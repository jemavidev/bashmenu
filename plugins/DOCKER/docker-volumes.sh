#!/bin/bash
#
# Docker Volumes Management Script
# Version: 1.0.0
# Description: Manage Docker volumes (list, create, remove, backup, restore)
#
# Usage: ./docker-volumes.sh
#
# This script provides comprehensive Docker volume management:
# - List all volumes with usage information
# - Create named volumes with custom drivers
# - Remove volumes safely (with usage checks)
# - Inspect volume details and usage
# - Backup volumes to compressed archives
# - Restore volumes from backups
#
# Examples:
#   ./docker-volumes.sh  # Interactive menu mode
#
# Volume types:
#   - Named volumes: Persistent data storage
#   - Bind mounts: Host directory mounting
#   - tmpfs: Temporary in-memory storage
#
# Safety features:
#   - Checks volume usage before removal
#   - Confirms destructive operations
#   - Backup verification
#

set -euo pipefail

readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'; readonly CYAN='\033[0;36m'; readonly NC='\033[0m'
readonly EXIT_SUCCESS=0; readonly EXIT_DOCKER_ERROR=1; readonly EXIT_USER_CANCEL=2
readonly BACKUP_DIR="./docker-volume-backups"

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_header() { echo -e "${CYAN}═══ $1 ═══${NC}"; }
print_separator() { echo "────────────────────────────────────────────────────────────────"; }

check_docker() { docker info &>/dev/null || { print_error "Docker daemon is not available"; return 1; }; }

confirm() {
    local response
    while true; do
        read -p "$1 (yes/no): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) print_error "Please answer 'yes' or 'no'" ;;
        esac
    done
}

list_volumes() {
    print_header "💾 Docker Volumes Overview"
    print_separator

    # Show volumes with better formatting
    print_info "📦 All Volumes:"
    docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"

    print_separator

    # Volume statistics
    local total_volumes=$(docker volume ls -q | wc -l)
    local local_volumes=$(docker volume ls --filter driver=local -q | wc -l)
    local other_drivers=$((total_volumes - local_volumes))

    print_info "📊 Volume Statistics:"
    echo "  💽 Total volumes: $total_volumes"
    echo "  🏠 Local driver volumes: $local_volumes"
    if [ $other_drivers -gt 0 ]; then
        echo "  🔌 Other drivers: $other_drivers"
    fi

    # Check for dangling volumes
    local dangling=$(docker volume ls -f "dangling=true" -q | wc -l)
    if [ $dangling -gt 0 ]; then
        print_warning "⚠️ Found $dangling dangling volume(s) - these are not attached to any container"
        print_info "💡 Dangling volumes can be safely removed to free disk space"
    else
        print_success "✅ No dangling volumes found"
    fi

    # Show volume usage
    echo ""
    print_info "🔗 Volume Usage (containers per volume):"
    for volume in $(docker volume ls --format "{{.Name}}"); do
        local container_count=$(docker ps -a --filter "volume=$volume" -q | wc -l)
        local driver=$(docker volume ls --filter name="$volume" --format "{{.Driver}}")
        printf "  %-25s %-8s %3d containers\n" "$volume" "$driver" "$container_count"
    done

    # Calculate total size if possible
    local total_size=0
    for volume in $(docker volume ls --format "{{.Name}}"); do
        local mountpoint=$(docker volume inspect "$volume" --format "{{.Mountpoint}}" 2>/dev/null)
        if [[ -d "$mountpoint" ]]; then
            local vol_size=$(du -sb "$mountpoint" 2>/dev/null | cut -f1 || echo "0")
            total_size=$((total_size + vol_size))
        fi
    done

    if [ $total_size -gt 0 ]; then
        local total_size_mb=$((total_size / 1024 / 1024))
        print_separator
        print_info "💾 Estimated total volume size: ${total_size_mb}MB"
    fi

    print_separator
}

create_volume() {
    print_info "💾 Create new Docker volume"
    print_info "Volumes provide persistent storage for container data"
    print_separator

    # Volume name input with validation
    local vol_name=""
    while [[ -z "$vol_name" ]]; do
        read -p "Volume name: " vol_name
        if [[ -z "$vol_name" ]]; then
            print_error "❌ Volume name cannot be empty"
            continue
        fi

        # Validate volume name format
        if [[ ! "$vol_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
            print_error "❌ Invalid volume name. Use only letters, numbers, hyphens, underscores"
            print_info "💡 Name must start with letter or number"
            vol_name=""
            continue
        fi

        # Check if volume already exists
        if docker volume ls --format "{{.Name}}" | grep -q "^${vol_name}$"; then
            print_error "❌ Volume already exists: $vol_name"
            if ! confirm "Choose a different name?"; then
                return 1
            fi
            vol_name=""
            continue
        fi
    done

    print_success "✅ Volume name: $vol_name"

    # Driver selection with explanations
    print_info "Select volume driver:"
    echo "  1) 🏠 local (default) - Local storage on host"
    echo "     📝 Best for: Most applications, development"
    echo "  2) ☁️ cloud - Cloud storage (requires plugin)"
    echo "     📝 Best for: Cloud-native deployments"
    echo "  3) 🔌 custom - Custom driver (specify name)"
    echo "     📝 Best for: Specialized storage solutions"

    read -p "Selection (1-3): " driver_choice

    local driver="local"
    case $driver_choice in
        2)
            driver="cloud"
            print_info "⚠️ Cloud driver requires cloud storage plugin"
            ;;
        3)
            read -p "Custom driver name: " custom_driver
            if [[ -n "$custom_driver" ]]; then
                driver="$custom_driver"
            else
                print_warning "⚠️ Using default 'local' driver"
            fi
            ;;
        1|"")
            driver="local"
            ;;
        *)
            print_warning "⚠️ Invalid selection, using 'local' driver"
            ;;
    esac

    print_success "✅ Driver: $driver"

    # Additional options
    local create_cmd="docker volume create --driver $driver"

    if confirm "⚙️ Configure additional options?"; then
        if [[ "$driver" == "local" ]]; then
            read -p "Mount options (e.g., uid=1000,gid=1000): " opts
            if [[ -n "$opts" ]]; then
                create_cmd+=" --opt $opts"
                print_success "✅ Mount options: $opts"
            fi
        fi

        read -p "Labels (key=value pairs, comma-separated): " labels
        if [[ -n "$labels" ]]; then
            IFS=',' read -ra label_array <<< "$labels"
            for label in "${label_array[@]}"; do
                if [[ "$label" =~ ^[a-zA-Z0-9._-]+=.+$ ]]; then
                    create_cmd+=" --label $label"
                fi
            done
            print_success "✅ Labels configured"
        fi
    fi

    create_cmd+=" $vol_name"

    print_separator
    print_info "🚀 Creating volume..."
    print_info "Command: $create_cmd"

    if eval "$create_cmd" &>/dev/null; then
        print_success "✅ Volume created successfully!"

        # Show volume details
        print_separator
        print_info "📋 Volume Details:"
        docker volume inspect "$vol_name" --format='  Name: {{.Name}}
  Driver: {{.Driver}}
  Mountpoint: {{.Mountpoint}}
  Created: {{.CreatedAt}}
  Scope: {{.Scope}}'

        print_separator
        print_info "💡 Next steps:"
        echo "  • Mount in container: docker run -v $vol_name:/data <image>"
        echo "  • Inspect volume: docker volume inspect $vol_name"
        echo "  • Remove when done: docker volume rm $vol_name"

        return 0
    else
        print_error "❌ Failed to create volume"
        print_info "💡 Check Docker daemon status and driver availability"
        return 1
    fi
}

remove_volume() {
    local volumes=()
    while IFS= read -r vol; do
        volumes+=("$vol")
    done < <(docker volume ls --format "{{.Name}}")
    
    if [ ${#volumes[@]} -eq 0 ]; then
        print_warning "No volumes found"
        return 1
    fi
    
    print_info "Select volume to remove:"
    for i in "${!volumes[@]}"; do
        echo "  $((i+1))) ${volumes[$i]}"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#volumes[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local vol_name="${volumes[$((selection-1))]}"
    
    # Check if volume is in use
    local in_use=$(docker ps -a --filter "volume=$vol_name" --format "{{.Names}}" | wc -l)
    if [ $in_use -gt 0 ]; then
        print_warning "Volume is used by $in_use container(s):"
        docker ps -a --filter "volume=$vol_name" --format "  - {{.Names}}"
        if ! confirm "Force remove anyway?"; then
            return 1
        fi
    fi
    
    print_warning "This will permanently delete volume data!"
    if ! confirm "Remove volume $vol_name?"; then
        return 1
    fi
    
    if docker volume rm "$vol_name" &>/dev/null; then
        print_success "Volume removed: $vol_name"
        return 0
    else
        print_error "Failed to remove volume"
        return 1
    fi
}

inspect_volume() {
    local volumes=()
    while IFS='|' read -r name driver mountpoint; do
        volumes+=("$name|$driver|$mountpoint")
    done < <(docker volume ls --format "{{.Name}}|{{.Driver}}|{{.Mountpoint}}")

    if [ ${#volumes[@]} -eq 0 ]; then
        print_warning "⚠️ No volumes found"
        print_info "💡 Create volumes first with 'docker volume create' or the create option"
        return 1
    fi

    print_info "🔍 Select volume to inspect:"
    printf "  %-4s %-25s %-10s %s\n" "NUM" "NAME" "DRIVER" "MOUNTPOINT"
    print_separator

    for i in "${!volumes[@]}"; do
        IFS='|' read -r name driver mountpoint <<< "${volumes[$i]}"
        printf "  %-4s %-25s %-10s %s\n" "$((i+1))" "$name" "$driver" "${mountpoint:0:30}"
    done
    echo ""

    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#volumes[@]}" ]; then
        print_error "❌ Invalid selection"
        return 1
    fi

    IFS='|' read -r vol_name _ _ <<< "${volumes[$((selection-1))]}"

    print_separator
    print_header "🔍 Volume Inspection: $vol_name"
    print_separator

    # Basic volume information
    print_info "📋 Basic Information:"
    local volume_info=$(docker volume inspect "$vol_name" 2>/dev/null)
    if [[ -z "$volume_info" ]]; then
        print_error "❌ Could not inspect volume: $vol_name"
        return 1
    fi

    echo "  📛 Name: $(echo "$volume_info" | jq -r '.[0].Name' 2>/dev/null || docker volume inspect "$vol_name" --format '{{.Name}}')"
    echo "  🔧 Driver: $(echo "$volume_info" | jq -r '.[0].Driver' 2>/dev/null || docker volume inspect "$vol_name" --format '{{.Driver}}')"
    echo "  📍 Mountpoint: $(echo "$volume_info" | jq -r '.[0].Mountpoint' 2>/dev/null || docker volume inspect "$vol_name" --format '{{.Mountpoint}}')"
    echo "  📅 Created: $(echo "$volume_info" | jq -r '.[0].CreatedAt' 2>/dev/null || docker volume inspect "$vol_name" --format '{{.CreatedAt}}')"
    echo "  🌍 Scope: $(echo "$volume_info" | jq -r '.[0].Scope' 2>/dev/null || docker volume inspect "$vol_name" --format '{{.Scope}}')"

    # Labels
    local labels=$(docker volume inspect "$vol_name" --format '{{range $k,$v := .Labels}}{{$k}}={{$v}} {{end}}' 2>/dev/null)
    if [[ -n "$labels" ]]; then
        echo "  🏷️  Labels: $labels"
    fi

    # Containers using this volume
    echo ""
    print_info "🐳 Containers using this volume:"
    local containers=$(docker ps -a --filter "volume=$vol_name" --format '{{.Names}} ({{.Status}})' 2>/dev/null)
    local container_count=$(docker ps -a --filter "volume=$vol_name" -q | wc -l)

    if [[ "$container_count" -eq 0 ]]; then
        echo "  📭 No containers are currently using this volume"
        print_info "💡 Volume is available for use by any container"
    else
        echo "  📦 $container_count container(s) using this volume:"
        if [[ -n "$containers" ]]; then
            echo "$containers" | sed 's/^/    • /'
        fi
    fi

    # Volume size and contents
    local mountpoint=$(docker volume inspect "$vol_name" --format '{{.Mountpoint}}' 2>/dev/null)
    if [[ -d "$mountpoint" ]]; then
        echo ""
        print_info "💾 Volume Contents:"
        local file_count=$(find "$mountpoint" -type f 2>/dev/null | wc -l)
        local dir_count=$(find "$mountpoint" -type d 2>/dev/null | wc -l)
        local volume_size=$(du -sh "$mountpoint" 2>/dev/null | cut -f1)

        echo "  📂 Directories: $dir_count"
        echo "  📄 Files: $file_count"
        echo "  💽 Size on disk: $volume_size"

        if [ $file_count -gt 0 ]; then
            echo ""
            print_info "📁 Top-level contents (first 10 items):"
            ls -la "$mountpoint" 2>/dev/null | head -n 11 | tail -n +2 | sed 's/^/    /'
        fi
    fi

    # Options and driver-specific info
    local driver=$(docker volume inspect "$vol_name" --format '{{.Driver}}' 2>/dev/null)
    case $driver in
        local)
            local opts=$(docker volume inspect "$vol_name" --format '{{range $k,$v := .Options}}{{$k}}={{$v}} {{end}}' 2>/dev/null)
            if [[ -n "$opts" ]]; then
                echo ""
                print_info "⚙️ Driver Options:"
                echo "  $opts"
            fi
            ;;
    esac

    print_separator

    # Usage recommendations
    if [[ "$container_count" -eq 0 ]]; then
        print_info "💡 This volume is not in use"
        echo "  • Mount in container: docker run -v $vol_name:/data <image>"
        echo "  • Backup volume: Use the backup option in this menu"
        echo "  • Remove if unused: docker volume rm $vol_name"
    else
        print_info "💡 Volume is actively used by $container_count container(s)"
        echo "  • Stop containers first: docker stop <container_name>"
        echo "  • Backup before changes: Use backup option"
        echo "  • Check container logs: docker logs <container_name>"
    fi

    print_separator

    if confirm "📄 View complete JSON configuration?"; then
        print_separator
        print_info "Complete JSON output (press 'q' to exit):"
        docker volume inspect "$vol_name" | less
        print_separator
    fi
}

backup_volume() {
    local volumes=()
    while IFS='|' read -r name driver mountpoint; do
        volumes+=("$name|$driver|$mountpoint")
    done < <(docker volume ls --format "{{.Name}}|{{.Driver}}|{{.Mountpoint}}")

    if [ ${#volumes[@]} -eq 0 ]; then
        print_warning "⚠️ No volumes found to backup"
        print_info "💡 Create volumes first before backing them up"
        return 1
    fi

    print_info "💾 Select volume to backup:"
    printf "  %-4s %-25s %-10s %s\n" "NUM" "NAME" "DRIVER" "MOUNTPOINT"
    print_separator

    for i in "${!volumes[@]}"; do
        IFS='|' read -r name driver mountpoint <<< "${volumes[$i]}"
        printf "  %-4s %-25s %-10s %s\n" "$((i+1))" "$name" "$driver" "${mountpoint:0:30}"
    done
    echo ""

    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#volumes[@]}" ]; then
        print_error "❌ Invalid selection"
        return 1
    fi

    IFS='|' read -r vol_name driver mountpoint <<< "${volumes[$((selection-1))]}"

    print_success "✅ Selected volume: $vol_name ($driver driver)"

    # Check if volume has content
    local file_count=$(docker run --rm -v "$vol_name:/volume" alpine find /volume -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        print_warning "⚠️ Volume appears to be empty ($file_count files)"
        if ! confirm "Continue with backup anyway?"; then
            print_info "ℹ️ Backup cancelled"
            return 1
        fi
    fi

    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="$BACKUP_DIR/${vol_name}_${timestamp}.tar.gz"

    print_info "📦 Creating backup archive..."
    print_info "📁 Backup location: $backup_file"

    # Show progress for large backups
    local start_time=$(date +%s)
    print_info "⏳ Compressing volume data (this may take a while for large volumes)..."

    if docker run --rm -v "$vol_name:/volume" -v "$BACKUP_DIR:/backup" alpine sh -c "cd /volume && tar czf \"/backup/$(basename "$backup_file")\" . 2>/dev/null"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Verify backup was created
        if [[ -f "$backup_file" ]]; then
            local size=$(du -h "$backup_file" | cut -f1)
            local size_bytes=$(du -b "$backup_file" | cut -f1)
            local size_mb=$((size_bytes / 1024 / 1024))

            print_success "✅ Backup completed successfully!"
            print_info "📊 Backup details:"
            echo "  📁 File: $(basename "$backup_file")"
            echo "  📍 Location: $BACKUP_DIR/"
            echo "  💾 Size: $size (${size_mb}MB)"
            echo "  ⏱️  Duration: ${duration}s"
            echo "  📄 Files backed up: ~$file_count"

            # Show backup directory contents
            print_separator
            print_info "📂 Recent backups in $BACKUP_DIR:"
            ls -la "$BACKUP_DIR" | tail -n 6 | head -n 5 | sed 's/^/  /'

            print_separator
            print_info "💡 Backup commands for reference:"
            echo "  • Restore: Use 'Restore volume' option in this menu"
            echo "  • Extract manually: tar -xzf $backup_file -C /target/dir"
            echo "  • Verify: tar -tzf $backup_file | head -10"

            return 0
        else
            print_error "❌ Backup file was not created"
            return 1
        fi
    else
        local exit_code=$?
        print_error "❌ Backup failed with exit code: $exit_code"
        print_info "💡 Possible causes:"
        echo "  • Insufficient disk space"
        echo "  • Permission issues"
        echo "  • Volume mount problems"
        echo "  • Docker daemon issues"
        return 1
    fi
}

restore_volume() {
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]]; then
        print_error "No backups found in $BACKUP_DIR"
        return 1
    fi
    
    local backups=()
    while IFS= read -r backup; do
        backups+=("$backup")
    done < <(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null)
    
    print_info "Select backup to restore:"
    for i in "${!backups[@]}"; do
        local size=$(du -h "${backups[$i]}" | cut -f1)
        echo "  $((i+1))) $(basename ${backups[$i]}) ($size)"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -le "${#backups[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local backup_file="${backups[$((selection-1))]}"
    
    read -p "Target volume name: " vol_name
    if [[ -z "$vol_name" ]]; then
        print_error "Volume name cannot be empty"
        return 1
    fi
    
    # Create volume if it doesn't exist
    if ! docker volume ls --format "{{.Name}}" | grep -q "^${vol_name}$"; then
        print_info "Creating volume: $vol_name"
        docker volume create "$vol_name" &>/dev/null
    fi
    
    print_warning "This will overwrite existing data in volume: $vol_name"
    if ! confirm "Continue with restore?"; then
        return 1
    fi
    
    print_info "Restoring backup..."
    
    if docker run --rm -v "$vol_name:/volume" -v "$(dirname $backup_file):/backup" alpine sh -c "cd /volume && tar xzf /backup/$(basename $backup_file)" &>/dev/null; then
        print_success "Restore completed: $vol_name"
        return 0
    else
        print_error "Restore failed"
        return 1
    fi
}

show_menu() {
    print_header "Docker Volumes Management"
    echo ""
    echo "  1) List volumes"
    echo "  2) Create volume"
    echo "  3) Remove volume"
    echo "  4) Inspect volume"
    echo "  5) Backup volume"
    echo "  6) Restore volume"
    echo "  0) Exit"
    echo ""
}

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    check_docker || exit $EXIT_DOCKER_ERROR
    
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) list_volumes; echo ""; read -p "Press Enter to continue..." ;;
            2) create_volume; echo ""; read -p "Press Enter to continue..." ;;
            3) remove_volume; echo ""; read -p "Press Enter to continue..." ;;
            4) inspect_volume; echo ""; read -p "Press Enter to continue..." ;;
            5) backup_volume; echo ""; read -p "Press Enter to continue..." ;;
            6) restore_volume; echo ""; read -p "Press Enter to continue..." ;;
            0) print_info "Exiting..."; exit $EXIT_SUCCESS ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

main "$@"

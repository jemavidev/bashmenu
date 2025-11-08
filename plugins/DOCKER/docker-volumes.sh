#!/bin/bash
#
# Docker Volumes Management Script
# Version: 1.0.0
# Description: Manage Docker volumes (list, create, remove, backup, restore)
#
# Usage: ./docker-volumes.sh
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
    print_header "Docker Volumes"
    print_separator
    docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"
    print_separator
    
    local count=$(docker volume ls -q | wc -l)
    print_info "Total volumes: $count"
    
    local dangling=$(docker volume ls -f "dangling=true" -q | wc -l)
    if [ $dangling -gt 0 ]; then
        print_warning "Unused volumes: $dangling"
    fi
    print_separator
}

create_volume() {
    print_info "Create new volume"
    print_separator
    
    read -p "Volume name: " vol_name
    if [[ -z "$vol_name" ]]; then
        print_error "Volume name cannot be empty"
        return 1
    fi
    
    if docker volume ls --format "{{.Name}}" | grep -q "^${vol_name}$"; then
        print_error "Volume already exists: $vol_name"
        return 1
    fi
    
    read -p "Driver (default: local): " driver
    driver="${driver:-local}"
    
    if docker volume create --driver "$driver" "$vol_name" &>/dev/null; then
        print_success "Volume created: $vol_name"
        return 0
    else
        print_error "Failed to create volume"
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
    while IFS= read -r vol; do
        volumes+=("$vol")
    done < <(docker volume ls --format "{{.Name}}")
    
    if [ ${#volumes[@]} -eq 0 ]; then
        print_warning "No volumes found"
        return 1
    fi
    
    print_info "Select volume to inspect:"
    for i in "${!volumes[@]}"; do
        echo "  $((i+1))) ${volumes[$i]}"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#volumes[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local vol_name="${volumes[$((selection-1))]}"
    
    print_separator
    print_header "Volume: $vol_name"
    print_separator
    
    docker volume inspect "$vol_name" --format='
  Name: {{.Name}}
  Driver: {{.Driver}}
  Mountpoint: {{.Mountpoint}}
  Created: {{.CreatedAt}}
  Scope: {{.Scope}}'
    
    echo ""
    print_info "Containers using this volume:"
    local containers=$(docker ps -a --filter "volume=$vol_name" --format "{{.Names}}")
    if [[ -z "$containers" ]]; then
        echo "  None"
    else
        echo "$containers" | sed 's/^/  - /'
    fi
    
    print_separator
}

backup_volume() {
    local volumes=()
    while IFS= read -r vol; do
        volumes+=("$vol")
    done < <(docker volume ls --format "{{.Name}}")
    
    if [ ${#volumes[@]} -eq 0 ]; then
        print_warning "No volumes found"
        return 1
    fi
    
    print_info "Select volume to backup:"
    for i in "${!volumes[@]}"; do
        echo "  $((i+1))) ${volumes[$i]}"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#volumes[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local vol_name="${volumes[$((selection-1))]}"
    
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/${vol_name}_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    print_info "Creating backup: $backup_file"
    
    if docker run --rm -v "$vol_name:/volume" -v "$BACKUP_DIR:/backup" alpine tar czf "/backup/$(basename $backup_file)" -C /volume . &>/dev/null; then
        print_success "Backup created: $backup_file"
        local size=$(du -h "$backup_file" | cut -f1)
        print_info "Backup size: $size"
        return 0
    else
        print_error "Backup failed"
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

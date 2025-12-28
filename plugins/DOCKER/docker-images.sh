#!/bin/bash
#
# Docker Images Management Script
# Version: 1.0.0
# Description: Manage Docker images (list, remove, tag, push)
#
# Usage: ./docker-images.sh
#
# This script provides comprehensive image management with:
# - List all images with disk usage information
# - Remove images safely (with container checks)
# - Create tags for existing images
# - Push images to registries
# - Handle dangling images cleanup
#
# Examples:
#   ./docker-images.sh  # Interactive menu mode
#
# Safety features:
#   - Checks if images are in use before removal
#   - Confirms destructive operations
#   - Shows disk space information
#   - Handles dangling images
#

set -euo pipefail

# ============================================================================
# CONSTANTS
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

readonly EXIT_SUCCESS=0
readonly EXIT_DOCKER_ERROR=1
readonly EXIT_USER_CANCEL=2

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }
print_header() { echo -e "${CYAN}═══ $1 ═══${NC}"; }
print_separator() { echo "────────────────────────────────────────────────────────────────"; }

check_docker() {
    if docker info &>/dev/null; then
        return 0
    fi
    print_error "Docker daemon is not available"
    return 1
}

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

# ============================================================================
# LIST IMAGES
# ============================================================================

list_images() {
    print_header "📋 Docker Images Overview"
    print_separator

    # Show regular images with better formatting
    print_info "📦 Regular Images (latest 20):"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | head -n 20

    print_separator

    # Show dangling images with warning
    local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
    if [ "$dangling_count" -gt 0 ]; then
        print_warning "⚠️ Found $dangling_count dangling image(s) - these are untagged and unused"
        print_info "💡 Dangling images can be safely removed to free disk space"
        if confirm "Show dangling images details?"; then
            print_separator
            print_info "🗑️ Dangling Images:"
            docker images -f "dangling=true" --format "table {{.ID}}\t{{.Size}}\t{{.CreatedSince}}"
            print_separator
        fi
    else
        print_success "✅ No dangling images found"
    fi

    # Show comprehensive disk usage
    print_separator
    print_info "💾 System Disk Usage:"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"

    # Additional statistics
    local total_images=$(docker images -q | wc -l)
    local total_size=$(docker images --format "{{.Size}}" | sed 's/B$//' | sed 's/KB$/ * 1024/' | sed 's/MB$/ * 1024 * 1024/' | sed 's/GB$/ * 1024 * 1024 * 1024/' | bc 2>/dev/null | paste -sd+ | bc 2>/dev/null || echo "0")
    local total_size_mb=$((total_size / 1024 / 1024))

    print_separator
    print_info "📊 Summary:"
    echo "  • Total images: $total_images"
    echo "  • Total size: ${total_size_mb}MB"
    echo "  • Dangling images: $dangling_count"
    print_separator
}

# ============================================================================
# REMOVE IMAGES
# ============================================================================

select_images_to_remove() {
    local -n images=$1
    local -n selected=$2

    print_info "🔍 Loading available images..."

    while IFS='|' read -r id repo tag size; do
        images+=("$id|$repo|$tag|$size")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}")

    if [ ${#images[@]} -eq 0 ]; then
        print_warning "⚠️ No images found to remove"
        print_info "💡 Create images first with 'docker build' or pull from registry"
        return 1
    fi

    print_info "📦 Available images for removal:"
    printf "  %-4s %-15s %-30s %-15s %s\n" "NUM" "ID" "REPOSITORY" "TAG" "SIZE"
    print_separator

    for i in "${!images[@]}"; do
        IFS='|' read -r id repo tag size <<< "${images[$i]}"
        printf "  %-4s %-15s %-30s %-15s %s\n" "$((i+1))" "${id:0:12}" "${repo:0:28}" "${tag:0:13}" "$size"
    done
    echo ""

    print_info "🗑️ Select images to remove:"
    echo "  • Enter numbers: '1 3 5' to select specific images"
    echo "  • Enter 'dangling' to remove all dangling (untagged) images"
    echo "  • Enter 'unused' to remove images not used by containers"
    echo "  • Enter '0' to cancel"
    print_warning "⚠️ Removed images cannot be recovered!"

    local input
    read -p "Selection: " input

    if [[ "$input" == "0" ]]; then
        print_info "ℹ️ Operation cancelled"
        return 1
    fi

    if [[ "$input" == "dangling" ]]; then
        while IFS= read -r id; do
            selected+=("$id")
        done < <(docker images -f "dangling=true" -q)

        if [ ${#selected[@]} -eq 0 ]; then
            print_warning "⚠️ No dangling images found"
            return 1
        fi

        print_success "✅ Selected ${#selected[@]} dangling image(s) for removal"
        print_info "💡 Dangling images are safe to remove - they're not referenced by any tag"
        return 0
    fi

    if [[ "$input" == "unused" ]]; then
        while IFS= read -r id; do
            selected+=("$id")
        done < <(docker images -q)

        # Filter out images that are used by containers
        local filtered_selected=()
        for img_id in "${selected[@]}"; do
            local in_use=$(docker ps -a --filter "ancestor=$img_id" -q | wc -l)
            if [ "$in_use" -eq 0 ]; then
                filtered_selected+=("$img_id")
            fi
        done

        selected=("${filtered_selected[@]}")

        if [ ${#selected[@]} -eq 0 ]; then
            print_warning "⚠️ No unused images found (all images are used by containers)"
            return 1
        fi

        print_success "✅ Selected ${#selected[@]} unused image(s) for removal"
        print_info "💡 These images are not currently used by any containers"
        return 0
    fi

    # Parse individual selections
    local valid_selections=()
    for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#images[@]}" ]; then
            IFS='|' read -r id repo tag _ <<< "${images[$((num-1))]}"
            selected+=("$id")
            valid_selections+=("$repo:$tag")
        else
            print_warning "⚠️ Invalid selection: $num (valid range: 1-${#images[@]})"
        fi
    done

    if [ ${#selected[@]} -eq 0 ]; then
        print_error "❌ No valid images selected"
        return 1
    fi

    print_success "✅ Selected ${#selected[@]} image(s): ${valid_selections[*]}"
    return 0
}

remove_images() {
    local -n image_ids=$1
    local force="$2"

    local removed_count=0
    local failed_count=0
    local skipped_count=0

    # Get disk usage before removal
    local space_before=$(docker system df --format "{{.Size}}" 2>/dev/null | tail -n 1 || echo "0B")

    print_separator
    print_info "🗑️ Removing ${#image_ids[@]} image(s)..."
    print_separator

    for image_id in "${image_ids[@]}"; do
        local image_info=$(docker images --format "{{.Repository}}:{{.Tag}}" --filter "id=$image_id" 2>/dev/null | head -n 1 || echo "unknown")

        # Check if image is in use by running containers
        local running_containers=$(docker ps --filter "ancestor=$image_id" -q | wc -l)
        local all_containers=$(docker ps -a --filter "ancestor=$image_id" -q | wc -l)

        if [ "$running_containers" -gt 0 ]; then
            print_warning "⚠️ Image $image_info is used by $running_containers running container(s)"
            if [[ "$force" != "true" ]]; then
                if ! confirm "Force remove (will stop containers)?"; then
                    print_info "⏭️ Skipped: $image_info"
                    ((skipped_count++))
                    continue
                fi
                force="true"
            fi
        elif [ "$all_containers" -gt 0 ]; then
            print_warning "⚠️ Image $image_info is used by $all_containers stopped container(s)"
            if [[ "$force" != "true" ]]; then
                if ! confirm "Remove anyway (containers will remain)?"; then
                    print_info "⏭️ Skipped: $image_info"
                    ((skipped_count++))
                    continue
                fi
            fi
        fi

        local rm_cmd="docker rmi"
        if [[ "$force" == "true" ]]; then
            rm_cmd+=" -f"
            print_info "🔨 Force removing: $image_info"
        else
            print_info "🗑️ Removing: $image_info"
        fi
        rm_cmd+=" $image_id"

        if eval "$rm_cmd" &>/dev/null; then
            print_success "✅ Removed: $image_info"
            ((removed_count++))
        else
            print_error "❌ Failed to remove: $image_info"
            ((failed_count++))
        fi
    done

    print_separator
    print_header "📊 Removal Summary"
    print_success "✅ Images removed: $removed_count"
    if [ $skipped_count -gt 0 ]; then
        print_info "⏭️ Images skipped: $skipped_count"
    fi
    if [ $failed_count -gt 0 ]; then
        print_error "❌ Failed removals: $failed_count"
    fi

    # Show disk space impact
    local space_after=$(docker system df --format "{{.Size}}" 2>/dev/null | tail -n 1 || echo "0B")
    print_separator
    print_info "💾 Disk Usage:"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}" | grep -i "images"
    print_separator
}

# ============================================================================
# CREATE TAG
# ============================================================================

create_tag() {
    print_info "🏷️ Create new tag for existing image"
    print_info "This allows you to create multiple references to the same image"
    print_separator

    # List images
    local images=()
    while IFS='|' read -r id repo tag size; do
        images+=("$id|$repo:$tag|$size")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}" | grep -v "<none>")

    if [ ${#images[@]} -eq 0 ]; then
        print_error "❌ No tagged images available"
        print_info "💡 Create images first with 'docker build' or pull from registry"
        return 1
    fi

    print_info "Select source image to tag:"
    printf "  %-4s %-15s %-35s %s\n" "NUM" "ID" "IMAGE" "SIZE"
    print_separator

    for i in "${!images[@]}"; do
        IFS='|' read -r id name size <<< "${images[$i]}"
        printf "  %-4s %-15s %-35s %s\n" "$((i+1))" "${id:0:12}" "$name" "$size"
    done
    echo ""

    local selection
    read -p "Select image: " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#images[@]}" ]; then
        print_error "❌ Invalid selection"
        return 1
    fi

    IFS='|' read -r source_id source_name _ <<< "${images[$((selection-1))]}"

    print_success "✅ Selected source: $source_name"
    print_separator

    # Get new tag with validation
    print_info "Enter new tag details:"
    print_info "📝 Examples:"
    echo "  • myapp:v2.0 (version tag)"
    echo "  • myregistry.com/user/app:stable (registry with tag)"
    echo "  • localhost:5000/myapp:latest (local registry)"

    local new_repo new_tag
    read -p "New repository name: " new_repo
    if [[ -z "$new_repo" ]]; then
        print_error "❌ Repository name cannot be empty"
        return 1
    fi

    read -p "New tag: " new_tag
    if [[ -z "$new_tag" ]]; then
        new_tag="latest"
        print_warning "⚠️ Using default tag: latest"
    fi

    local full_new_tag="${new_repo}:${new_tag}"

    # Validate new tag format
    if [[ ! "$full_new_tag" =~ ^[a-zA-Z0-9._/-]+:[a-zA-Z0-9._-]+$ ]]; then
        print_error "❌ Invalid tag format"
        print_info "💡 Use format: repository:tag (e.g., myapp:v1.0)"
        return 1
    fi

    # Check if tag already exists
    if docker image inspect "$full_new_tag" &>/dev/null; then
        print_warning "⚠️ Tag $full_new_tag already exists"
        if ! confirm "Overwrite existing tag?"; then
            print_info "ℹ️ Tag creation cancelled"
            return 1
        fi
    fi

    print_info "🏷️ Creating tag: $source_name → $full_new_tag"

    # Create tag
    if docker tag "$source_id" "$full_new_tag"; then
        print_success "✅ Tag created successfully!"
        print_info "📋 Tag details:"
        echo "  • Source: $source_name"
        echo "  • New tag: $full_new_tag"
        echo "  • Same image ID: $source_id"

        # Show the new tag in images list
        print_separator
        print_info "🔍 Verification - new tag in images list:"
        docker images "$new_repo" --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}"

        return 0
    else
        print_error "❌ Failed to create tag"
        print_info "💡 Check Docker daemon status and permissions"
        return 1
    fi
}

# ============================================================================
# PUSH IMAGE
# ============================================================================

push_image() {
    print_info "📤 Push image to registry"
    print_info "Share your images with others or deploy to remote environments"
    print_separator

    # List images
    local images=()
    while IFS='|' read -r repo tag size; do
        images+=("$repo:$tag|$size")
    done < <(docker images --format "{{.Repository}}|{{.Tag}}|{{.Size}}" | grep -v "<none>")

    if [ ${#images[@]} -eq 0 ]; then
        print_error "❌ No tagged images available to push"
        print_info "💡 Create images first with 'docker build' or tag existing images"
        return 1
    fi

    print_info "Select image to push:"
    printf "  %-4s %-40s %s\n" "NUM" "IMAGE" "SIZE"
    print_separator

    for i in "${!images[@]}"; do
        IFS='|' read -r name size <<< "${images[$i]}"
        printf "  %-4s %-40s %s\n" "$((i+1))" "$name" "$size"
    done
    echo ""

    local selection
    read -p "Select image: " selection

    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#images[@]}" ]; then
        print_error "❌ Invalid selection"
        return 1
    fi

    IFS='|' read -r image_name _ <<< "${images[$((selection-1))]}"

    print_success "✅ Selected: $image_name"
    print_separator

    # Check registry type and login status
    if [[ "$image_name" =~ ^[^/]+\.[^/]+ ]]; then
        print_info "🌐 Pushing to remote registry"
        print_info "💡 Make sure you're logged in: docker login <registry>"
    elif [[ "$image_name" =~ ^[^/]+/ ]]; then
        print_info "🐳 Pushing to Docker Hub"
        print_info "💡 Make sure you're logged in: docker login"
    else
        print_warning "⚠️ Local registry detected - ensure registry is accessible"
    fi

    # Check if logged in (for Docker Hub)
    if [[ "$image_name" =~ ^[^/]+/[^/]+: ]] || [[ "$image_name" =~ ^[^/]+/[^/]+$ ]]; then
        local registry=$(echo "$image_name" | cut -d'/' -f1)
        if ! docker system info 2>/dev/null | grep -q "Registry:.*$registry"; then
            print_warning "⚠️ Not logged in to registry: $registry"
            print_info "💡 Run: docker login $registry"
            if ! confirm "Continue anyway?"; then
                print_info "ℹ️ Push cancelled"
                return 1
            fi
        fi
    fi

    if ! confirm "🚀 Start pushing $image_name?"; then
        print_info "ℹ️ Push cancelled"
        return 1
    fi

    print_info "📤 Pushing image: $image_name"
    print_info "⏳ This may take several minutes depending on image size..."

    local start_time=$(date +%s)
    if docker push "$image_name"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "✅ Image pushed successfully!"
        print_info "📊 Push completed in ${duration}s"
        print_info "🌍 Image available at: $image_name"
        return 0
    else
        local exit_code=$?
        print_error "❌ Failed to push image (exit code: $exit_code)"
        print_info "💡 Possible solutions:"
        echo "  • Login to registry: docker login <registry>"
        echo "  • Check network connectivity"
        echo "  • Verify registry URL and credentials"
        echo "  • Check image name format"
        return 1
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    print_header "Docker Images Management"
    echo ""
    echo "  1) 📋 List images and disk usage"
    echo "  2) 🗑️  Remove images (with safety checks)"
    echo "  3) 🏷️  Create tag for existing image"
    echo "  4) 📤 Push image to registry"
    echo "  0) Exit"
    echo ""
    print_info "💡 Tip: Use 'docker system prune -a' for comprehensive cleanup"
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    :  # No cleanup needed
}

trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    print_header "Docker Images Management"
    print_info "Manage Docker images with interactive operations"
    print_info "This script helps you:"
    print_info "  • List and inspect all images"
    print_info "  • Remove unused or dangling images"
    print_info "  • Create tags for existing images"
    print_info "  • Push images to registries"
    print_info "  • Monitor disk usage"
    print_separator

    # Check Docker
    if ! check_docker; then
        exit $EXIT_DOCKER_ERROR
    fi

    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1)
                list_images
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                local images=()
                local selected=()
                
                if select_images_to_remove images selected; then
                    print_separator
                    print_warning "About to remove ${#selected[@]} image(s)"
                    
                    if confirm "Proceed with removal?"; then
                        local force="false"
                        if confirm "Force remove (ignore containers)?"; then
                            force="true"
                        fi
                        remove_images selected "$force"
                    else
                        print_info "Cancelled"
                    fi
                fi
                
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                create_tag
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                push_image
                echo ""
                read -p "Press Enter to continue..."
                ;;
            0)
                print_info "Exiting..."
                exit $EXIT_SUCCESS
                ;;
            *)
                print_error "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"

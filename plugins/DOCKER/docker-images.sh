#!/bin/bash
#
# Docker Images Management Script
# Version: 1.0.0
# Description: Manage Docker images (list, remove, tag, push)
#
# Usage: ./docker-images.sh
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
    print_header "Docker Images"
    print_separator
    
    # Show regular images
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | head -n 20
    
    print_separator
    
    # Show dangling images
    local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
    if [ "$dangling_count" -gt 0 ]; then
        print_warning "Found $dangling_count dangling image(s) (untagged)"
        if confirm "Show dangling images?"; then
            print_info "Dangling Images:"
            docker images -f "dangling=true" --format "table {{.ID}}\t{{.Size}}\t{{.CreatedSince}}"
        fi
    fi
    
    # Show total disk usage
    print_separator
    print_info "Disk Usage:"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | grep -i "images"
    print_separator
}

# ============================================================================
# REMOVE IMAGES
# ============================================================================

select_images_to_remove() {
    local -n images=$1
    local -n selected=$2
    
    print_info "Loading images..."
    
    while IFS='|' read -r id repo tag size; do
        images+=("$id|$repo|$tag|$size")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}")
    
    if [ ${#images[@]} -eq 0 ]; then
        print_warning "No images found"
        return 1
    fi
    
    print_info "Available images:"
    printf "  %-4s %-15s %-30s %-15s %s\n" "NUM" "ID" "REPOSITORY" "TAG" "SIZE"
    print_separator
    
    for i in "${!images[@]}"; do
        IFS='|' read -r id repo tag size <<< "${images[$i]}"
        printf "  %-4s %-15s %-30s %-15s %s\n" "$((i+1))" "${id:0:12}" "${repo:0:28}" "${tag:0:13}" "$size"
    done
    echo ""
    
    print_info "Select images to remove:"
    echo "  - Enter numbers separated by spaces (e.g., 1 3 5)"
    echo "  - Enter 'dangling' to remove all dangling images"
    echo "  - Enter '0' to cancel"
    
    local input
    read -p "Selection: " input
    
    if [[ "$input" == "0" ]]; then
        return 1
    fi
    
    if [[ "$input" == "dangling" ]]; then
        while IFS= read -r id; do
            selected+=("$id")
        done < <(docker images -f "dangling=true" -q)
        
        if [ ${#selected[@]} -eq 0 ]; then
            print_warning "No dangling images found"
            return 1
        fi
        
        print_success "Selected ${#selected[@]} dangling image(s)"
        return 0
    fi
    
    # Parse individual selections
    for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#images[@]}" ]; then
            IFS='|' read -r id _ _ _ <<< "${images[$((num-1))]}"
            selected+=("$id")
        else
            print_warning "Invalid selection: $num"
        fi
    done
    
    if [ ${#selected[@]} -eq 0 ]; then
        print_error "No valid images selected"
        return 1
    fi
    
    print_success "Selected ${#selected[@]} image(s)"
    return 0
}

remove_images() {
    local -n image_ids=$1
    local force="$2"
    
    local removed_count=0
    local failed_count=0
    local space_before=$(docker system df --format "{{.Size}}" | grep -i "images" | awk '{print $1}' || echo "0")
    
    print_separator
    print_info "Removing ${#image_ids[@]} image(s)..."
    print_separator
    
    for image_id in "${image_ids[@]}"; do
        local image_info=$(docker images --format "{{.Repository}}:{{.Tag}}" --filter "id=$image_id" | head -n 1)
        
        # Check if image is in use
        local in_use=$(docker ps -a --filter "ancestor=$image_id" -q | wc -l)
        if [ "$in_use" -gt 0 ] && [[ "$force" != "true" ]]; then
            print_warning "Image $image_info is used by $in_use container(s)"
            if ! confirm "Force remove anyway?"; then
                print_info "Skipped: $image_info"
                continue
            fi
            force="true"
        fi
        
        local rm_cmd="docker rmi"
        if [[ "$force" == "true" ]]; then
            rm_cmd+=" -f"
        fi
        rm_cmd+=" $image_id"
        
        if eval "$rm_cmd" &>/dev/null; then
            print_success "Removed: $image_info"
            ((removed_count++))
        else
            print_error "Failed to remove: $image_info"
            ((failed_count++))
        fi
    done
    
    print_separator
    print_success "Images removed: $removed_count"
    if [ $failed_count -gt 0 ]; then
        print_error "Failed removals: $failed_count"
    fi
    
    # Show space freed
    local space_after=$(docker system df --format "{{.Size}}" | grep -i "images" | awk '{print $1}' || echo "0")
    print_info "Space freed: Check with 'docker system df'"
    print_separator
}

# ============================================================================
# CREATE TAG
# ============================================================================

create_tag() {
    print_info "Create new tag for existing image"
    print_separator
    
    # List images
    local images=()
    while IFS='|' read -r id repo tag; do
        images+=("$id|$repo:$tag")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}" | grep -v "<none>")
    
    if [ ${#images[@]} -eq 0 ]; then
        print_error "No images available"
        return 1
    fi
    
    print_info "Select source image:"
    for i in "${!images[@]}"; do
        IFS='|' read -r id name <<< "${images[$i]}"
        echo "  $((i+1))) $name (${id:0:12})"
    done
    
    local selection
    read -p "Select image: " selection
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#images[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    IFS='|' read -r source_id source_name <<< "${images[$((selection-1))]}"
    
    print_info "Source image: $source_name"
    
    # Get new tag
    read -p "New image name (e.g., myrepo/myimage:v2.0): " new_tag
    
    if [[ -z "$new_tag" ]]; then
        print_error "Tag cannot be empty"
        return 1
    fi
    
    # Create tag
    if docker tag "$source_id" "$new_tag"; then
        print_success "Tag created: $new_tag"
        return 0
    else
        print_error "Failed to create tag"
        return 1
    fi
}

# ============================================================================
# PUSH IMAGE
# ============================================================================

push_image() {
    print_info "Push image to registry"
    print_separator
    
    # List images
    local images=()
    while IFS= read -r name; do
        images+=("$name")
    done < <(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
    
    if [ ${#images[@]} -eq 0 ]; then
        print_error "No images available"
        return 1
    fi
    
    print_info "Select image to push:"
    for i in "${!images[@]}"; do
        echo "  $((i+1))) ${images[$i]}"
    done
    
    local selection
    read -p "Select image: " selection
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#images[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local image_name="${images[$((selection-1))]}"
    
    print_info "Pushing: $image_name"
    print_warning "Ensure you are logged in to the registry (docker login)"
    
    if ! confirm "Continue with push?"; then
        return 1
    fi
    
    if docker push "$image_name"; then
        print_success "Image pushed successfully: $image_name"
        return 0
    else
        print_error "Failed to push image"
        print_info "You may need to login: docker login"
        return 1
    fi
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    print_header "Docker Images Management"
    echo ""
    echo "  1) List images"
    echo "  2) Remove images"
    echo "  3) Create tag"
    echo "  4) Push image to registry"
    echo "  0) Exit"
    echo ""
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

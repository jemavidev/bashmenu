#!/bin/bash
#
# Docker Clean Script
# Version: 1.0.0
# Description: Intelligent cleanup of unused Docker resources
#
# Usage: ./docker-clean.sh
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
# DISK USAGE
# ============================================================================

show_disk_usage() {
    print_header "Docker Disk Usage"
    print_separator
    docker system df
    print_separator
    
    # Detailed breakdown
    print_info "Detailed Breakdown:"
    echo ""
    
    local containers_count=$(docker ps -a -q | wc -l)
    local running_count=$(docker ps -q | wc -l)
    local stopped_count=$((containers_count - running_count))
    print_info "Containers: $containers_count total ($running_count running, $stopped_count stopped)"
    
    local images_count=$(docker images -q | wc -l)
    local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
    print_info "Images: $images_count total ($dangling_count dangling)"
    
    local volumes_count=$(docker volume ls -q | wc -l)
    print_info "Volumes: $volumes_count total"
    
    local networks_count=$(docker network ls --filter "type=custom" -q | wc -l)
    print_info "Networks: $networks_count custom"
    
    print_separator
}

# ============================================================================
# PREVIEW CLEANUP
# ============================================================================

preview_cleanup() {
    local cleanup_type="$1"
    
    print_info "Preview: What will be removed"
    print_separator
    
    case $cleanup_type in
        containers)
            local count=$(docker ps -a -f "status=exited" -q | wc -l)
            print_info "Stopped containers: $count"
            if [ $count -gt 0 ]; then
                docker ps -a -f "status=exited" --format "  - {{.Names}} ({{.ID}})" | head -n 10
                if [ $count -gt 10 ]; then
                    print_info "  ... and $((count - 10)) more"
                fi
            fi
            ;;
        images)
            local dangling=$(docker images -f "dangling=true" -q | wc -l)
            local unused=$(docker images -q | wc -l)
            print_info "Dangling images: $dangling"
            print_info "Unused images: $unused (images not used by any container)"
            ;;
        volumes)
            local count=$(docker volume ls -f "dangling=true" -q | wc -l)
            print_info "Unused volumes: $count"
            if [ $count -gt 0 ]; then
                docker volume ls -f "dangling=true" --format "  - {{.Name}}" | head -n 10
                if [ $count -gt 10 ]; then
                    print_info "  ... and $((count - 10)) more"
                fi
            fi
            ;;
        networks)
            local count=$(docker network ls --filter "type=custom" -q | wc -l)
            print_info "Custom networks (unused): $count"
            ;;
        cache)
            print_info "Build cache will be cleared"
            ;;
        all)
            preview_cleanup containers
            echo ""
            preview_cleanup images
            echo ""
            preview_cleanup volumes
            echo ""
            preview_cleanup networks
            echo ""
            preview_cleanup cache
            ;;
    esac
    
    print_separator
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

clean_containers() {
    print_info "Cleaning stopped containers..."
    
    local count_before=$(docker ps -a -f "status=exited" -q | wc -l)
    
    if [ $count_before -eq 0 ]; then
        print_info "No stopped containers to remove"
        return 0
    fi
    
    if docker container prune -f &>/dev/null; then
        print_success "Removed $count_before stopped container(s)"
        return 0
    else
        print_error "Failed to remove containers"
        return 1
    fi
}

clean_images() {
    print_info "Cleaning unused images..."
    
    local dangling_before=$(docker images -f "dangling=true" -q | wc -l)
    
    # Remove dangling images first
    if [ $dangling_before -gt 0 ]; then
        if docker image prune -f &>/dev/null; then
            print_success "Removed $dangling_before dangling image(s)"
        fi
    fi
    
    # Ask about unused images
    if confirm "Also remove all unused images (not just dangling)?"; then
        print_warning "This will remove ALL images not used by containers"
        if confirm "Are you sure?"; then
            if docker image prune -a -f &>/dev/null; then
                print_success "Removed unused images"
            else
                print_error "Failed to remove unused images"
            fi
        fi
    fi
    
    return 0
}

clean_volumes() {
    print_info "Cleaning unused volumes..."
    
    local count_before=$(docker volume ls -f "dangling=true" -q | wc -l)
    
    if [ $count_before -eq 0 ]; then
        print_info "No unused volumes to remove"
        return 0
    fi
    
    print_warning "This will permanently delete volume data!"
    if ! confirm "Remove $count_before unused volume(s)?"; then
        print_info "Skipped volume cleanup"
        return 0
    fi
    
    if docker volume prune -f &>/dev/null; then
        print_success "Removed $count_before unused volume(s)"
        return 0
    else
        print_error "Failed to remove volumes"
        return 1
    fi
}

clean_networks() {
    print_info "Cleaning unused networks..."
    
    local count_before=$(docker network ls --filter "type=custom" -q | wc -l)
    
    if [ $count_before -eq 0 ]; then
        print_info "No unused networks to remove"
        return 0
    fi
    
    if docker network prune -f &>/dev/null; then
        print_success "Removed unused network(s)"
        return 0
    else
        print_error "Failed to remove networks"
        return 1
    fi
}

clean_build_cache() {
    print_info "Cleaning build cache..."
    
    if docker builder prune -f &>/dev/null; then
        print_success "Build cache cleared"
        return 0
    else
        print_error "Failed to clear build cache"
        return 1
    fi
}

clean_all() {
    print_header "Complete Docker Cleanup"
    print_separator
    
    print_warning "This will remove:"
    echo "  - All stopped containers"
    echo "  - All dangling images"
    echo "  - All unused volumes"
    echo "  - All unused networks"
    echo "  - All build cache"
    print_separator
    
    if ! confirm "Proceed with complete cleanup?"; then
        print_info "Cancelled"
        return 1
    fi
    
    print_separator
    
    # Get disk usage before
    local space_before=$(docker system df --format "{{.Size}}" | head -n 1 | awk '{print $1}')
    
    # Clean each resource type
    clean_containers
    echo ""
    clean_images
    echo ""
    clean_volumes
    echo ""
    clean_networks
    echo ""
    clean_build_cache
    
    print_separator
    
    # Show space freed
    show_space_freed "$space_before"
    
    return 0
}

# ============================================================================
# SHOW SPACE FREED
# ============================================================================

show_space_freed() {
    local space_before="$1"
    
    print_header "Cleanup Summary"
    print_separator
    
    # Show current disk usage
    docker system df
    
    print_separator
    print_success "Cleanup completed!"
    print_info "Run 'docker system df' to see current disk usage"
    print_separator
}

# ============================================================================
# MAIN MENU
# ============================================================================

show_menu() {
    print_header "Docker Cleanup Tool"
    echo ""
    echo "  1) Show disk usage"
    echo "  2) Clean stopped containers"
    echo "  3) Clean unused images"
    echo "  4) Clean unused volumes"
    echo "  5) Clean unused networks"
    echo "  6) Clean build cache"
    echo "  7) Clean everything (complete cleanup)"
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
    
    # Show initial disk usage
    show_disk_usage
    echo ""
    read -p "Press Enter to continue..."
    
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1)
                show_disk_usage
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                preview_cleanup containers
                if confirm "Proceed with cleanup?"; then
                    print_separator
                    clean_containers
                    print_separator
                    show_disk_usage
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                preview_cleanup images
                if confirm "Proceed with cleanup?"; then
                    print_separator
                    clean_images
                    print_separator
                    show_disk_usage
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                preview_cleanup volumes
                if confirm "Proceed with cleanup?"; then
                    print_separator
                    clean_volumes
                    print_separator
                    show_disk_usage
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                preview_cleanup networks
                if confirm "Proceed with cleanup?"; then
                    print_separator
                    clean_networks
                    print_separator
                    show_disk_usage
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                preview_cleanup cache
                if confirm "Proceed with cleanup?"; then
                    print_separator
                    clean_build_cache
                    print_separator
                    show_disk_usage
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                preview_cleanup all
                clean_all
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

#!/bin/bash
#
# Docker Stop Script
# Version: 1.0.0
# Description: Stop and remove Docker containers safely
#
# Usage: ./docker-stop.sh
#
# This script provides safe container management with:
# - Interactive container selection
# - Graceful shutdown with timeout
# - Force kill for unresponsive containers
# - Optional container removal
# - Volume removal options
# - Safety confirmations for destructive actions
#
# Examples:
#   ./docker-stop.sh  # Interactive mode
#
# Safety features:
#   - Shows container details before stopping
#   - Confirms destructive actions
#   - Graceful stop before force kill
#   - Progress reporting
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

readonly STOP_TIMEOUT=10
readonly EXIT_SUCCESS=0
readonly EXIT_DOCKER_ERROR=1
readonly EXIT_USER_CANCEL=2
readonly EXIT_VALIDATION_ERROR=3

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

confirm_destructive() {
    local action="$1"
    local confirm_word="STOP"
    local response
    
    print_warning "DESTRUCTIVE ACTION: $action"
    print_info "Type '$confirm_word' to confirm, or anything else to cancel"
    read -p "> " response
    
    if [ "$response" = "$confirm_word" ]; then
        return 0
    else
        print_info "Action cancelled"
        return 1
    fi
}

# ============================================================================
# LIST CONTAINERS
# ============================================================================

list_running_containers() {
    local -n containers=$1

    print_info "🔍 Scanning for running containers..."

    local count=0
    while IFS='|' read -r id name image status; do
        containers+=("$id|$name|$image|$status")
        ((count++))
    done < <(docker ps --format "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}")

    if [ $count -eq 0 ]; then
        print_warning "⚠️ No running containers found"
        print_info "💡 Use 'docker ps -a' to see all containers (including stopped)"
        return 1
    fi

    print_success "✅ Found $count running container(s)"

    # Show system info
    local total_containers=$(docker ps -a -q | wc -l)
    local stopped_containers=$((total_containers - count))
    if [ $stopped_containers -gt 0 ]; then
        print_info "📊 System status: $count running, $stopped_containers stopped"
    fi

    return 0
}

display_containers() {
    local -n containers=$1

    print_info "🏃 Running Containers:"
    echo ""
    printf "  %-4s %-15s %-25s %-30s %s\n" "NUM" "ID" "NAME" "IMAGE" "STATUS"
    print_separator

    for i in "${!containers[@]}"; do
        IFS='|' read -r id name image status <<< "${containers[$i]}"

        # Color code status
        local status_display="$status"
        if [[ "$status" =~ ^Up ]]; then
            status_display="${GREEN}$status${NC}"
        elif [[ "$status" =~ ^Exited ]]; then
            status_display="${RED}$status${NC}"
        fi

        printf "  %-4s %-15s %-25s %-30s %b\n" "$((i+1))" "${id:0:12}" "$name" "${image:0:28}" "$status_display"
    done
    echo ""

    # Show additional info
    print_info "💡 Selection tips:"
    echo "  • Enter numbers: '1 3 5' to select specific containers"
    echo "  • Enter 'all' to select all containers"
    echo "  • Enter '0' to cancel"
}

# ============================================================================
# SELECT CONTAINERS
# ============================================================================

select_containers() {
    local -n containers=$1
    local -n selected=$2

    print_info "Select containers to stop:"
    echo "  • Enter numbers separated by spaces (e.g., 1 3 5)"
    echo "  • Enter 'all' to select all containers"
    echo "  • Enter '0' to cancel operation"
    print_info "💡 Tip: You can select multiple containers: '1 2 4'"

    local input
    read -p "Selection: " input

    if [[ "$input" == "0" ]]; then
        print_info "Operation cancelled"
        return 1
    fi

    if [[ "$input" == "all" ]]; then
        for container in "${containers[@]}"; do
            IFS='|' read -r id name _ _ <<< "$container"
            selected+=("$id|$name")
        done
        print_success "Selected all ${#selected[@]} container(s) for stopping"
        return 0
    fi

    # Parse individual selections
    local valid_selections=()
    for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#containers[@]}" ]; then
            IFS='|' read -r id name _ _ <<< "${containers[$((num-1))]}"
            selected+=("$id|$name")
            valid_selections+=("$num")
        else
            print_warning "Invalid selection: $num (valid range: 1-${#containers[@]})"
        fi
    done

    if [ ${#selected[@]} -eq 0 ]; then
        print_error "No valid containers selected"
        return 1
    fi

    print_success "Selected ${#selected[@]} container(s): ${valid_selections[*]}"
    return 0
}

# ============================================================================
# STOP CONTAINER
# ============================================================================

stop_container_gracefully() {
    local container_id="$1"
    local container_name="$2"

    print_info "🛑 Stopping container: $container_name"

    # Show container uptime before stopping
    local uptime=$(docker inspect "$container_id" --format='{{.State.StartedAt}}' 2>/dev/null || echo "unknown")
    if [[ "$uptime" != "unknown" ]]; then
        local start_time=$(date -d "$uptime" +%s 2>/dev/null || echo "0")
        local current_time=$(date +%s)
        local uptime_seconds=$((current_time - start_time))
        local uptime_display=$(printf '%dh:%dm:%ds\n' $((uptime_seconds/3600)) $((uptime_seconds%3600/60)) $((uptime_seconds%60)))
        print_info "Container uptime: $uptime_display"
    fi

    # Try graceful stop first
    print_info "Attempting graceful stop (timeout: ${STOP_TIMEOUT}s)..."
    if timeout $STOP_TIMEOUT docker stop "$container_id" &>/dev/null; then
        print_success "✅ Container stopped gracefully: $container_name"
        return 0
    fi

    # If graceful stop fails, check if container is still running
    local status=$(docker inspect "$container_id" --format='{{.State.Status}}' 2>/dev/null || echo "unknown")

    if [[ "$status" == "running" ]]; then
        print_warning "⚠️ Graceful stop timed out, forcing kill: $container_name"
        print_info "This will immediately terminate the container"
        if docker kill "$container_id" &>/dev/null; then
            print_success "✅ Container killed: $container_name"
            return 0
        else
            print_error "❌ Failed to kill container: $container_name"
            return 1
        fi
    elif [[ "$status" == "exited" ]]; then
        print_success "✅ Container was already stopped: $container_name"
        return 0
    else
        print_error "❓ Container in unknown state: $status"
        return 1
    fi
}

# ============================================================================
# REMOVE CONTAINER
# ============================================================================

remove_container() {
    local container_id="$1"
    local container_name="$2"
    local remove_volumes="$3"
    
    print_info "Removing container: $container_name ($container_id)"
    
    local rm_cmd="docker rm"
    if [[ "$remove_volumes" == "true" ]]; then
        rm_cmd+=" -v"
        print_info "Will also remove associated volumes"
    fi
    rm_cmd+=" $container_id"
    
    if eval "$rm_cmd" &>/dev/null; then
        print_success "Container removed: $container_name"
        return 0
    else
        print_error "Failed to remove container: $container_name"
        return 1
    fi
}

# ============================================================================
# PROCESS CONTAINERS
# ============================================================================

process_containers() {
    local -n selected_containers=$1
    local remove_after_stop="$2"
    local remove_volumes="$3"

    local stopped_count=0
    local removed_count=0
    local failed_count=0

    print_separator
    print_info "🔄 Processing ${#selected_containers[@]} container(s)..."
    print_separator

    local start_time=$(date +%s)

    for i in "${!selected_containers[@]}"; do
        IFS='|' read -r id name <<< "${selected_containers[$i]}"

        echo "[$((i+1))/${#selected_containers[@]}] Processing: $name"

        # Stop container
        if stop_container_gracefully "$id" "$name"; then
            ((stopped_count++))

            # Remove if requested
            if [[ "$remove_after_stop" == "true" ]]; then
                if remove_container "$id" "$name" "$remove_volumes"; then
                    ((removed_count++))
                else
                    ((failed_count++))
                fi
            fi
        else
            ((failed_count++))
        fi

        echo ""
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Summary
    print_separator
    print_header "📊 Operation Summary"
    print_success "✅ Containers stopped: $stopped_count"
    if [[ "$remove_after_stop" == "true" ]]; then
        print_success "🗑️ Containers removed: $removed_count"
        if [[ "$remove_volumes" == "true" ]]; then
            print_info "💾 Associated volumes were also removed"
        fi
    fi
    if [ $failed_count -gt 0 ]; then
        print_error "❌ Failed operations: $failed_count"
    fi
    print_info "⏱️ Total time: ${duration}s"
    print_separator
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
    print_header "Docker Container Stop/Remove"
    print_info "Stop and remove containers safely with interactive selection"
    print_info "This script helps you:"
    print_info "  • View all running containers with details"
    print_info "  • Select specific containers or stop all"
    print_info "  • Choose to remove containers after stopping"
    print_info "  • Optionally remove associated volumes"
    print_info "  • Get confirmation for destructive actions"
    print_separator
    
    # Check Docker
    if ! check_docker; then
        exit $EXIT_DOCKER_ERROR
    fi
    
    # List running containers
    local containers=()
    if ! list_running_containers containers; then
        print_info "No containers to stop"
        exit $EXIT_SUCCESS
    fi
    
    print_separator
    
    # Display containers
    display_containers containers
    
    # Select containers
    local selected=()
    if ! select_containers containers selected; then
        print_info "Operation cancelled"
        exit $EXIT_USER_CANCEL
    fi
    
    print_separator
    
    # Show selected containers
    print_info "Selected containers:"
    for container in "${selected[@]}"; do
        IFS='|' read -r id name <<< "$container"
        echo "  - $name ($id)"
    done
    
    print_separator
    
    # Confirm stop action
    if ! confirm_destructive "Stop ${#selected[@]} container(s)"; then
        exit $EXIT_USER_CANCEL
    fi
    
    # Ask about removal
    local remove_after_stop="false"
    local remove_volumes="false"
    
    if confirm "Remove containers after stopping?"; then
        remove_after_stop="true"
        
        if confirm "Also remove associated volumes?"; then
            remove_volumes="true"
            print_warning "This will permanently delete volume data!"
        fi
    fi
    
    # Process containers
    process_containers selected "$remove_after_stop" "$remove_volumes"
    
    print_success "🎉 Operation completed successfully!"
    print_separator
    print_info "💡 Useful commands for next steps:"
    echo "  • View all containers: docker ps -a"
    echo "  • Clean up resources: docker system prune"
    echo "  • Check volumes:       docker volume ls"
    echo "  • System status:       docker system df"
    echo "  • Start containers:    docker start <container>"
    print_separator
    print_info "🔄 Quick restart commands:"
    echo "  • Restart all stopped: docker start \$(docker ps -aq -f status=exited)"
    echo "  • Restart specific:    docker start <container_name>"
    print_separator

    exit $EXIT_SUCCESS
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"

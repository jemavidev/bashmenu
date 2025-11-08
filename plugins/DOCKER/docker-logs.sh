#!/bin/bash
set -euo pipefail

readonly RED='\033[0;31m'; readonly GREEN='\033[0;32m'; readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'; readonly CYAN='\033[0;36m'; readonly NC='\033[0m'
readonly EXIT_SUCCESS=0; readonly EXIT_DOCKER_ERROR=1; readonly EXIT_USER_CANCEL=2

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

select_container() {
    local containers=()
    while IFS='|' read -r id name status; do
        containers+=("$id|$name|$status")
    done < <(docker ps -a --format "{{.ID}}|{{.Names}}|{{.Status}}")
    
    if [ ${#containers[@]} -eq 0 ]; then
        print_error "No containers found"
        return 1
    fi
    
    print_info "Select container:"
    for i in "${!containers[@]}"; do
        IFS='|' read -r id name status <<< "${containers[$i]}"
        echo "  $((i+1))) $name (${id:0:12}) - $status"
    done
    
    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#containers[@]}" ]; then
        IFS='|' read -r id name _ <<< "${containers[$((selection-1))]}"
        echo "$id|$name"
        return 0
    fi
    print_error "Invalid selection"
    return 1
}

configure_log_options() {
    local -n options=$1
    
    print_info "Configure log options:"
    echo ""
    
    read -p "Number of lines to show (default: 100): " tail_lines
    tail_lines="${tail_lines:-100}"
    options[tail]="--tail $tail_lines"
    
    if confirm "Show timestamps?"; then
        options[timestamps]="--timestamps"
    fi
    
    if confirm "Follow logs in real-time?"; then
        options[follow]="--follow"
        print_warning "Press Ctrl+C to stop following"
    fi
    
    if confirm "Filter by time range?"; then
        read -p "Since (e.g., 2023-01-01, 1h, 30m): " since
        if [[ -n "$since" ]]; then
            options[since]="--since $since"
        fi
        
        if [[ -z "${options[follow]:-}" ]]; then
            read -p "Until (e.g., 2023-01-02, 2h): " until
            if [[ -n "$until" ]]; then
                options[until]="--until $until"
            fi
        fi
    fi
}

show_logs() {
    local container_id="$1"
    local container_name="$2"
    local -n log_opts=$3
    
    local logs_cmd="docker logs"
    
    for opt in "${log_opts[@]}"; do
        logs_cmd+=" $opt"
    done
    
    logs_cmd+=" $container_id"
    
    print_separator
    print_header "Logs: $container_name"
    print_separator
    
    eval "$logs_cmd"
    
    print_separator
}

export_logs() {
    local container_id="$1"
    local container_name="$2"
    
    local export_file="${container_name}_$(date +%Y%m%d_%H%M%S).log"
    
    print_info "Exporting logs to: $export_file"
    
    if docker logs "$container_id" > "$export_file" 2>&1; then
        local size=$(du -h "$export_file" | cut -f1)
        print_success "Logs exported: $export_file ($size)"
        return 0
    else
        print_error "Failed to export logs"
        return 1
    fi
}

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    print_header "Docker Logs Viewer"
    print_separator
    
    check_docker || exit $EXIT_DOCKER_ERROR
    
    local container_info
    container_info=$(select_container) || exit $EXIT_USER_CANCEL
    
    IFS='|' read -r container_id container_name <<< "$container_info"
    
    print_separator
    print_success "Selected: $container_name"
    print_separator
    
    declare -A log_options=()
    configure_log_options log_options
    
    show_logs "$container_id" "$container_name" log_options
    
    if [[ -z "${log_options[follow]:-}" ]]; then
        if confirm "Export logs to file?"; then
            export_logs "$container_id" "$container_name"
        fi
    fi
    
    print_success "Done!"
    exit $EXIT_SUCCESS
}

main "$@"

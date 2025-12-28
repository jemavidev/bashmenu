#!/bin/bash
#
# Docker Logs Script
# Version: 1.0.0
# Description: View and analyze container logs with advanced filtering
#
# Usage: ./docker-logs.sh
#
# This script provides comprehensive log viewing with:
# - Container selection from all containers
# - Time-based filtering (since/until)
# - Real-time log following
# - Line count limits
# - Timestamp display
# - Log export to files
#
# Examples:
#   ./docker-logs.sh  # Interactive mode
#
# Time formats:
#   - Absolute: 2024-01-01, 2024-01-01T10:00:00
#   - Relative: 1h (1 hour ago), 30m (30 minutes ago)
#   - Lines: 100 (last 100 lines)
#
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
        print_info "💡 Create containers first with 'docker run' or use Docker scripts"
        return 1
    fi

    print_info "📋 Select container for log viewing:"
    echo ""
    printf "  %-4s %-15s %-25s %-20s\n" "NUM" "ID" "NAME" "STATUS"
    print_separator

    for i in "${!containers[@]}"; do
        IFS='|' read -r id name status <<< "${containers[$i]}"

        # Color code status for better visibility
        local status_display="$status"
        if [[ "$status" =~ ^Up ]]; then
            status_display="${GREEN}$status${NC}"
        elif [[ "$status" =~ ^Exited ]]; then
            status_display="${RED}$status${NC}"
        elif [[ "$status" =~ ^Created ]]; then
            status_display="${YELLOW}$status${NC}"
        fi

        printf "  %-4s %-15s %-25s %-20s\n" "$((i+1))" "${id:0:12}" "$name" "$status_display"
    done
    echo ""

    print_info "💡 Tips:"
    echo "  • Running containers show real-time logs"
    echo "  • Stopped containers show historical logs"
    echo "  • Use numbers to select specific containers"

    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#containers[@]}" ]; then
        IFS='|' read -r id name _ <<< "${containers[$((selection-1))]}"
        echo "$id|$name"
        return 0
    fi
    print_error "❌ Invalid selection. Please choose a number between 1 and ${#containers[@]}"
    return 1
}

configure_log_options() {
    local -n options=$1

    print_info "🔧 Configure log viewing options:"
    print_info "These options help you find and analyze the right logs for debugging"
    echo ""

    # Line count configuration
    print_info "📏 How many log lines to show?"
    echo "  • More lines = more context but slower display"
    echo "  • Fewer lines = faster but less history"
    read -p "Number of lines (default: 100, max: 1000): " tail_lines
    tail_lines="${tail_lines:-100}"
    if [[ "$tail_lines" =~ ^[0-9]+$ ]] && [ "$tail_lines" -le 1000 ]; then
        options[tail]="--tail $tail_lines"
        print_success "✅ Show last $tail_lines lines"
    else
        print_warning "⚠️ Invalid number, using default: 100"
        options[tail]="--tail 100"
    fi

    # Timestamps
    if confirm "🕒 Show timestamps with each log line?"; then
        options[timestamps]="--timestamps"
        print_success "✅ Timestamps enabled - useful for timing analysis"
    else
        print_info "ℹ️ Timestamps disabled - cleaner output"
    fi

    # Real-time following
    if confirm "🔄 Follow logs in real-time (live streaming)?"; then
        options[follow]="--follow"
        print_success "✅ Real-time following enabled"
        print_info "💡 Press Ctrl+C to stop following and return to menu"
        print_warning "⚠️ Real-time mode will continue until interrupted"
    fi

    # Time-based filtering
    if confirm "⏰ Filter logs by time range?"; then
        print_info "📅 Time filtering helps focus on specific time periods"
        print_info "Time formats supported:"
        echo "  • Absolute dates: 2024-01-01, 2024-01-01T10:00:00"
        echo "  • Relative time: 1h (1 hour ago), 30m (30 minutes ago)"
        echo "  • Complex: 2h30m (2 hours 30 minutes ago)"
        echo "  • Duration: 1h30m (last 1.5 hours)"

        read -p "Since (when to start logs from): " since
        if [[ -n "$since" ]]; then
            options[since]="--since $since"
            print_success "✅ Start logs from: $since"
        fi

        if [[ -z "${options[follow]:-}" ]]; then
            read -p "Until (when to end logs, optional): " until
            if [[ -n "$until" ]]; then
                options[until]="--until $until"
                print_success "✅ End logs at: $until"
            fi
        else
            print_info "ℹ️ 'Until' filter not available when following logs in real-time"
        fi
    fi

    # Summary of options
    print_separator
    print_info "📋 Log viewing configuration summary:"
    echo "  • Lines: $(echo ${options[tail]} | cut -d' ' -f2)"
    if [[ -n "${options[timestamps]:-}" ]]; then echo "  • Timestamps: enabled"; fi
    if [[ -n "${options[follow]:-}" ]]; then echo "  • Real-time: enabled"; fi
    if [[ -n "${options[since]:-}" ]]; then echo "  • Since: $(echo ${options[since]} | cut -d' ' -f2)"; fi
    if [[ -n "${options[until]:-}" ]]; then echo "  • Until: $(echo ${options[until]} | cut -d' ' -f2)"; fi
    print_separator
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
    print_header "📋 Logs: $container_name"
    print_info "Container ID: $container_id"
    if [[ -n "${log_opts[follow]:-}" ]]; then
        print_info "🔄 Real-time mode: Press Ctrl+C to stop following"
    fi
    print_separator

    local start_time=$(date +%s)
    if eval "$logs_cmd"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_separator
        if [[ -n "${log_opts[follow]:-}" ]]; then
            print_success "✅ Log streaming stopped after ${duration}s"
        else
            print_success "✅ Logs displayed successfully (${duration}s)"
        fi
    else
        local exit_code=$?
        print_separator
        print_error "❌ Failed to retrieve logs (exit code: $exit_code)"
        print_info "💡 Possible reasons:"
        echo "  • Container has no logs yet"
        echo "  • Container logging driver issue"
        echo "  • Permission problems"
    fi
}

export_logs() {
    local container_id="$1"
    local container_name="$2"

    # Sanitize container name for filename
    local safe_name=$(echo "$container_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="${safe_name}_${timestamp}.log"

    print_info "💾 Exporting logs to file: $export_file"
    print_info "📁 Location: $(pwd)/$export_file"

    if docker logs "$container_id" > "$export_file" 2>&1; then
        local size=$(du -h "$export_file" | cut -f1)
        local lines=$(wc -l < "$export_file")
        print_success "✅ Logs exported successfully!"
        print_info "📊 File details:"
        echo "  • Filename: $export_file"
        echo "  • Size: $size"
        echo "  • Lines: $lines"
        print_info "💡 You can now:"
        echo "  • Open with: less $export_file"
        echo "  • Search with: grep 'error' $export_file"
        echo "  • Analyze with: cat $export_file | head -50"
        return 0
    else
        print_error "❌ Failed to export logs"
        print_info "💡 Check file permissions and disk space"
        return 1
    fi
}

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    print_header "Docker Logs Viewer"
    print_info "View and analyze container logs with advanced filtering"
    print_info "This script helps you:"
    print_info "  • View logs from running or stopped containers"
    print_info "  • Filter logs by time range and line count"
    print_info "  • Follow logs in real-time"
    print_info "  • Export logs to files for analysis"
    print_info "  • Show timestamps for better debugging"
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
    
    print_success "🎉 Log viewing session completed!"
    print_separator
    print_info "💡 Useful commands for continued log analysis:"
    echo "  • View all logs:     docker logs $container_name"
    echo "  • Follow logs:       docker logs -f $container_name"
    echo "  • Recent logs:       docker logs --tail 50 $container_name"
    echo "  • With timestamps:   docker logs -t $container_name"
    echo "  • Time filtered:     docker logs --since 1h $container_name"
    print_separator
    print_info "🔧 Advanced log analysis:"
    echo "  • Search errors:     docker logs $container_name 2>&1 | grep -i error"
    echo "  • Count errors:      docker logs $container_name 2>&1 | grep -c -i error"
    echo "  • Monitor in background: docker logs -f $container_name > ${container_name}.log &"
    print_separator
    print_info "📊 Related monitoring commands:"
    echo "  • Container stats:   docker stats $container_name"
    echo "  • Container inspect: docker inspect $container_name"
    echo "  • System overview:   docker system df"
    print_separator
    exit $EXIT_SUCCESS
}

main "$@"

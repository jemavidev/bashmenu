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

select_running_container() {
    local containers=()
    while IFS='|' read -r id name image; do
        containers+=("$id|$name|$image")
    done < <(docker ps --format "{{.ID}}|{{.Names}}|{{.Image}}")
    
    if [ ${#containers[@]} -eq 0 ]; then
        print_error "No running containers found"
        return 1
    fi
    
    print_info "Select container:"
    for i in "${!containers[@]}"; do
        IFS='|' read -r id name image <<< "${containers[$i]}"
        echo "  $((i+1))) $name (${id:0:12}) - $image"
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

select_shell() {
    local container_id="$1"
    
    # Try to detect available shells
    for shell in bash sh ash; do
        if docker exec "$container_id" which "$shell" &>/dev/null; then
            echo "$shell"
            return 0
        fi
    done
    
    # Default to sh if nothing found
    echo "sh"
}

configure_exec_options() {
    local -n options=$1
    
    print_info "Execution mode:"
    echo "  1) Interactive shell (recommended)"
    echo "  2) Execute specific command"
    
    read -p "Selection: " mode
    
    case $mode in
        1)
            options[mode]="interactive"
            ;;
        2)
            options[mode]="command"
            read -p "Command to execute: " cmd
            if [[ -z "$cmd" ]]; then
                print_error "Command cannot be empty"
                return 1
            fi
            options[command]="$cmd"
            ;;
        *)
            print_error "Invalid selection"
            return 1
            ;;
    esac
    
    if confirm "Run as specific user?"; then
        read -p "Username: " user
        if [[ -n "$user" ]]; then
            options[user]="--user $user"
        fi
    fi
    
    if confirm "Set working directory?"; then
        read -p "Working directory: " workdir
        if [[ -n "$workdir" ]]; then
            options[workdir]="--workdir $workdir"
        fi
    fi
    
    if confirm "Add environment variables?"; then
        print_info "Enter variables (format: KEY=VALUE), empty line to finish"
        while true; do
            read -p "Env var: " env_var
            if [[ -z "$env_var" ]]; then
                break
            fi
            if [[ "$env_var" =~ ^[A-Za-z_][A-Za-z0-9_]*=.+$ ]]; then
                options[env]+=" -e $env_var"
                print_success "Added: $env_var"
            else
                print_error "Invalid format. Use KEY=VALUE"
            fi
        done
    fi
}

exec_interactive() {
    local container_id="$1"
    local container_name="$2"
    local shell="$3"
    local -n exec_opts=$4
    
    local exec_cmd="docker exec -it"
    
    if [[ -n "${exec_opts[user]:-}" ]]; then
        exec_cmd+=" ${exec_opts[user]}"
    fi
    
    if [[ -n "${exec_opts[workdir]:-}" ]]; then
        exec_cmd+=" ${exec_opts[workdir]}"
    fi
    
    if [[ -n "${exec_opts[env]:-}" ]]; then
        exec_cmd+=" ${exec_opts[env]}"
    fi
    
    exec_cmd+=" $container_id $shell"
    
    print_separator
    print_info "Starting interactive shell in: $container_name"
    print_info "Shell: $shell"
    print_info "Type 'exit' to return"
    print_separator
    
    eval "$exec_cmd"
}

exec_command() {
    local container_id="$1"
    local container_name="$2"
    local -n exec_opts=$3
    
    local exec_cmd="docker exec"
    
    if [[ -n "${exec_opts[user]:-}" ]]; then
        exec_cmd+=" ${exec_opts[user]}"
    fi
    
    if [[ -n "${exec_opts[workdir]:-}" ]]; then
        exec_cmd+=" ${exec_opts[workdir]}"
    fi
    
    if [[ -n "${exec_opts[env]:-}" ]]; then
        exec_cmd+=" ${exec_opts[env]}"
    fi
    
    exec_cmd+=" $container_id ${exec_opts[command]}"
    
    print_separator
    print_info "Executing command in: $container_name"
    print_info "Command: ${exec_opts[command]}"
    print_separator
    
    if eval "$exec_cmd"; then
        print_separator
        print_success "Command executed successfully"
        return 0
    else
        print_separator
        print_error "Command failed"
        return 1
    fi
}

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    print_header "Docker Exec Tool"
    print_info "Execute commands inside containers"
    print_separator
    
    check_docker || exit $EXIT_DOCKER_ERROR
    
    local container_info
    container_info=$(select_running_container) || exit $EXIT_USER_CANCEL
    
    IFS='|' read -r container_id container_name <<< "$container_info"
    
    print_separator
    print_success "Selected: $container_name"
    print_separator
    
    declare -A exec_options=(
        [mode]=""
        [command]=""
        [user]=""
        [workdir]=""
        [env]=""
    )
    
    configure_exec_options exec_options || exit $EXIT_USER_CANCEL
    
    if [[ "${exec_options[mode]}" == "interactive" ]]; then
        local shell
        shell=$(select_shell "$container_id")
        print_info "Detected shell: $shell"
        exec_interactive "$container_id" "$container_name" "$shell" exec_options
    else
        exec_command "$container_id" "$container_name" exec_options
    fi
    
    print_separator
    print_success "Done!"
    exit $EXIT_SUCCESS
}

main "$@"

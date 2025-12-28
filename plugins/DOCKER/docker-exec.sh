#!/bin/bash
#
# Docker Exec Script
# Version: 1.0.0
# Description: Execute commands inside running Docker containers
#
# Usage: ./docker-exec.sh
#
# This script allows you to:
# - Access container shells (bash, sh, ash)
# - Run specific commands inside containers
# - Execute as different users
# - Set working directories
# - Add environment variables
# - Choose from running containers
#
# Examples:
#   ./docker-exec.sh  # Interactive mode
#
# Common use cases:
#   - Debug running containers
#   - Check container configuration
#   - Run maintenance commands
#   - Access databases or services
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

select_running_container() {
    local containers=()
    while IFS='|' read -r id name image status; do
        containers+=("$id|$name|$image|$status")
    done < <(docker ps --format "{{.ID}}|{{.Names}}|{{.Image}}|{{.Status}}")

    if [ ${#containers[@]} -eq 0 ]; then
        print_error "No running containers found"
        print_info "💡 Use 'docker ps -a' to see all containers (including stopped)"
        return 1
    fi

    print_info "🏃 Select running container to access:"
    echo ""
    printf "  %-4s %-15s %-25s %-30s %s\n" "NUM" "ID" "NAME" "IMAGE" "STATUS"
    print_separator

    for i in "${!containers[@]}"; do
        IFS='|' read -r id name image status <<< "${containers[$i]}"
        printf "  %-4s %-15s %-25s %-30s %s\n" "$((i+1))" "${id:0:12}" "$name" "${image:0:28}" "$status"
    done
    echo ""

    print_info "💡 Tips:"
    echo "  • Choose containers running your applications or databases"
    echo "  • Web servers typically have bash/sh available"
    echo "  • Database containers may have limited shells"

    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#containers[@]}" ]; then
        IFS='|' read -r id name _ _ <<< "${containers[$((selection-1))]}"
        echo "$id|$name"
        return 0
    fi
    print_error "Invalid selection. Please choose a number between 1 and ${#containers[@]}"
    return 1
}

select_shell() {
    local container_id="$1"

    print_info "🔍 Detecting available shells in container..."

    # Try to detect available shells in order of preference
    local shells_found=()
    for shell in bash ash sh; do
        if docker exec "$container_id" which "$shell" &>/dev/null; then
            shells_found+=("$shell")
        fi
    done

    if [ ${#shells_found[@]} -eq 0 ]; then
        print_warning "⚠️ No common shells found, defaulting to 'sh'"
        print_info "💡 Some minimal containers may not have shells installed"
        echo "sh"
        return 0
    fi

    # Prefer bash if available, otherwise first found
    local preferred_shell="bash"
    if [[ " ${shells_found[*]} " =~ " $preferred_shell " ]]; then
        print_success "✅ Found preferred shell: $preferred_shell"
        echo "$preferred_shell"
    else
        local selected_shell="${shells_found[0]}"
        print_success "✅ Found shell: $selected_shell"
        if [ ${#shells_found[@]} -gt 1 ]; then
            print_info "💡 Other available shells: ${shells_found[*]}"
        fi
        echo "$selected_shell"
    fi
}

configure_exec_options() {
    local -n options=$1

    print_info "🔧 Choose execution mode:"
    echo "  1) 🖥️ Interactive shell (recommended for exploration)"
    echo "  2) ⚡ Execute specific command (for automation/scripts)"
    print_info "💡 Interactive mode gives you a full shell inside the container"

    read -p "Selection: " mode

    case $mode in
        1)
            options[mode]="interactive"
            print_success "✅ Interactive shell mode selected"
            print_info "🎯 You'll get a shell prompt inside the container"
            ;;
        2)
            options[mode]="command"
            print_info "Enter the command to run inside the container"
            print_info "📋 Common examples:"
            echo "  • ls -la /app"
            echo "  • ps aux"
            echo "  • cat /etc/os-release"
            echo "  • tail -f /var/log/app.log"
            echo "  • mysql -u root -p"
            read -p "Command to execute: " cmd
            if [[ -z "$cmd" ]]; then
                print_error "❌ Command cannot be empty"
                return 1
            fi
            options[command]="$cmd"
            print_success "✅ Command configured: $cmd"
            ;;
        *)
            print_error "❌ Invalid selection. Please choose 1 or 2"
            return 1
            ;;
    esac

    print_separator

    if confirm "👤 Run as specific user?"; then
        print_info "Common container users:"
        echo "  • root (full access)"
        echo "  • www-data (web servers)"
        echo "  • node (Node.js apps)"
        echo "  • app (application user)"
        echo "  • postgres, mysql (database users)"
        read -p "Username (default: container default): " user
        if [[ -n "$user" ]]; then
            options[user]="--user $user"
            print_success "✅ User set to: $user"
        fi
    fi

    if confirm "📁 Set working directory?"; then
        print_info "Container working directory"
        print_info "📂 Common paths:"
        echo "  • /app (application directory)"
        echo "  • /var/www (web root)"
        echo "  • /tmp (temporary files)"
        echo "  • /home/node (Node.js home)"
        read -p "Working directory: " workdir
        if [[ -n "$workdir" ]]; then
            options[workdir]="--workdir $workdir"
            print_success "✅ Working directory: $workdir"
        fi
    fi

    if confirm "🌍 Add environment variables?"; then
        print_info "Add temporary environment variables for this session"
        print_info "📝 Format: KEY=VALUE"
        print_info "💡 Examples:"
        echo "  • DEBUG=true"
        echo "  • NODE_ENV=development"
        echo "  • LOG_LEVEL=info"
        echo "  • DATABASE_URL=postgresql://..."
        print_info "Enter empty line to finish"
        while true; do
            read -p "Environment variable: " env_var
            if [[ -z "$env_var" ]]; then
                break
            fi
            if [[ "$env_var" =~ ^[A-Za-z_][A-Za-z0-9_]*=.+$ ]]; then
                options[env]+=" -e $env_var"
                print_success "✅ Added: $env_var"
            else
                print_error "❌ Invalid format. Use KEY=VALUE (e.g., DEBUG=true)"
                print_info "💡 Variable names: letters, numbers, underscores only"
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
    print_info "🚀 Starting interactive shell session"
    print_info "📦 Container: $container_name"
    print_info "🐚 Shell: $shell"
    if [[ -n "${exec_opts[user]:-}" ]]; then
        print_info "👤 User: $(echo ${exec_opts[user]} | cut -d' ' -f2)"
    fi
    if [[ -n "${exec_opts[workdir]:-}" ]]; then
        print_info "📁 Working dir: $(echo ${exec_opts[workdir]} | cut -d' ' -f2)"
    fi
    print_separator
    print_info "💡 Shell commands:"
    echo "  • Type 'exit' or Ctrl+D to return to host"
    echo "  • Use 'ls', 'pwd', 'ps' to explore"
    echo "  • Check 'env' for environment variables"
    echo "  • Use 'history' if available"
    print_separator

    if eval "$exec_cmd"; then
        print_separator
        print_success "✅ Shell session ended normally"
    else
        local exit_code=$?
        print_separator
        print_warning "⚠️ Shell session ended with code: $exit_code"
    fi
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
    print_info "⚡ Executing command in container: $container_name"
    print_info "📝 Command: ${exec_opts[command]}"
    if [[ -n "${exec_opts[user]:-}" ]]; then
        print_info "👤 User: $(echo ${exec_opts[user]} | cut -d' ' -f2)"
    fi
    if [[ -n "${exec_opts[workdir]:-}" ]]; then
        print_info "📁 Working dir: $(echo ${exec_opts[workdir]} | cut -d' ' -f2)"
    fi
    print_separator
    print_info "🔄 Command output:"
    echo ""

    local start_time=$(date +%s)
    if eval "$exec_cmd"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        echo ""
        print_separator
        print_success "✅ Command executed successfully in ${duration}s"
        return 0
    else
        local exit_code=$?
        echo ""
        print_separator
        print_error "❌ Command failed with exit code: $exit_code"
        print_info "💡 Check the command syntax and container state"
        return 1
    fi
}

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    print_header "Docker Exec Tool"
    print_info "Execute commands inside running containers interactively"
    print_info "This script helps you:"
    print_info "  • Access container shells (bash, sh, ash)"
    print_info "  • Run specific commands inside containers"
    print_info "  • Execute as different users"
    print_info "  • Set working directories and environment variables"
    print_info "  • Choose from running containers"
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
    print_success "🎉 Execution session completed!"
    print_separator
    print_info "💡 Useful commands for continued container management:"
    echo "  • View running containers: docker ps"
    echo "  • View all containers:     docker ps -a"
    echo "  • View container logs:     docker logs $container_name"
    echo "  • Inspect container:       docker inspect $container_name"
    echo "  • Monitor resources:       docker stats $container_name"
    echo "  • Access again:            docker exec -it $container_name /bin/bash"
    print_separator
    print_info "🔧 Quick troubleshooting:"
    echo "  • Check container health:  docker ps -f name=$container_name"
    echo "  • View recent logs:        docker logs --tail 50 $container_name"
    echo "  • Restart container:       docker restart $container_name"
    print_separator
    exit $EXIT_SUCCESS
}

main "$@"

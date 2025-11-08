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

list_networks() {
    print_header "Docker Networks"
    print_separator
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}\t{{.ID}}"
    print_separator
    local count=$(docker network ls -q | wc -l)
    print_info "Total networks: $count"
    print_separator
}

create_network() {
    print_info "Create new network"
    print_separator
    
    read -p "Network name: " net_name
    if [[ -z "$net_name" ]]; then
        print_error "Network name cannot be empty"
        return 1
    fi
    
    if docker network ls --format "{{.Name}}" | grep -q "^${net_name}$"; then
        print_error "Network already exists: $net_name"
        return 1
    fi
    
    print_info "Select driver:"
    echo "  1) bridge (default)"
    echo "  2) overlay"
    echo "  3) macvlan"
    read -p "Selection: " driver_choice
    
    local driver="bridge"
    case $driver_choice in
        2) driver="overlay" ;;
        3) driver="macvlan" ;;
    esac
    
    local create_cmd="docker network create --driver $driver"
    
    if confirm "Configure subnet and gateway?"; then
        read -p "Subnet (e.g., 172.20.0.0/16): " subnet
        if [[ -n "$subnet" ]]; then
            create_cmd+=" --subnet=$subnet"
        fi
        
        read -p "Gateway (e.g., 172.20.0.1): " gateway
        if [[ -n "$gateway" ]]; then
            create_cmd+=" --gateway=$gateway"
        fi
    fi
    
    create_cmd+=" $net_name"
    
    if eval "$create_cmd" &>/dev/null; then
        print_success "Network created: $net_name"
        return 0
    else
        print_error "Failed to create network"
        return 1
    fi
}

remove_network() {
    local networks=()
    while IFS= read -r net; do
        [[ "$net" != "bridge" && "$net" != "host" && "$net" != "none" ]] && networks+=("$net")
    done < <(docker network ls --format "{{.Name}}")
    
    if [ ${#networks[@]} -eq 0 ]; then
        print_warning "No custom networks found"
        return 1
    fi
    
    print_info "Select network to remove:"
    for i in "${!networks[@]}"; do
        echo "  $((i+1))) ${networks[$i]}"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#networks[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local net_name="${networks[$((selection-1))]}"
    
    # Check if network is in use
    local in_use=$(docker network inspect "$net_name" --format='{{range .Containers}}{{.Name}} {{end}}' | wc -w)
    if [ $in_use -gt 0 ]; then
        print_warning "Network is used by $in_use container(s)"
        docker network inspect "$net_name" --format='{{range .Containers}}  - {{.Name}}{{"\n"}}{{end}}'
        print_error "Disconnect containers first"
        return 1
    fi
    
    if ! confirm "Remove network $net_name?"; then
        return 1
    fi
    
    if docker network rm "$net_name" &>/dev/null; then
        print_success "Network removed: $net_name"
        return 0
    else
        print_error "Failed to remove network"
        return 1
    fi
}

connect_container() {
    print_info "Connect container to network"
    print_separator
    
    # Select container
    local containers=()
    while IFS='|' read -r id name; do
        containers+=("$id|$name")
    done < <(docker ps --format "{{.ID}}|{{.Names}}")
    
    if [ ${#containers[@]} -eq 0 ]; then
        print_error "No running containers found"
        return 1
    fi
    
    print_info "Select container:"
    for i in "${!containers[@]}"; do
        IFS='|' read -r _ name <<< "${containers[$i]}"
        echo "  $((i+1))) $name"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#containers[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    IFS='|' read -r container_id container_name <<< "${containers[$((selection-1))]}"
    
    # Select network
    local networks=()
    while IFS= read -r net; do
        networks+=("$net")
    done < <(docker network ls --format "{{.Name}}")
    
    print_info "Select network:"
    for i in "${!networks[@]}"; do
        echo "  $((i+1))) ${networks[$i]}"
    done
    
    read -p "Selection: " net_selection
    if [[ ! "$net_selection" =~ ^[0-9]+$ ]] || [ "$net_selection" -lt 1 ] || [ "$net_selection" -gt "${#networks[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local net_name="${networks[$((net_selection-1))]}"
    
    if docker network connect "$net_name" "$container_id" &>/dev/null; then
        print_success "Container $container_name connected to network $net_name"
        return 0
    else
        print_error "Failed to connect container"
        return 1
    fi
}

disconnect_container() {
    print_info "Disconnect container from network"
    print_separator
    
    # Similar to connect but with disconnect command
    local containers=()
    while IFS='|' read -r id name; do
        containers+=("$id|$name")
    done < <(docker ps --format "{{.ID}}|{{.Names}}")
    
    if [ ${#containers[@]} -eq 0 ]; then
        print_error "No running containers found"
        return 1
    fi
    
    print_info "Select container:"
    for i in "${!containers[@]}"; do
        IFS='|' read -r _ name <<< "${containers[$i]}"
        echo "  $((i+1))) $name"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#containers[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    IFS='|' read -r container_id container_name <<< "${containers[$((selection-1))]}"
    
    local networks=()
    while IFS= read -r net; do
        [[ "$net" != "bridge" && "$net" != "host" && "$net" != "none" ]] && networks+=("$net")
    done < <(docker network ls --format "{{.Name}}")
    
    print_info "Select network:"
    for i in "${!networks[@]}"; do
        echo "  $((i+1))) ${networks[$i]}"
    done
    
    read -p "Selection: " net_selection
    if [[ ! "$net_selection" =~ ^[0-9]+$ ]] || [ "$net_selection" -lt 1 ] || [ "$net_selection" -gt "${#networks[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local net_name="${networks[$((net_selection-1))]}"
    
    if docker network disconnect "$net_name" "$container_id" &>/dev/null; then
        print_success "Container $container_name disconnected from network $net_name"
        return 0
    else
        print_error "Failed to disconnect container"
        return 1
    fi
}

inspect_network() {
    local networks=()
    while IFS= read -r net; do
        networks+=("$net")
    done < <(docker network ls --format "{{.Name}}")
    
    if [ ${#networks[@]} -eq 0 ]; then
        print_warning "No networks found"
        return 1
    fi
    
    print_info "Select network to inspect:"
    for i in "${!networks[@]}"; do
        echo "  $((i+1))) ${networks[$i]}"
    done
    
    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#networks[@]}" ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    local net_name="${networks[$((selection-1))]}"
    
    print_separator
    print_header "Network: $net_name"
    print_separator
    
    docker network inspect "$net_name" --format='
  Name: {{.Name}}
  ID: {{.Id}}
  Driver: {{.Driver}}
  Scope: {{.Scope}}
  Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}
  Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}'
    
    echo ""
    print_info "Connected containers:"
    local containers=$(docker network inspect "$net_name" --format='{{range .Containers}}{{.Name}}{{"\n"}}{{end}}')
    if [[ -z "$containers" ]]; then
        echo "  None"
    else
        echo "$containers" | sed 's/^/  - /'
    fi
    
    print_separator
}

show_menu() {
    print_header "Docker Networks Management"
    echo ""
    echo "  1) List networks"
    echo "  2) Create network"
    echo "  3) Remove network"
    echo "  4) Connect container to network"
    echo "  5) Disconnect container from network"
    echo "  6) Inspect network"
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
            1) list_networks; echo ""; read -p "Press Enter to continue..." ;;
            2) create_network; echo ""; read -p "Press Enter to continue..." ;;
            3) remove_network; echo ""; read -p "Press Enter to continue..." ;;
            4) connect_container; echo ""; read -p "Press Enter to continue..." ;;
            5) disconnect_container; echo ""; read -p "Press Enter to continue..." ;;
            6) inspect_network; echo ""; read -p "Press Enter to continue..." ;;
            0) print_info "Exiting..."; exit $EXIT_SUCCESS ;;
            *) print_error "Invalid option"; sleep 1 ;;
        esac
    done
}

main "$@"

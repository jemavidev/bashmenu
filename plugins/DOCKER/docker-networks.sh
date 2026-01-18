#!/bin/bash
#
# Docker Networks Script
# Version: 1.0.0
# Description: Manage Docker networks (create, remove, connect containers)
#
# Usage: ./docker-networks.sh
#
# This script provides comprehensive Docker network management:
# - List all networks with details
# - Create custom networks with different drivers
# - Remove unused networks safely
# - Connect/disconnect containers to networks
# - Inspect network configurations
#
# Examples:
#   ./docker-networks.sh  # Interactive menu mode
#
# Network types:
#   - bridge: Default network for containers
#   - overlay: For multi-host networking
#   - macvlan: Direct layer 2 connectivity
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

list_networks() {
    print_header "🌐 Docker Networks Overview"
    print_separator

    # Show networks with better formatting
    print_info "📋 All Networks:"
    docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}\t{{.ID}}"

    print_separator

    # Network statistics
    local total_networks=$(docker network ls -q | wc -l)
    local custom_networks=$(docker network ls --filter type=custom -q | wc -l)
    local builtin_networks=$((total_networks - custom_networks))

    print_info "📊 Network Statistics:"
    echo "  🌍 Total networks: $total_networks"
    echo "  🔧 Custom networks: $custom_networks"
    echo "  📦 Built-in networks: $builtin_networks"

    # Show network usage
    echo ""
    print_info "🔗 Network Usage (containers per network):"
    for network in $(docker network ls --format "{{.Name}}"); do
        local container_count=$(docker network inspect "$network" --format='{{len .Containers}}' 2>/dev/null || echo "0")
        local driver=$(docker network ls --filter name="$network" --format "{{.Driver}}")
        printf "  %-20s %-10s %3d containers\n" "$network" "$driver" "$container_count"
    done

    print_separator

    # Show warnings for unused networks
    local unused_networks=()
    while IFS= read -r network; do
        [[ "$network" != "bridge" && "$network" != "host" && "$network" != "none" ]] || continue
        local container_count=$(docker network inspect "$network" --format='{{len .Containers}}' 2>/dev/null || echo "0")
        if [ "$container_count" -eq 0 ]; then
            unused_networks+=("$network")
        fi
    done < <(docker network ls --format "{{.Name}}")

    if [ ${#unused_networks[@]} -gt 0 ]; then
        print_warning "⚠️ Found ${#unused_networks[@]} unused custom networks:"
        for net in "${unused_networks[@]}"; do
            echo "  • $net"
        done
        print_info "💡 Consider removing unused networks to clean up"
    fi

    print_separator
}

create_network() {
    print_info "🌐 Create new Docker network"
    print_info "Networks allow containers to communicate with each other"
    print_separator

    # Network name input with validation
    local net_name=""
    while [[ -z "$net_name" ]]; do
        read -p "Network name: " net_name
        if [[ -z "$net_name" ]]; then
            print_error "❌ Network name cannot be empty"
            continue
        fi

        # Validate network name format
        if [[ ! "$net_name" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]]; then
            print_error "❌ Invalid network name. Use only letters, numbers, hyphens, underscores"
            print_info "💡 Name must start with letter or number"
            net_name=""
            continue
        fi

        # Check if network already exists
        if docker network ls --format "{{.Name}}" | grep -q "^${net_name}$"; then
            print_error "❌ Network already exists: $net_name"
            if ! confirm "Choose a different name?"; then
                return 1
            fi
            net_name=""
            continue
        fi
    done

    print_success "✅ Network name: $net_name"

    # Driver selection with explanations
    print_info "Select network driver:"
    echo "  1) 🌉 bridge (default) - Isolated network for single host"
    echo "     📝 Best for: Most applications, development"
    echo "  2) 🌍 overlay - Multi-host networking with Swarm"
    echo "     📝 Best for: Distributed applications, production clusters"
    echo "  3) 🔌 macvlan - Direct layer 2 connectivity"
    echo "     📝 Best for: Legacy applications, direct hardware access"
    read -p "Selection (1-3): " driver_choice

    local driver="bridge"
    local driver_desc="bridge (single host)"
    case $driver_choice in
        2)
            driver="overlay"
            driver_desc="overlay (multi-host)"
            ;;
        3)
            driver="macvlan"
            driver_desc="macvlan (layer 2)"
            ;;
        1|"")
            driver="bridge"
            driver_desc="bridge (single host)"
            ;;
        *)
            print_warning "⚠️ Invalid selection, using bridge driver"
            ;;
    esac

    print_success "✅ Driver: $driver_desc"

    local create_cmd="docker network create --driver $driver"

    # Advanced configuration
    if confirm "⚙️ Configure advanced network settings?"; then
        print_info "Configure IP address management (IPAM):"

        read -p "Subnet (e.g., 172.20.0.0/16) [optional]: " subnet
        if [[ -n "$subnet" ]]; then
            # Basic subnet validation
            if [[ "$subnet" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
                create_cmd+=" --subnet=$subnet"
                print_success "✅ Subnet: $subnet"
            else
                print_error "❌ Invalid subnet format"
            fi
        fi

        read -p "Gateway (e.g., 172.20.0.1) [optional]: " gateway
        if [[ -n "$gateway" ]]; then
            if [[ "$gateway" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                create_cmd+=" --gateway=$gateway"
                print_success "✅ Gateway: $gateway"
            else
                print_error "❌ Invalid gateway format"
            fi
        fi

        # Additional options based on driver
        case $driver in
            overlay)
                if confirm "Enable encryption for overlay network?"; then
                    create_cmd+=" --opt encrypted=true"
                    print_success "✅ Encryption enabled"
                fi
                ;;
            macvlan)
                read -p "Parent interface (e.g., eth0) [optional]: " parent
                if [[ -n "$parent" ]]; then
                    create_cmd+=" --opt parent=$parent"
                    print_success "✅ Parent interface: $parent"
                fi
                ;;
        esac
    fi

    create_cmd+=" $net_name"

    print_separator
    print_info "🚀 Creating network..."
    print_info "Command: $create_cmd"

    if eval "$create_cmd" &>/dev/null; then
        print_success "✅ Network created successfully!"

        # Show network details
        print_separator
        print_info "📋 Network Details:"
        docker network inspect "$net_name" --format='  Name: {{.Name}}
  ID: {{.Id}}
  Driver: {{.Driver}}
  Scope: {{.Scope}}'

        local subnet_info=$(docker network inspect "$net_name" --format='{{range .IPAM.Config}}Subnet: {{.Subnet}}, Gateway: {{.Gateway}}{{end}}')
        if [[ -n "$subnet_info" ]]; then
            echo "  IPAM: $subnet_info"
        fi

        print_separator
        print_info "💡 Next steps:"
        echo "  • Connect containers: docker network connect $net_name <container>"
        echo "  • Run with network: docker run --network $net_name <image>"
        echo "  • Inspect network: docker network inspect $net_name"

        return 0
    else
        print_error "❌ Failed to create network"
        print_info "💡 Check Docker daemon status and try a different name"
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
    while IFS='|' read -r name driver scope; do
        networks+=("$name|$driver|$scope")
    done < <(docker network ls --format "{{.Name}}|{{.Driver}}|{{.Scope}}")

    if [ ${#networks[@]} -eq 0 ]; then
        print_warning "⚠️ No networks found"
        return 1
    fi

    print_info "🔍 Select network to inspect:"
    printf "  %-4s %-20s %-10s %-8s\n" "NUM" "NAME" "DRIVER" "SCOPE"
    print_separator

    for i in "${!networks[@]}"; do
        IFS='|' read -r name driver scope <<< "${networks[$i]}"
        printf "  %-4s %-20s %-10s %-8s\n" "$((i+1))" "$name" "$driver" "$scope"
    done
    echo ""

    read -p "Selection: " selection
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#networks[@]}" ]; then
        print_error "❌ Invalid selection"
        return 1
    fi

    IFS='|' read -r net_name _ _ <<< "${networks[$((selection-1))]}"

    print_separator
    print_header "🔍 Network Inspection: $net_name"
    print_separator

    # Basic network information
    print_info "📋 Basic Information:"
    local network_info=$(docker network inspect "$net_name" 2>/dev/null)
    if [[ -z "$network_info" ]]; then
        print_error "❌ Could not inspect network: $net_name"
        return 1
    fi

    echo "  🏷️  Name: $(echo "$network_info" | jq -r '.[0].Name' 2>/dev/null || docker network inspect "$net_name" --format='{{.Name}}')"
    echo "  🆔  ID: $(echo "$network_info" | jq -r '.[0].Id[:12]' 2>/dev/null || docker network inspect "$net_name" --format='{{.Id}}' | cut -c1-12)"
    echo "  🔧 Driver: $(echo "$network_info" | jq -r '.[0].Driver' 2>/dev/null || docker network inspect "$net_name" --format='{{.Driver}}')"
    echo "  🌍 Scope: $(echo "$network_info" | jq -r '.[0].Scope' 2>/dev/null || docker network inspect "$net_name" --format='{{.Scope}}')"

    # IPAM Configuration
    local subnet=$(docker network inspect "$net_name" --format='{{range .IPAM.Config}}{{.Subnet}}{{end}}')
    local gateway=$(docker network inspect "$net_name" --format='{{range .IPAM.Config}}{{.Gateway}}{{end}}')

    if [[ -n "$subnet" ]]; then
        echo "  🌐 Subnet: $subnet"
        if [[ -n "$gateway" ]]; then
            echo "  🚪 Gateway: $gateway"
        fi
    fi

    # Connected containers
    echo ""
    print_info "🐳 Connected Containers:"
    local containers=$(docker network inspect "$net_name" --format='{{range .Containers}}{{.Name}} ({{.IPv4Address}}){{"\n"}}{{end}}' 2>/dev/null)
    local container_count=$(docker network inspect "$net_name" --format='{{len .Containers}}' 2>/dev/null || echo "0")

    if [[ "$container_count" -eq 0 ]]; then
        echo "  📭 No containers connected"
    else
        echo "  📦 $container_count container(s) connected:"
        if [[ -n "$containers" ]]; then
            echo "$containers" | sed 's/^/    • /'
        fi
    fi

    # Network-specific information
    local driver=$(docker network inspect "$net_name" --format='{{.Driver}}')
    case $driver in
        overlay)
            echo ""
            print_info "🌐 Overlay Network Details:"
            local attachable=$(docker network inspect "$net_name" --format='{{.Attachable}}' 2>/dev/null)
            local ingress=$(docker network inspect "$net_name" --format='{{.Ingress}}' 2>/dev/null)
            if [[ "$attachable" == "true" ]]; then
                echo "  ✅ Attachable: Yes (can attach standalone containers)"
            fi
            if [[ "$ingress" == "true" ]]; then
                echo "  🚪 Ingress: Yes (load balancing network)"
            fi
            ;;
        macvlan)
            echo ""
            print_info "🔌 Macvlan Network Details:"
            local parent=$(docker network inspect "$net_name" --format='{{.Options.parent}}' 2>/dev/null)
            if [[ -n "$parent" ]]; then
                echo "  🔗 Parent Interface: $parent"
            fi
            ;;
    esac

    # Labels and options
    local labels=$(docker network inspect "$net_name" --format='{{range $k,$v := .Labels}}{{$k}}={{$v}} {{end}}' 2>/dev/null)
    if [[ -n "$labels" ]]; then
        echo ""
        print_info "🏷️ Labels:"
        echo "  $labels"
    fi

    print_separator

    # Usage recommendations
    if [[ "$container_count" -eq 0 ]]; then
        print_info "💡 This network has no connected containers"
        echo "  • Connect containers: docker network connect $net_name <container>"
        echo "  • Run with network: docker run --network $net_name <image>"
    else
        print_info "💡 Network is in use by $container_count container(s)"
        echo "  • View container IPs: docker network inspect $net_name"
        echo "  • Test connectivity: docker exec <container> ping <other_container>"
    fi

    print_separator

    if confirm "📄 View complete JSON configuration?"; then
        print_separator
        print_info "Complete JSON output (press 'q' to exit):"
        docker network inspect "$net_name" | less
        print_separator
    fi
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

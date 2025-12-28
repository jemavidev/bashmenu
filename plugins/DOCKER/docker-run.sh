#!/bin/bash
#
# Docker Run Script
# Version: 1.0.0
# Description: Run Docker containers with interactive configuration
#
# Usage: ./docker-run.sh
#
# This script provides an interactive way to run Docker containers with:
# - Image selection from local images or pull new ones
# - Port mapping configuration
# - Volume mounting
# - Environment variable setup
# - Network configuration
# - Resource limits (CPU/memory)
# - Restart policy configuration
#
# Examples:
#   ./docker-run.sh  # Interactive mode
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

readonly DOCKER_TIMEOUT=30
readonly MAX_RETRIES=3
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

validate_not_empty() {
    [[ -n "$1" ]] || { print_error "$2 cannot be empty"; return 1; }
}

validate_port() {
    local port="$1"
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        print_error "Invalid port: $port"
        return 1
    fi
    return 0
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
# IMAGE SELECTION
# ============================================================================

select_image() {
    local images=()
    
    print_info "Loading available images..."
    
    while IFS= read -r line; do
        images+=("$line")
    done < <(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")
    
    if [ ${#images[@]} -eq 0 ]; then
        print_warning "No images found locally"
        read -p "Enter image name to pull and run: " image_name
        
        if ! validate_not_empty "$image_name" "Image name"; then
            return 1
        fi
        
        print_info "Pulling image: $image_name"
        if docker pull "$image_name"; then
            print_success "Image pulled successfully"
            echo "$image_name"
            return 0
        else
            print_error "Failed to pull image"
            return 1
        fi
    fi
    
    print_info "Select an image:"
    for i in "${!images[@]}"; do
        echo "  $((i+1))) ${images[$i]}"
    done
    echo "  0) Enter custom image name"
    
    local selection
    while true; do
        read -p "Select image: " selection
        
        if [[ "$selection" == "0" ]]; then
            read -p "Enter image name: " image_name
            if validate_not_empty "$image_name" "Image name"; then
                echo "$image_name"
                return 0
            fi
        elif [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#images[@]}" ]; then
            echo "${images[$((selection-1))]}"
            return 0
        else
            print_error "Invalid selection"
        fi
    done
}

# ============================================================================
# CONTAINER CONFIGURATION
# ============================================================================

get_container_name() {
    local name
    while true; do
        read -p "Container name (leave empty for auto-generated): " name
        
        if [[ -z "$name" ]]; then
            print_info "Docker will auto-generate a name"
            echo ""
            return 0
        fi
        
        if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_error "Invalid name. Use only letters, numbers, hyphens, underscores"
            continue
        fi
        
        if docker ps -a --format "{{.Names}}" | grep -q "^${name}$"; then
            print_error "Container name already exists: $name"
            continue
        fi
        
        echo "$name"
        return 0
    done
}

configure_ports() {
    local -n ports=$1

    if ! confirm "Configure port mappings?"; then
        return 0
    fi

    print_info "Add port mappings (format: HOST:CONTAINER)"
    print_info "Examples:"
    echo "  • Web server: 8080:80 (host port 8080 → container port 80)"
    echo "  • API: 3000:3000 (host port 3000 → container port 3000)"
    echo "  • Database: 5432:5432 (PostgreSQL default)"
    print_info "Enter empty line to finish"

    while true; do
        read -p "Port mapping: " mapping

        if [[ -z "$mapping" ]]; then
            break
        fi

        if [[ "$mapping" =~ ^([0-9]+):([0-9]+)$ ]]; then
            local host_port="${BASH_REMATCH[1]}"
            local container_port="${BASH_REMATCH[2]}"

            if validate_port "$host_port" && validate_port "$container_port"; then
                ports+=("-p $mapping")
                print_success "Added: $mapping"
            fi
        else
            print_error "Invalid format. Use HOST:CONTAINER (e.g., 8080:80)"
            print_info "Examples: 8080:80, 3000:3000, 5432:5432"
        fi
    done
}

configure_volumes() {
    local -n volumes=$1

    if ! confirm "Configure volume mounts?"; then
        return 0
    fi

    print_info "Add volume mounts for persistent data"
    print_info "Format: HOST_PATH:CONTAINER_PATH or VOLUME_NAME:CONTAINER_PATH"
    print_info "Examples:"
    echo "  • Host directory: /host/data:/app/data"
    echo "  • Named volume: mydata:/app/data"
    echo "  • Config files: ./config:/etc/app"
    echo "  • Logs: ./logs:/var/log/app"
    print_info "Enter empty line to finish"

    while true; do
        read -p "Volume mount: " mount

        if [[ -z "$mount" ]]; then
            break
        fi

        if [[ "$mount" =~ ^(.+):(.+)$ ]]; then
            volumes+=("-v $mount")
            print_success "Added: $mount"
        else
            print_error "Invalid format. Use SOURCE:DESTINATION"
            print_info "Examples: /host/data:/app/data, myvolume:/app/data"
        fi
    done
}

configure_env_vars() {
    local -n env_vars=$1

    if ! confirm "Configure environment variables?"; then
        return 0
    fi

    print_info "Add environment variables for container configuration"
    print_info "Format: KEY=VALUE"
    print_info "Examples:"
    echo "  • NODE_ENV=production"
    echo "  • DATABASE_URL=postgresql://localhost:5432/mydb"
    echo "  • PORT=8080"
    echo "  • DEBUG=true"
    print_info "Enter empty line to finish"

    while true; do
        read -p "Environment variable: " env_var

        if [[ -z "$env_var" ]]; then
            break
        fi

        if [[ "$env_var" =~ ^[A-Za-z_][A-Za-z0-9_]*=.+$ ]]; then
            env_vars+=("-e $env_var")
            print_success "Added: $env_var"
        else
            print_error "Invalid format. Use KEY=VALUE (e.g., NODE_ENV=production)"
            print_info "Variable names can only contain letters, numbers, and underscores"
        fi
    done
}

configure_network() {
    local -n network=$1

    if ! confirm "Configure custom network?"; then
        network="bridge"
        return 0
    fi

    print_info "Network types:"
    echo "  • bridge: Isolated network with port mapping"
    echo "  • host: Use host network directly (no isolation)"
    echo "  • none: No networking"
    echo "  • custom: User-defined networks for container communication"

    local networks=()
    while IFS= read -r net; do
        networks+=("$net")
    done < <(docker network ls --format "{{.Name}}" | grep -v "^bridge$\|^host$\|^none$")

    if [ ${#networks[@]} -eq 0 ]; then
        print_warning "No custom networks found"
        print_info "Available network types:"
        echo "  1) bridge (default - isolated with port mapping)"
        echo "  2) host (direct host networking - no isolation)"
        echo "  3) none (no networking)"
        echo "  4) Create new custom network"

        local selection
        read -p "Select network type: " selection

        case $selection in
            1|"") network="bridge" ;;
            2) network="host" ;;
            3) network="none" ;;
            4)
                read -p "Enter new network name: " new_net
                if [[ -n "$new_net" ]]; then
                    print_info "Creating network: $new_net"
                    if docker network create "$new_net" &>/dev/null; then
                        print_success "Network created: $new_net"
                        network="$new_net"
                    else
                        print_error "Failed to create network, using bridge"
                        network="bridge"
                    fi
                else
                    print_warning "No name provided, using bridge"
                    network="bridge"
                fi
                ;;
            *)
                print_warning "Invalid selection, using bridge"
                network="bridge"
                ;;
        esac
        return 0
    fi

    print_info "Select network:"
    echo "  1) bridge (default - isolated with port mapping)"
    echo "  2) host (direct host networking)"
    echo "  3) none (no networking)"
    for i in "${!networks[@]}"; do
        echo "  $((i+4))) ${networks[$i]} (custom network)"
    done
    echo "  0) Create new custom network"

    local selection
    read -p "Select network: " selection

    case $selection in
        1|"") network="bridge" ;;
        2) network="host" ;;
        3) network="none" ;;
        0)
            read -p "Enter new network name: " new_net
            if [[ -n "$new_net" ]]; then
                print_info "Creating network: $new_net"
                if docker network create "$new_net" &>/dev/null; then
                    print_success "Network created: $new_net"
                    network="$new_net"
                else
                    print_error "Failed to create network, using bridge"
                    network="bridge"
                fi
            else
                print_warning "No name provided, using bridge"
                network="bridge"
            fi
            ;;
        *)
            if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 4 ] && [ "$selection" -lt $((${#networks[@]}+4)) ]; then
                network="${networks[$((selection-4))]}"
                print_info "Selected custom network: $network"
            else
                print_warning "Invalid selection, using bridge"
                network="bridge"
            fi
            ;;
    esac

    print_success "Network: $network"
}

configure_restart_policy() {
    local -n policy=$1

    print_info "Select restart policy for container resilience:"
    echo "  1) no - Do not restart (manual control only)"
    echo "  2) on-failure - Restart only when container exits with error"
    echo "  3) always - Always restart (aggressive, use carefully)"
    echo "  4) unless-stopped - Always restart unless manually stopped"
    print_info "💡 Recommended: 'unless-stopped' for production services"

    local selection
    read -p "Select policy (default: unless-stopped): " selection

    case $selection in
        1)
            policy="no"
            print_info "Container will not restart automatically"
            ;;
        2)
            policy="on-failure"
            print_info "Container will restart only on failures"
            ;;
        3)
            policy="always"
            print_warning "Container will always restart - ensure proper error handling"
            ;;
        4|"")
            policy="unless-stopped"
            print_info "Container will restart automatically unless manually stopped"
            ;;
        *)
            print_warning "Invalid selection, using unless-stopped"
            policy="unless-stopped"
            ;;
    esac

    print_success "Restart policy: $policy"
}

configure_resources() {
    local -n resources=$1

    if ! confirm "Configure resource limits?"; then
        return 0
    fi

    print_info "Configure CPU and memory limits to prevent resource exhaustion"
    print_info "CPU limits:"
    echo "  • 0.5 = half a CPU core"
    echo "  • 1.0 = one CPU core"
    echo "  • 2.0 = two CPU cores"
    print_info "Memory limits:"
    echo "  • 512m = 512 MB"
    echo "  • 1g = 1 GB"
    echo "  • 2g = 2 GB"

    read -p "CPU limit (e.g., 0.5, 1, 2) [optional]: " cpu_limit
    if [[ -n "$cpu_limit" ]]; then
        if [[ "$cpu_limit" =~ ^[0-9]*\.?[0-9]+$ ]]; then
            resources+=("--cpus=$cpu_limit")
            print_success "CPU limit: $cpu_limit cores"
        else
            print_error "Invalid CPU limit format"
        fi
    fi

    read -p "Memory limit (e.g., 512m, 1g, 2g) [optional]: " mem_limit
    if [[ -n "$mem_limit" ]]; then
        if [[ "$mem_limit" =~ ^[0-9]+[mg]$ ]]; then
            resources+=("--memory=$mem_limit")
            print_success "Memory limit: $mem_limit"
        else
            print_error "Invalid memory format. Use format like 512m, 1g, 2g"
        fi
    fi
}

# ============================================================================
# RUN CONTAINER
# ============================================================================

run_container() {
    local image="$1"
    local container_name="$2"
    local -n ports_ref=$3
    local -n volumes_ref=$4
    local -n env_vars_ref=$5
    local network="$6"
    local restart_policy="$7"
    local -n resources_ref=$8
    
    local run_cmd="docker run -d"
    
    # Add container name
    if [[ -n "$container_name" ]]; then
        run_cmd+=" --name $container_name"
    fi
    
    # Add ports
    for port in "${ports_ref[@]}"; do
        run_cmd+=" $port"
    done
    
    # Add volumes
    for volume in "${volumes_ref[@]}"; do
        run_cmd+=" $volume"
    done
    
    # Add environment variables
    for env_var in "${env_vars_ref[@]}"; do
        run_cmd+=" $env_var"
    done
    
    # Add network
    run_cmd+=" --network=$network"
    
    # Add restart policy
    run_cmd+=" --restart=$restart_policy"
    
    # Add resource limits
    for resource in "${resources_ref[@]}"; do
        run_cmd+=" $resource"
    done
    
    # Add image
    run_cmd+=" $image"
    
    print_separator
    print_info "Run command: $run_cmd"
    print_separator
    
    if ! confirm "Start container?"; then
        print_info "Cancelled"
        return $EXIT_USER_CANCEL
    fi
    
    print_info "Starting container..."
    
    local container_id
    if container_id=$(eval "$run_cmd" 2>&1); then
        print_success "Container started: $container_id"
        echo "$container_id"
        return 0
    else
        print_error "Failed to start container"
        print_error "$container_id"
        return 1
    fi
}

# ============================================================================
# VERIFY CONTAINER
# ============================================================================

verify_container() {
    local container_id="$1"

    sleep 2

    print_info "Verifying container status..."

    local status=$(docker inspect "$container_id" --format='{{.State.Status}}' 2>/dev/null)
    local health=$(docker inspect "$container_id" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")

    if [[ "$status" == "running" ]]; then
        print_success "Container is running"

        # Show container info
        local name=$(docker inspect "$container_id" --format='{{.Name}}' | sed 's/^\///')
        local ip=$(docker inspect "$container_id" --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
        local started=$(docker inspect "$container_id" --format='{{.State.StartedAt}}' 2>/dev/null)
        local image=$(docker inspect "$container_id" --format='{{.Config.Image}}' 2>/dev/null)

        print_separator
        print_info "Container Information:"
        echo "  ID: $container_id"
        echo "  Name: $name"
        echo "  Image: $image"
        echo "  IP: $ip"
        echo "  Status: $status"
        if [[ "$health" != "none" ]]; then
            echo "  Health: $health"
        fi
        echo "  Started: $started"

        # Show port mappings
        local ports=$(docker port "$container_id" 2>/dev/null)
        if [[ -n "$ports" ]]; then
            print_info "Port Mappings:"
            echo "$ports" | sed 's/^/  /'
        fi

        # Show resource usage
        print_info "Resource Usage:"
        local stats=$(docker stats --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" "$container_id" 2>/dev/null | tail -n 1)
        if [[ -n "$stats" ]]; then
            echo "  $stats"
        fi

        return 0
    else
        print_error "Container is not running (status: $status)"
        if [[ "$health" != "none" ]]; then
            print_info "Health status: $health"
        fi
        print_info "Check logs: docker logs $container_id"
        print_info "Check details: docker inspect $container_id"
        return 1
    fi
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    :  # No cleanup needed for run script
}

trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    print_header "Docker Container Runner"
    print_info "Run containers with interactive configuration"
    print_info "This script helps you run Docker containers with:"
    print_info "  • Interactive image selection"
    print_info "  • Port mapping configuration"
    print_info "  • Volume mounting"
    print_info "  • Environment variables"
    print_info "  • Network configuration"
    print_info "  • Resource limits"
    print_separator
    
    # Check Docker
    if ! check_docker; then
        exit $EXIT_DOCKER_ERROR
    fi
    
    # Select image
    local image
    if ! image=$(select_image); then
        exit $EXIT_VALIDATION_ERROR
    fi
    
    print_separator
    print_success "Selected image: $image"
    print_separator
    
    # Get container name
    local container_name
    container_name=$(get_container_name)
    
    # Configure ports
    local ports=()
    configure_ports ports
    
    # Configure volumes
    local volumes=()
    configure_volumes volumes
    
    # Configure environment variables
    local env_vars=()
    configure_env_vars env_vars
    
    # Configure network
    local network
    configure_network network
    
    # Configure restart policy
    local restart_policy
    configure_restart_policy restart_policy
    
    # Configure resources
    local resources=()
    configure_resources resources
    
    # Run container
    local container_id
    if ! container_id=$(run_container "$image" "$container_name" ports volumes env_vars "$network" "$restart_policy" resources); then
        exit $EXIT_DOCKER_ERROR
    fi
    
    print_separator
    
    # Verify container
    if ! verify_container "$container_id"; then
        print_warning "Container started but may have issues"
    fi
    
    print_separator
    print_success "Container deployment completed!"
    print_separator
    print_header "🚀 Deployment Summary"
    print_info "Container ID: $container_id"
    print_info "Container Name: $(docker inspect "$container_id" --format='{{.Name}}' | sed 's/^\///')"
    print_info "Image Used: $image"
    print_separator
    print_info "🔧 Management Commands:"
    echo "  • View logs:        docker logs $container_id"
    echo "  • Follow logs:      docker logs -f $container_id"
    echo "  • Stop container:   docker stop $container_id"
    echo "  • Restart container: docker restart $container_id"
    echo "  • Access shell:     docker exec -it $container_id /bin/bash"
    echo "  • Monitor status:   docker ps -f id=$container_id"
    echo "  • View details:     docker inspect $container_id"
    echo "  • Check stats:      docker stats $container_id"
    print_separator
    print_info "💡 Pro Tips:"
    echo "  • Use 'docker ps' to see all running containers"
    echo "  • Use 'docker stats' to monitor resource usage"
    echo "  • Use 'docker logs --tail 100 -f' to follow recent logs"
    if [[ "$restart_policy" != "no" ]]; then
        echo "  • Container will restart automatically on failure"
    fi
    
    exit $EXIT_SUCCESS
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"

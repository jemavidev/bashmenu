#!/bin/bash
#
# Docker Inspect Script
# Version: 1.0.0
# Description: Inspect containers and images in detail
#
# Usage: ./docker-inspect.sh
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

select_resource_type() {
    print_info "Select resource type:"
    echo "  1) Container"
    echo "  2) Image"
    read -p "Selection: " choice
    case $choice in
        1) echo "container" ;;
        2) echo "image" ;;
        *) print_error "Invalid selection"; return 1 ;;
    esac
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
        IFS='|' read -r id _ _ <<< "${containers[$((selection-1))]}"
        echo "$id"
        return 0
    fi
    print_error "Invalid selection"
    return 1
}

select_image() {
    local images=()
    while IFS='|' read -r id repo tag; do
        images+=("$id|$repo:$tag")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}" | grep -v "<none>")
    
    if [ ${#images[@]} -eq 0 ]; then
        print_error "No images found"
        return 1
    fi
    
    print_info "Select image:"
    for i in "${!images[@]}"; do
        IFS='|' read -r id name <<< "${images[$i]}"
        echo "  $((i+1))) $name (${id:0:12})"
    done
    
    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#images[@]}" ]; then
        IFS='|' read -r id _ <<< "${images[$((selection-1))]}"
        echo "$id"
        return 0
    fi
    print_error "Invalid selection"
    return 1
}

inspect_container() {
    local container_id="$1"
    
    print_header "Container Inspection"
    print_separator
    
    # Basic info
    print_info "Basic Information:"
    docker inspect "$container_id" --format='
  Name: {{.Name}}
  ID: {{.Id}}
  Image: {{.Config.Image}}
  Status: {{.State.Status}}
  Created: {{.Created}}
  Started: {{.State.StartedAt}}' 2>/dev/null
    
    echo ""
    print_info "Network Information:"
    docker inspect "$container_id" --format='{{range $net, $conf := .NetworkSettings.Networks}}
  Network: {{$net}}
  IP Address: {{$conf.IPAddress}}
  Gateway: {{$conf.Gateway}}{{end}}' 2>/dev/null
    
    echo ""
    print_info "Port Mappings:"
    docker port "$container_id" 2>/dev/null || echo "  No port mappings"
    
    echo ""
    print_info "Volumes:"
    docker inspect "$container_id" --format='{{range .Mounts}}
  {{.Type}}: {{.Source}} -> {{.Destination}}{{end}}' 2>/dev/null || echo "  No volumes"
    
    echo ""
    print_info "Environment Variables:"
    docker inspect "$container_id" --format='{{range .Config.Env}}
  {{.}}{{end}}' 2>/dev/null | head -n 10
    
    print_separator
    
    # Show stats
    if [[ "$(docker inspect "$container_id" --format='{{.State.Status}}')" == "running" ]]; then
        if confirm "Show real-time stats?"; then
            print_info "Press Ctrl+C to stop"
            docker stats "$container_id" --no-stream
        fi
        
        if confirm "Show recent logs?"; then
            print_separator
            print_info "Last 20 log lines:"
            docker logs "$container_id" --tail 20
            print_separator
        fi
    fi
    
    if confirm "View complete JSON output?"; then
        docker inspect "$container_id" | less
    fi
}

inspect_image() {
    local image_id="$1"
    
    print_header "Image Inspection"
    print_separator
    
    print_info "Basic Information:"
    docker inspect "$image_id" --format='
  ID: {{.Id}}
  Tags: {{join .RepoTags ", "}}
  Created: {{.Created}}
  Size: {{.Size}} bytes
  Architecture: {{.Architecture}}
  OS: {{.Os}}' 2>/dev/null
    
    echo ""
    print_info "Image Layers:"
    docker history "$image_id" --human=true --format "table {{.CreatedBy}}\t{{.Size}}" | head -n 15
    
    echo ""
    print_info "Exposed Ports:"
    docker inspect "$image_id" --format='{{range $port, $_ := .Config.ExposedPorts}}
  {{$port}}{{end}}' 2>/dev/null || echo "  No exposed ports"
    
    echo ""
    print_info "Environment Variables:"
    docker inspect "$image_id" --format='{{range .Config.Env}}
  {{.}}{{end}}' 2>/dev/null | head -n 10
    
    echo ""
    print_info "Entry Point:"
    docker inspect "$image_id" --format='  {{join .Config.Entrypoint " "}}' 2>/dev/null || echo "  None"
    
    echo ""
    print_info "Command:"
    docker inspect "$image_id" --format='  {{join .Config.Cmd " "}}' 2>/dev/null || echo "  None"
    
    print_separator
    
    if confirm "View complete JSON output?"; then
        docker inspect "$image_id" | less
    fi
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

cleanup() { :; }
trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

main() {
    print_header "Docker Inspect Tool"
    print_separator
    
    check_docker || exit $EXIT_DOCKER_ERROR
    
    local resource_type
    resource_type=$(select_resource_type) || exit $EXIT_USER_CANCEL
    
    print_separator
    
    if [[ "$resource_type" == "container" ]]; then
        local container_id
        container_id=$(select_container) || exit $EXIT_USER_CANCEL
        print_separator
        inspect_container "$container_id"
    else
        local image_id
        image_id=$(select_image) || exit $EXIT_USER_CANCEL
        print_separator
        inspect_image "$image_id"
    fi
    
    print_separator
    print_success "Inspection completed!"
    exit $EXIT_SUCCESS
}

main "$@"

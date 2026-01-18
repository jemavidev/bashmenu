#!/bin/bash
#
# Docker Inspect Script
# Version: 1.0.0
# Description: Inspect containers and images in detail
#
# Usage: ./docker-inspect.sh
#
# This script provides detailed inspection of Docker resources:
# - Container inspection: network, ports, volumes, environment
# - Image inspection: layers, exposed ports, entrypoint, command
# - Real-time container stats
# - Recent logs preview
# - Complete JSON output viewing
#
# Examples:
#   ./docker-inspect.sh  # Interactive mode
#
# Use cases:
#   - Debug container networking issues
#   - Check image configuration
#   - Monitor container performance
#   - Analyze volume mounts
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
    print_info "🔍 Select resource type to inspect:"
    echo "  1) 🐳 Container - running/stopped containers with full details"
    echo "  2) 📦 Image - Docker images with layers and configuration"
    print_info "💡 Containers show runtime info, images show build-time configuration"
    read -p "Selection: " choice
    case $choice in
        1)
            print_success "✅ Inspecting containers"
            echo "container"
            ;;
        2)
            print_success "✅ Inspecting images"
            echo "image"
            ;;
        *)
            print_error "❌ Invalid selection. Please choose 1 or 2"
            return 1
            ;;
    esac
}

select_container() {
    local containers=()
    while IFS='|' read -r id name status image; do
        containers+=("$id|$name|$status|$image")
    done < <(docker ps -a --format "{{.ID}}|{{.Names}}|{{.Status}}|{{.Image}}")

    if [ ${#containers[@]} -eq 0 ]; then
        print_error "❌ No containers found"
        print_info "💡 Create containers first with 'docker run' or use Docker scripts"
        return 1
    fi

    print_info "🐳 Select container to inspect:"
    printf "  %-4s %-15s %-25s %-20s %s\n" "NUM" "ID" "NAME" "STATUS" "IMAGE"
    print_separator

    for i in "${!containers[@]}"; do
        IFS='|' read -r id name status image <<< "${containers[$i]}"

        # Color code status for better visibility
        local status_display="$status"
        if [[ "$status" =~ ^Up ]]; then
            status_display="${GREEN}$status${NC}"
        elif [[ "$status" =~ ^Exited ]]; then
            status_display="${RED}$status${NC}"
        elif [[ "$status" =~ ^Created ]]; then
            status_display="${YELLOW}$status${NC}"
        fi

        printf "  %-4s %-15s %-25s %-20s %s\n" "$((i+1))" "${id:0:12}" "$name" "$status_display" "${image:0:18}"
    done
    echo ""

    print_info "💡 Tips:"
    echo "  • Running containers show real-time network info"
    echo "  • Stopped containers show final state"
    echo "  • Choose containers you're debugging or monitoring"

    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#containers[@]}" ]; then
        IFS='|' read -r id name _ _ <<< "${containers[$((selection-1))]}"
        print_success "✅ Selected container: $name"
        echo "$id"
        return 0
    fi
    print_error "❌ Invalid selection. Please choose a number between 1 and ${#containers[@]}"
    return 1
}

select_image() {
    local images=()
    while IFS='|' read -r id repo tag size; do
        images+=("$id|$repo:$tag|$size")
    done < <(docker images --format "{{.ID}}|{{.Repository}}|{{.Tag}}|{{.Size}}" | grep -v "<none>")

    if [ ${#images[@]} -eq 0 ]; then
        print_error "❌ No tagged images found"
        print_info "💡 Create images first with 'docker build' or pull from registry"
        return 1
    fi

    print_info "📦 Select image to inspect:"
    printf "  %-4s %-15s %-35s %s\n" "NUM" "ID" "IMAGE" "SIZE"
    print_separator

    for i in "${!images[@]}"; do
        IFS='|' read -r id name size <<< "${images[$i]}"
        printf "  %-4s %-15s %-35s %s\n" "$((i+1))" "${id:0:12}" "$name" "$size"
    done
    echo ""

    print_info "💡 Tips:"
    echo "  • Choose images you're debugging or analyzing"
    echo "  • Larger images may have more layers to inspect"
    echo "  • Check image configuration and exposed ports"

    read -p "Selection: " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#images[@]}" ]; then
        IFS='|' read -r id name _ <<< "${images[$((selection-1))]}"
        print_success "✅ Selected image: $name"
        echo "$id"
        return 0
    fi
    print_error "❌ Invalid selection. Please choose a number between 1 and ${#images[@]}"
    return 1
}

inspect_container() {
    local container_id="$1"

    print_header "🔍 Container Inspection: $container_id"
    print_separator

    # Basic info with better formatting
    print_info "📋 Basic Information:"
    local name=$(docker inspect "$container_id" --format='{{.Name}}' 2>/dev/null | sed 's/^\///')
    local image=$(docker inspect "$container_id" --format='{{.Config.Image}}' 2>/dev/null)
    local status=$(docker inspect "$container_id" --format='{{.State.Status}}' 2>/dev/null)
    local created=$(docker inspect "$container_id" --format='{{.Created}}' 2>/dev/null)
    local started=$(docker inspect "$container_id" --format='{{.State.StartedAt}}' 2>/dev/null)

    echo "  🏷️  Name: $name"
    echo "  🆔  ID: ${container_id:0:12}"
    echo "  📦 Image: $image"
    echo "  🔄 Status: $status"
    echo "  📅 Created: $created"
    if [[ "$started" != "0001-01-01T00:00:00Z" ]]; then
        echo "  ▶️  Started: $started"
    fi

    # Health check if available
    local health=$(docker inspect "$container_id" --format='{{.State.Health.Status}}' 2>/dev/null)
    if [[ -n "$health" && "$health" != "<no value>" ]]; then
        echo "  ❤️  Health: $health"
    fi

    echo ""
    print_info "🌐 Network Information:"
    local networks=$(docker inspect "$container_id" --format='{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}: {{$conf.IPAddress}} ({{$conf.Gateway}}){{end}}' 2>/dev/null)
    if [[ -n "$networks" ]]; then
        echo "$networks" | sed 's/^/  /'
    else
        echo "  No network information available"
    fi

    echo ""
    print_info "🔌 Port Mappings:"
    local ports=$(docker port "$container_id" 2>/dev/null)
    if [[ -n "$ports" ]]; then
        echo "$ports" | sed 's/^/  /'
    else
        echo "  No port mappings configured"
    fi

    echo ""
    print_info "💾 Volume Mounts:"
    local volumes=$(docker inspect "$container_id" --format='{{range .Mounts}}{{.Type}}: {{.Source}} → {{.Destination}} ({{.Mode}}){{end}}' 2>/dev/null)
    if [[ -n "$volumes" ]]; then
        echo "$volumes" | sed 's/^/  /'
    else
        echo "  No volumes mounted"
    fi

    echo ""
    print_info "🌍 Environment Variables (first 10):"
    local env_vars=$(docker inspect "$container_id" --format='{{range .Config.Env}}{{.}}{{end}}' 2>/dev/null | head -n 10)
    if [[ -n "$env_vars" ]]; then
        echo "$env_vars" | sed 's/^/  /'
        local total_env=$(docker inspect "$container_id" --format='{{len .Config.Env}}' 2>/dev/null)
        if [[ $total_env -gt 10 ]]; then
            echo "  ... and $((total_env - 10)) more"
        fi
    else
        echo "  No environment variables set"
    fi

    print_separator

    # Show additional options for running containers
    if [[ "$status" == "running" ]]; then
        print_info "⚡ Additional options for running container:"

        if confirm "📊 Show real-time performance stats?"; then
            print_separator
            print_info "Real-time stats (press Ctrl+C to stop):"
            docker stats "$container_id" --no-stream
            print_separator
        fi

        if confirm "📜 Show recent logs (last 20 lines)?"; then
            print_separator
            print_info "Recent logs:"
            docker logs "$container_id" --tail 20 2>&1 | head -n 50
            print_separator
        fi

        if confirm "🔍 Show running processes?"; then
            print_separator
            print_info "Running processes:"
            docker exec "$container_id" ps aux 2>/dev/null || echo "  Unable to get process list"
            print_separator
        fi
    fi

    if confirm "📄 View complete JSON configuration?"; then
        print_separator
        print_info "Complete JSON output (press 'q' to exit):"
        docker inspect "$container_id" | less
        print_separator
    fi
}

inspect_image() {
    local image_id="$1"

    print_header "🔍 Image Inspection: ${image_id:0:12}"
    print_separator

    # Basic information with better formatting
    print_info "📋 Basic Information:"
    local tags=$(docker inspect "$image_id" --format='{{join .RepoTags ", "}}' 2>/dev/null)
    local created=$(docker inspect "$image_id" --format='{{.Created}}' 2>/dev/null)
    local size=$(docker inspect "$image_id" --format='{{.Size}}' 2>/dev/null)
    local size_mb=$((size / 1024 / 1024))
    local arch=$(docker inspect "$image_id" --format='{{.Architecture}}' 2>/dev/null)
    local os=$(docker inspect "$image_id" --format='{{.Os}}' 2>/dev/null)

    echo "  🆔  ID: ${image_id:0:12}"
    echo "  🏷️  Tags: ${tags:-<none>}"
    echo "  📅 Created: $created"
    echo "  💾 Size: ${size_mb}MB ($size bytes)"
    echo "  🖥️  Architecture: $arch"
    echo "  🐧 OS: $os"

    # Layer information
    echo ""
    print_info "🏗️ Build Layers (most recent first):"
    local layer_count=$(docker history "$image_id" --format "{{.ID}}" | wc -l)
    echo "  Total layers: $layer_count"
    echo ""
    docker history "$image_id" --human=true --format "table {{.CreatedBy}}\t{{.Size}}" | head -n 12

    if [ $layer_count -gt 12 ]; then
        echo "  ... and $((layer_count - 12)) more layers"
    fi

    # Configuration details
    echo ""
    print_info "⚙️ Configuration:"

    local exposed_ports=$(docker inspect "$image_id" --format='{{range $port, $_ := .Config.ExposedPorts}}{{$port}} {{end}}' 2>/dev/null)
    echo "  🔌 Exposed Ports: ${exposed_ports:-None}"

    local entrypoint=$(docker inspect "$image_id" --format='{{join .Config.Entrypoint " "}}' 2>/dev/null)
    echo "  🚀 Entry Point: ${entrypoint:-None}"

    local cmd=$(docker inspect "$image_id" --format='{{join .Config.Cmd " "}}' 2>/dev/null)
    echo "  ▶️  Default Command: ${cmd:-None}"

    local workdir=$(docker inspect "$image_id" --format='{{.Config.WorkingDir}}' 2>/dev/null)
    if [[ -n "$workdir" ]]; then
        echo "  📁 Working Directory: $workdir"
    fi

    local user=$(docker inspect "$image_id" --format='{{.Config.User}}' 2>/dev/null)
    if [[ -n "$user" ]]; then
        echo "  👤 Default User: $user"
    fi

    # Environment variables
    echo ""
    print_info "🌍 Environment Variables (first 10):"
    local env_vars=$(docker inspect "$image_id" --format='{{range .Config.Env}}{{.}}{{end}}' 2>/dev/null | head -n 10)
    if [[ -n "$env_vars" ]]; then
        echo "$env_vars" | sed 's/^/  /'
        local total_env=$(docker inspect "$image_id" --format='{{len .Config.Env}}' 2>/dev/null)
        if [[ $total_env -gt 10 ]]; then
            echo "  ... and $((total_env - 10)) more"
        fi
    else
        echo "  No environment variables defined"
    fi

    # Labels
    local labels=$(docker inspect "$image_id" --format='{{range $key, $value := .Config.Labels}}{{$key}}={{$value}} {{end}}' 2>/dev/null)
    if [[ -n "$labels" ]]; then
        echo ""
        print_info "🏷️ Labels:"
        echo "$labels" | sed 's/ /\n  /g' | head -n 5
    fi

    print_separator

    # Additional analysis
    print_info "📊 Image Analysis:"
    if [ $layer_count -gt 30 ]; then
        print_warning "⚠️ High layer count ($layer_count) - consider multi-stage build"
    fi

    if [ $size_mb -gt 500 ]; then
        print_warning "⚠️ Large image size (${size_mb}MB) - consider optimization"
    fi

    if [[ -z "$exposed_ports" ]]; then
        print_info "ℹ️ No exposed ports - image may be for internal use only"
    fi

    print_separator

    if confirm "📄 View complete JSON configuration?"; then
        print_separator
        print_info "Complete JSON output (press 'q' to exit):"
        docker inspect "$image_id" | less
        print_separator
    fi

    if confirm "🔍 Analyze image vulnerabilities?"; then
        print_separator
        print_info "Vulnerability scan (requires Docker Desktop or external scanner):"
        if command -v docker scan &>/dev/null; then
            docker scan "$image_id" 2>/dev/null || print_warning "Scan failed - may require Docker Desktop"
        else
            print_info "💡 Install Docker Desktop for built-in vulnerability scanning"
            print_info "💡 Or use external tools like Trivy, Clair, or Anchore"
        fi
        print_separator
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

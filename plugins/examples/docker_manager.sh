#!/bin/bash
# Docker Manager Script - Manage Docker containers and images
# Usage: ./docker_manager.sh [build|ps|logs|restart|images]

# =============================================================================
# Configuration
# =============================================================================

# Default docker-compose file path
DEFAULT_COMPOSE_FILE="docker-compose.yml"

# =============================================================================
# Functions
# =============================================================================

show_usage() {
    echo "Docker Manager Script"
    echo ""
    echo "Usage: $0 [operation] [options]"
    echo ""
    echo "Operations:"
    echo "  build     - Build Docker containers"
    echo "  ps        - Show running containers"
    echo "  logs      - Show recent container logs"
    echo "  restart   - Restart containers"
    echo "  images    - List Docker images"
    echo "  stop      - Stop all containers"
    echo "  start     - Start containers"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 ps"
    echo "  $0 logs"
    echo ""
}

check_docker_installed() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Error: docker is not installed"
        echo "Install with: curl -fsSL https://get.docker.com | sh"
        exit 1
    fi
    
    # Check if docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        echo "Error: Docker daemon is not running"
        echo "Start with: sudo systemctl start docker"
        exit 1
    fi
}

check_docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        return 0
    elif docker compose version >/dev/null 2>&1; then
        return 0
    else
        echo "Warning: docker-compose not found"
        echo "Some operations may not work"
        return 1
    fi
}

docker_build() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Build - Building containers"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    if check_docker_compose; then
        if [[ -f "$DEFAULT_COMPOSE_FILE" ]]; then
            echo "Using docker-compose file: $DEFAULT_COMPOSE_FILE"
            echo ""
            
            if command -v docker-compose >/dev/null 2>&1; then
                docker-compose build
            else
                docker compose build
            fi
        else
            echo "Error: docker-compose.yml not found in current directory"
            exit 1
        fi
    else
        echo "Building all Docker images..."
        docker build -t myapp:latest .
    fi
    
    echo ""
    echo "✓ Build completed"
}

docker_ps() {
    echo "═══════════════════════════════════════════════"
    echo "Docker PS - Running containers"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    echo "Running containers:"
    echo ""
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "All containers (including stopped):"
    echo ""
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
}

docker_logs() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Logs - Recent container logs"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    if check_docker_compose && [[ -f "$DEFAULT_COMPOSE_FILE" ]]; then
        echo "Showing logs from docker-compose services:"
        echo ""
        
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose logs --tail=50
        else
            docker compose logs --tail=50
        fi
    else
        echo "Showing logs from all running containers:"
        echo ""
        
        # Get all running container IDs
        local containers=$(docker ps -q)
        
        if [[ -z "$containers" ]]; then
            echo "No running containers found"
            exit 0
        fi
        
        for container in $containers; do
            local name=$(docker inspect --format='{{.Name}}' "$container" | sed 's/\///')
            echo "─────────────────────────────────────────────"
            echo "Container: $name ($container)"
            echo "─────────────────────────────────────────────"
            docker logs --tail=20 "$container" 2>&1
            echo ""
        done
    fi
}

docker_restart() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Restart - Restarting containers"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    if check_docker_compose && [[ -f "$DEFAULT_COMPOSE_FILE" ]]; then
        echo "Restarting docker-compose services..."
        echo ""
        
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose restart
        else
            docker compose restart
        fi
    else
        echo "Restarting all running containers..."
        echo ""
        
        local containers=$(docker ps -q)
        
        if [[ -z "$containers" ]]; then
            echo "No running containers found"
            exit 0
        fi
        
        docker restart $containers
    fi
    
    echo ""
    echo "✓ Restart completed"
}

docker_images() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Images - Available images"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    echo "Local Docker images:"
    echo ""
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    echo ""
    echo "Disk usage:"
    docker system df
}

docker_stop() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Stop - Stopping containers"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    if check_docker_compose && [[ -f "$DEFAULT_COMPOSE_FILE" ]]; then
        echo "Stopping docker-compose services..."
        echo ""
        
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose stop
        else
            docker compose stop
        fi
    else
        echo "Stopping all running containers..."
        echo ""
        
        local containers=$(docker ps -q)
        
        if [[ -z "$containers" ]]; then
            echo "No running containers found"
            exit 0
        fi
        
        docker stop $containers
    fi
    
    echo ""
    echo "✓ Stop completed"
}

docker_start() {
    echo "═══════════════════════════════════════════════"
    echo "Docker Start - Starting containers"
    echo "═══════════════════════════════════════════════"
    echo ""
    
    if check_docker_compose && [[ -f "$DEFAULT_COMPOSE_FILE" ]]; then
        echo "Starting docker-compose services..."
        echo ""
        
        if command -v docker-compose >/dev/null 2>&1; then
            docker-compose start
        else
            docker compose start
        fi
    else
        echo "Starting all stopped containers..."
        echo ""
        
        local containers=$(docker ps -a -q)
        
        if [[ -z "$containers" ]]; then
            echo "No containers found"
            exit 0
        fi
        
        docker start $containers
    fi
    
    echo ""
    echo "✓ Start completed"
}

# =============================================================================
# Main
# =============================================================================

main() {
    local operation="${1:-ps}"
    
    # Check if docker is installed
    check_docker_installed
    
    # Execute operation
    case "$operation" in
        build)
            docker_build
            ;;
        ps)
            docker_ps
            ;;
        logs)
            docker_logs
            ;;
        restart)
            docker_restart
            ;;
        images)
            docker_images
            ;;
        stop)
            docker_stop
            ;;
        start)
            docker_start
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown operation: $operation"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

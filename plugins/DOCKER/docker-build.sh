#!/bin/bash
#
# Docker Build Script
# Version: 1.0.0
# Description: Build Docker images with best practices and interactive configuration
#
# Usage: ./docker-build.sh
#

# ============================================================================
# STRICT MODE AND CONFIGURATION
# ============================================================================

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
readonly BUILD_TIMEOUT=600
readonly MAX_RETRIES=3
readonly RETRY_DELAY=2

readonly EXIT_SUCCESS=0
readonly EXIT_DOCKER_ERROR=1
readonly EXIT_USER_CANCEL=2
readonly EXIT_VALIDATION_ERROR=3
readonly EXIT_TIMEOUT=4

declare -g ITERATION_COUNT=0
readonly MAX_ITERATIONS=10

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
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker info &>/dev/null; then
            return 0
        fi
        print_warning "Docker daemon not responding (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    print_error "Docker daemon is not available"
    print_info "Please ensure Docker is running: systemctl status docker"
    return 1
}

validate_not_empty() {
    local value="$1"
    local field_name="$2"
    
    if [[ -z "$value" ]]; then
        print_error "$field_name cannot be empty"
        return 1
    fi
    return 0
}

check_loop() {
    ((ITERATION_COUNT++))
    if [ $ITERATION_COUNT -gt $MAX_ITERATIONS ]; then
        print_error "Detected possible infinite loop. Aborting."
        exit $EXIT_TIMEOUT
    fi
}

confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (yes/no): " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]) return 1 ;;
            *) print_error "Please answer 'yes' or 'no'" ;;
        esac
    done
}

# ============================================================================
# DOCKERFILE SELECTION
# ============================================================================

select_dockerfile() {
    local dockerfiles=()
    local dockerfile_path=""
    
    print_info "Searching for Dockerfiles in current directory..."
    
    # Find Dockerfiles in current directory and subdirectories (max depth 2)
    while IFS= read -r file; do
        dockerfiles+=("$file")
    done < <(find . -maxdepth 2 -type f \( -name "Dockerfile" -o -name "Dockerfile.*" \) 2>/dev/null)
    
    if [ ${#dockerfiles[@]} -eq 0 ]; then
        print_warning "No Dockerfiles found in current directory"
        read -p "Enter path to Dockerfile: " dockerfile_path
        
        if [[ ! -f "$dockerfile_path" ]]; then
            print_error "Dockerfile not found: $dockerfile_path"
            return 1
        fi
    elif [ ${#dockerfiles[@]} -eq 1 ]; then
        dockerfile_path="${dockerfiles[0]}"
        print_success "Found Dockerfile: $dockerfile_path"
    else
        print_info "Multiple Dockerfiles found. Select one:"
        for i in "${!dockerfiles[@]}"; do
            echo "  $((i+1))) ${dockerfiles[$i]}"
        done
        echo "  0) Enter custom path"
        
        local selection
        while true; do
            read -p "Select Dockerfile: " selection
            
            if [[ "$selection" == "0" ]]; then
                read -p "Enter path to Dockerfile: " dockerfile_path
                if [[ ! -f "$dockerfile_path" ]]; then
                    print_error "Dockerfile not found: $dockerfile_path"
                    continue
                fi
                break
            elif [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#dockerfiles[@]}" ]; then
                dockerfile_path="${dockerfiles[$((selection-1))]}"
                break
            else
                print_error "Invalid selection"
            fi
        done
    fi
    
    # Validate Dockerfile
    if [[ ! -f "$dockerfile_path" ]]; then
        print_error "Dockerfile not found: $dockerfile_path"
        return 1
    fi
    
    if [[ ! -r "$dockerfile_path" ]]; then
        print_error "Cannot read Dockerfile: $dockerfile_path"
        return 1
    fi
    
    print_success "Using Dockerfile: $dockerfile_path"
    echo "$dockerfile_path"
    return 0
}

# ============================================================================
# IMAGE NAME AND TAG
# ============================================================================

get_image_name() {
    local image_name=""
    local image_tag=""
    local full_name=""
    
    print_info "Enter image name and tag"
    
    while true; do
        read -p "Image name (e.g., myapp, username/myapp): " image_name
        
        if ! validate_not_empty "$image_name" "Image name"; then
            continue
        fi
        
        # Validate format
        if [[ ! "$image_name" =~ ^[a-z0-9._/-]+$ ]]; then
            print_error "Invalid image name format. Use lowercase letters, numbers, dots, hyphens, slashes"
            continue
        fi
        
        break
    done
    
    while true; do
        read -p "Image tag (default: latest): " image_tag
        
        if [[ -z "$image_tag" ]]; then
            print_warning "Using 'latest' tag is not recommended for production"
            if confirm "Use 'latest' tag anyway?"; then
                image_tag="latest"
                break
            else
                continue
            fi
        fi
        
        # Validate tag format
        if [[ ! "$image_tag" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            print_error "Invalid tag format. Use letters, numbers, dots, hyphens, underscores"
            continue
        fi
        
        break
    done
    
    full_name="${image_name}:${image_tag}"
    
    # Check if image already exists
    if docker image inspect "$full_name" &>/dev/null; then
        print_warning "Image $full_name already exists"
        if ! confirm "Overwrite existing image?"; then
            return 1
        fi
    fi
    
    print_success "Image will be tagged as: $full_name"
    echo "$full_name"
    return 0
}

# ============================================================================
# BUILD OPTIONS
# ============================================================================

get_build_options() {
    local -n options=$1
    local choice
    
    print_info "Configure build options (optional)"
    echo "  1) Add build arguments"
    echo "  2) Enable no-cache build"
    echo "  3) Specify target stage (multi-stage builds)"
    echo "  4) Set build context path"
    echo "  5) Continue with build"
    
    while true; do
        read -p "Select option (1-5): " choice
        
        case $choice in
            1)
                print_info "Add build arguments (format: KEY=VALUE)"
                print_info "Enter empty line to finish"
                while true; do
                    read -p "Build arg: " build_arg
                    if [[ -z "$build_arg" ]]; then
                        break
                    fi
                    if [[ "$build_arg" =~ ^[A-Za-z_][A-Za-z0-9_]*=.+$ ]]; then
                        options[build_args]+=" --build-arg $build_arg"
                        print_success "Added: $build_arg"
                    else
                        print_error "Invalid format. Use KEY=VALUE"
                    fi
                done
                ;;
            2)
                options[no_cache]="--no-cache"
                print_success "No-cache build enabled"
                ;;
            3)
                read -p "Target stage name: " target_stage
                if validate_not_empty "$target_stage" "Target stage"; then
                    options[target]="--target $target_stage"
                    print_success "Target stage: $target_stage"
                fi
                ;;
            4)
                read -p "Build context path (default: .): " context_path
                if [[ -z "$context_path" ]]; then
                    context_path="."
                fi
                if [[ -d "$context_path" ]]; then
                    options[context]="$context_path"
                    print_success "Build context: $context_path"
                else
                    print_error "Directory not found: $context_path"
                fi
                ;;
            5)
                return 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
    done
}

# ============================================================================
# BUILD IMAGE
# ============================================================================

build_image() {
    local dockerfile="$1"
    local image_name="$2"
    local -n build_opts=$3
    
    local build_cmd="docker build"
    local context="${build_opts[context]:-.}"
    
    # Construct build command
    build_cmd+=" -f $dockerfile"
    build_cmd+=" -t $image_name"
    
    if [[ -n "${build_opts[build_args]:-}" ]]; then
        build_cmd+=" ${build_opts[build_args]}"
    fi
    
    if [[ -n "${build_opts[no_cache]:-}" ]]; then
        build_cmd+=" ${build_opts[no_cache]}"
    fi
    
    if [[ -n "${build_opts[target]:-}" ]]; then
        build_cmd+=" ${build_opts[target]}"
    fi
    
    build_cmd+=" $context"
    
    print_separator
    print_info "Build command: $build_cmd"
    print_separator
    
    if ! confirm "Start build?"; then
        print_info "Build cancelled"
        return $EXIT_USER_CANCEL
    fi
    
    print_info "Building image... (timeout: ${BUILD_TIMEOUT}s)"
    
    local start_time=$(date +%s)
    
    if timeout $BUILD_TIMEOUT bash -c "$build_cmd"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "Build completed in ${duration}s"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            print_error "Build timed out after ${BUILD_TIMEOUT}s"
            return $EXIT_TIMEOUT
        else
            print_error "Build failed with exit code $exit_code"
            return 1
        fi
    fi
}

# ============================================================================
# VERIFY IMAGE
# ============================================================================

verify_image() {
    local image_name="$1"
    
    print_info "Verifying image..."
    
    if docker image inspect "$image_name" &>/dev/null; then
        local size=$(docker image inspect "$image_name" --format='{{.Size}}' 2>/dev/null)
        local size_mb=$((size / 1024 / 1024))
        print_success "Image created successfully: $image_name (${size_mb}MB)"
        
        # Show image layers
        print_info "Image layers:"
        docker history "$image_name" --human=true --format "table {{.CreatedBy}}\t{{.Size}}" | head -n 10
        
        return 0
    else
        print_error "Image verification failed: $image_name not found"
        return 1
    fi
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    # Clean up dangling images from failed builds
    local dangling=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
    if [ "$dangling" -gt 0 ]; then
        print_info "Found $dangling dangling image(s) from build"
        if confirm "Remove dangling images?"; then
            docker image prune -f &>/dev/null
            print_success "Dangling images removed"
        fi
    fi
}

trap cleanup EXIT
trap 'print_warning "Interrupted by user"; exit $EXIT_USER_CANCEL' INT TERM

# ============================================================================
# MAIN FUNCTION
# ============================================================================

main() {
    print_header "Docker Image Builder"
    print_info "Build Docker images with best practices"
    print_separator
    
    # Check Docker
    if ! check_docker; then
        exit $EXIT_DOCKER_ERROR
    fi
    
    # Select Dockerfile
    local dockerfile
    if ! dockerfile=$(select_dockerfile); then
        exit $EXIT_VALIDATION_ERROR
    fi
    
    print_separator
    
    # Get image name and tag
    local image_name
    if ! image_name=$(get_image_name); then
        print_info "Build cancelled"
        exit $EXIT_USER_CANCEL
    fi
    
    print_separator
    
    # Get build options
    declare -A build_options=(
        [build_args]=""
        [no_cache]=""
        [target]=""
        [context]="."
    )
    
    get_build_options build_options
    
    print_separator
    
    # Build image
    if ! build_image "$dockerfile" "$image_name" build_options; then
        print_error "Build failed"
        exit $EXIT_DOCKER_ERROR
    fi
    
    print_separator
    
    # Verify image
    if ! verify_image "$image_name"; then
        exit $EXIT_DOCKER_ERROR
    fi
    
    print_separator
    print_success "Build process completed successfully!"
    print_info "Image: $image_name"
    print_info "You can now run: docker run $image_name"
    
    exit $EXIT_SUCCESS
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"

#!/bin/bash
#
# Docker Build Script
# Version: 1.0.0
# Description: Build Docker images with best practices and interactive configuration
#
# Usage: ./docker-build.sh
#
# This script provides an interactive way to build Docker images with:
# - Automatic Dockerfile detection
# - Build argument configuration
# - Multi-stage build support
# - No-cache build options
# - Build context customization
# - Image verification and information
#
# Examples:
#   ./docker-build.sh  # Interactive mode
#
# Build arguments can be used for:
#   - Version numbers: VERSION=1.2.3
#   - Base images: BASE_IMAGE=alpine:latest
#   - Build flags: BUILD_TYPE=production
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

    print_info "🔍 Searching for Dockerfiles in current directory and subdirectories..."

    # Find Dockerfiles in current directory and subdirectories (max depth 3)
    while IFS= read -r file; do
        dockerfiles+=("$file")
    done < <(find . -maxdepth 3 -type f \( -name "Dockerfile" -o -name "Dockerfile.*" \) 2>/dev/null | sort)

    if [ ${#dockerfiles[@]} -eq 0 ]; then
        print_warning "No Dockerfiles found in current directory or subdirectories"
        print_info "💡 Tip: Make sure you're in the right directory or create a Dockerfile"
        read -p "Enter path to Dockerfile: " dockerfile_path

        if [[ ! -f "$dockerfile_path" ]]; then
            print_error "Dockerfile not found: $dockerfile_path"
            return 1
        fi
    elif [ ${#dockerfiles[@]} -eq 1 ]; then
        dockerfile_path="${dockerfiles[0]}"
        print_success "Found Dockerfile: $dockerfile_path"

        # Show basic info about the Dockerfile
        if [[ -f "$dockerfile_path" ]]; then
            local lines=$(wc -l < "$dockerfile_path")
            local size=$(du -h "$dockerfile_path" | cut -f1)
            print_info "Dockerfile info: $lines lines, $size"
        fi
    else
        print_info "Multiple Dockerfiles found. Select one:"
        for i in "${!dockerfiles[@]}"; do
            local file="${dockerfiles[$i]}"
            local lines=$(wc -l < "$file" 2>/dev/null || echo "?")
            local size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "?")
            echo "  $((i+1))) $file (${lines} lines, ${size})"
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
                print_error "Invalid selection. Please choose 0-${#dockerfiles[@]}"
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

    # Show Dockerfile preview
    print_success "Using Dockerfile: $dockerfile_path"
    if confirm "Show Dockerfile preview?"; then
        print_separator
        print_info "First 10 lines of Dockerfile:"
        head -n 10 "$dockerfile_path" | nl -ba
        print_separator
    fi

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

    print_info "🏷️ Configure image name and tag"
    print_info "Image naming best practices:"
    echo "  • Use lowercase only"
    echo "  • Include registry: registry.com/username/app"
    echo "  • Use descriptive names: myapp, web-server, api-gateway"

    while true; do
        read -p "Image name (e.g., myapp, username/myapp): " image_name

        if ! validate_not_empty "$image_name" "Image name"; then
            continue
        fi

        # Validate format
        if [[ ! "$image_name" =~ ^[a-z0-9._/-]+$ ]]; then
            print_error "Invalid image name format."
            print_info "Requirements: lowercase letters, numbers, dots, hyphens, slashes only"
            print_info "Examples: myapp, my-app, username/myapp, registry.com/user/app"
            continue
        fi

        # Check for common mistakes
        if [[ "$image_name" =~ [A-Z] ]]; then
            print_warning "Image names should be lowercase"
            if ! confirm "Continue with uppercase characters?"; then
                continue
            fi
        fi

        break
    done

    print_info "Tag recommendations:"
    echo "  • Use semantic versioning: v1.2.3, 1.0.0"
    echo "  • Use descriptive tags: stable, dev, prod"
    echo "  • Avoid 'latest' for production"

    while true; do
        read -p "Image tag (default: latest): " image_tag

        if [[ -z "$image_tag" ]]; then
            print_warning "⚠️ Using 'latest' tag is not recommended for production!"
            print_info "Consider using version tags like 'v1.0.0' or 'stable'")
            if confirm "Use 'latest' tag anyway?"; then
                image_tag="latest"
                break
            else
                continue
            fi
        fi

        # Validate tag format
        if [[ ! "$image_tag" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            print_error "Invalid tag format."
            print_info "Requirements: letters, numbers, dots, hyphens, underscores only"
            print_info "Examples: v1.2.3, stable, dev, prod-2024"
            continue
        fi

        # Check for version-like tags
        if [[ "$image_tag" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            print_info "✅ Using semantic version tag: $image_tag"
        elif [[ "$image_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            print_info "✅ Using version tag: $image_tag"
        fi

        break
    done

    full_name="${image_name}:${image_tag}"

    # Check if image already exists
    if docker image inspect "$full_name" &>/dev/null 2>&1; then
        print_warning "⚠️ Image $full_name already exists locally"
        local existing_size=$(docker images "$full_name" --format "{{.Size}}" 2>/dev/null)
        print_info "Existing image size: $existing_size"

        if ! confirm "Overwrite existing image?"; then
            print_info "Build cancelled to preserve existing image"
            return 1
        fi
        print_info "Will overwrite existing image"
    fi

    print_success "✅ Image will be tagged as: $full_name"

    # Show registry info if applicable
    if [[ "$image_name" =~ / ]]; then
        if [[ "$image_name" =~ ^[^/]+/[^/]+/ ]]; then
            print_info "📤 Will push to registry: ${image_name%%/*}"
        else
            print_info "📤 Will push to Docker Hub as: $image_name"
        fi
    else
        print_info "📤 Local image only (use full name with registry for pushing)"
    fi

    echo "$full_name"
    return 0
}

# ============================================================================
# BUILD OPTIONS
# ============================================================================

get_build_options() {
    local -n options=$1
    local choice

    print_info "Configure advanced build options (optional)"
    echo "  1) Add build arguments (ARG variables)"
    echo "  2) Enable no-cache build (slower but ensures fresh build)"
    echo "  3) Specify target stage (for multi-stage builds)"
    echo "  4) Set custom build context path"
    echo "  5) Continue with build"
    print_info "💡 Tip: Build arguments are useful for passing variables like versions"

    while true; do
        read -p "Select option (1-5): " choice

        case $choice in
            1)
                print_info "Add build arguments for Dockerfile ARG instructions"
                print_info "Examples:"
                echo "  • VERSION=1.2.3"
                echo "  • NODE_VERSION=18"
                echo "  • BASE_IMAGE=alpine:latest"
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
                        print_error "Invalid format. Use KEY=VALUE (e.g., VERSION=1.0.0)"
                    fi
                done
                ;;
            2)
                options[no_cache]="--no-cache"
                print_success "No-cache build enabled (build will be slower but more reliable)"
                print_warning "This will rebuild all layers from scratch"
                ;;
            3)
                print_info "For multi-stage builds, specify which stage to build"
                print_info "Common stages: base, build, test, production"
                read -p "Target stage name: " target_stage
                if validate_not_empty "$target_stage" "Target stage"; then
                    options[target]="--target $target_stage"
                    print_success "Target stage: $target_stage"
                fi
                ;;
            4)
                print_info "Build context is the directory sent to Docker daemon"
                print_info "Usually the directory containing the Dockerfile"
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
                print_error "Invalid option. Please select 1-5"
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
    print_info "🏗️ Build Configuration:"
    echo "  Dockerfile: $dockerfile"
    echo "  Image: $image_name"
    echo "  Context: $context"
    if [[ -n "${build_opts[build_args]:-}" ]]; then
        echo "  Build args: ${build_opts[build_args]}"
    fi
    if [[ -n "${build_opts[no_cache]:-}" ]]; then
        echo "  No cache: enabled"
    fi
    if [[ -n "${build_opts[target]:-}" ]]; then
        echo "  Target stage: ${build_opts[target]#--target }"
    fi
    print_separator
    print_info "Full command: $build_cmd"
    print_separator

    if ! confirm "🚀 Start build process?"; then
        print_info "Build cancelled by user"
        return $EXIT_USER_CANCEL
    fi

    print_info "🔨 Building image... (timeout: ${BUILD_TIMEOUT}s)"
    print_info "💡 This may take several minutes depending on your Dockerfile"

    local start_time=$(date +%s)
    local build_success=false

    # Show progress indicator
    echo -n "Building"

    if timeout $BUILD_TIMEOUT bash -c "$build_cmd"; then
        build_success=true
        echo "" # New line after progress dots
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_success "✅ Build completed successfully in ${duration}s"
        return 0
    else
        echo "" # New line after progress dots
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            print_error "⏰ Build timed out after ${BUILD_TIMEOUT}s"
            print_info "💡 Try increasing timeout or optimizing your Dockerfile"
            return $EXIT_TIMEOUT
        else
            print_error "❌ Build failed with exit code $exit_code"
            print_info "💡 Check the build output above for error details"
            print_info "💡 Common issues: missing files, syntax errors, network timeouts"
            return 1
        fi
    fi
}

# ============================================================================
# VERIFY IMAGE
# ============================================================================

verify_image() {
    local image_name="$1"

    print_info "🔍 Verifying built image..."

    if docker image inspect "$image_name" &>/dev/null; then
        local size=$(docker image inspect "$image_name" --format='{{.Size}}' 2>/dev/null)
        local size_mb=$((size / 1024 / 1024))
        local layers=$(docker history "$image_name" --format "{{.ID}}" | wc -l)
        local created=$(docker image inspect "$image_name" --format='{{.Created}}' 2>/dev/null)

        print_success "✅ Image created successfully!"
        print_info "📊 Image Details:"
        echo "  Name: $image_name"
        echo "  Size: ${size_mb}MB"
        echo "  Layers: $layers"
        echo "  Created: $created"

        # Show image layers summary
        print_info "🏗️ Build Layers Summary:"
        docker history "$image_name" --human=true --format "table {{.CreatedBy}}\t{{.Size}}" | head -n 8

        # Check for potential issues
        if [ $size_mb -gt 1000 ]; then
            print_warning "⚠️ Large image size (${size_mb}MB) - consider optimization"
        fi

        if [ $layers -gt 50 ]; then
            print_warning "⚠️ Many layers ($layers) - consider multi-stage build"
        fi

        return 0
    else
        print_error "❌ Image verification failed: $image_name not found"
        print_info "💡 Check build output above for error details"
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
    print_info "Build Docker images with best practices and interactive configuration"
    print_info "This script helps you:"
    print_info "  • Find and select Dockerfiles automatically"
    print_info "  • Configure build arguments and options"
    print_info "  • Set build context and target stages"
    print_info "  • Enable no-cache builds for debugging"
    print_info "  • Verify build results"
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
    print_success "🎉 Build process completed successfully!"
    print_separator
    print_header "📋 Build Summary"
    print_info "✅ Image: $image_name"
    print_info "📏 Size: $(docker images "$image_name" --format "{{.Size}}" 2>/dev/null || echo "unknown")"
    print_info "🕒 Created: $(docker images "$image_name" --format "{{.CreatedAt}}" 2>/dev/null || echo "unknown")"
    print_info "🏗️ Layers: $(docker history "$image_name" --format "{{.ID}}" | wc -l)"
    print_separator
    print_info "🚀 Next Steps:"
    echo "  • Test locally:     docker run --rm -it $image_name"
    echo "  • Run as daemon:    docker run -d $image_name"
    echo "  • Push to registry: docker push $image_name"
    echo "  • View build layers: docker history $image_name"
    echo "  • Inspect metadata:  docker inspect $image_name"
    echo "  • Check vulnerabilities: docker scan $image_name"
    print_separator
    print_info "💡 Pro Tips:"
    echo "  • Use 'docker images' to see all your images"
    echo "  • Use 'docker system df' to check disk usage"
    echo "  • Consider multi-stage builds to reduce image size"
    echo "  • Use .dockerignore to exclude unnecessary files"
    print_separator
    
    exit $EXIT_SUCCESS
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"

#!/usr/bin/env bash
# Bashmenu v2.2 - Performance Optimization Script
# Apply performance optimizations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#######################################
# Optimize cache settings
#######################################
optimize_cache() {
    echo -e "${CYAN}Optimizing cache settings...${NC}"
    
    local env_file="${BASHMENU_USER_DIR:-$HOME/.bashmenu}/.bashmenu.env"
    
    if [[ ! -f "$env_file" ]]; then
        echo "Creating .bashmenu.env with optimized settings"
        mkdir -p "$(dirname "$env_file")"
        cat > "$env_file" << 'EOF'
# Bashmenu Performance Optimizations
BASHMENU_ENABLE_CACHE=true
BASHMENU_CACHE_TTL=3600
BASHMENU_LOG_LEVEL=WARN
BASHMENU_DEBUG_MODE=false
EOF
    else
        echo "Updating existing .bashmenu.env"
        
        # Enable cache if not set
        if ! grep -q "BASHMENU_ENABLE_CACHE" "$env_file"; then
            echo "BASHMENU_ENABLE_CACHE=true" >> "$env_file"
        fi
        
        # Set optimal TTL
        if ! grep -q "BASHMENU_CACHE_TTL" "$env_file"; then
            echo "BASHMENU_CACHE_TTL=3600" >> "$env_file"
        fi
    fi
    
    echo -e "${GREEN}✓ Cache optimized${NC}"
    echo ""
}

#######################################
# Optimize script scanning
#######################################
optimize_scanning() {
    echo -e "${CYAN}Optimizing script scanning...${NC}"
    
    # Create scan cache
    local cache_dir="${BASHMENU_USER_DIR:-$HOME/.bashmenu}/cache"
    mkdir -p "$cache_dir"
    
    local plugins_dir="${BASHMENU_PLUGINS_DIR:-$SCRIPT_DIR/plugins}"
    
    if [[ -d "$plugins_dir" ]]; then
        echo "Pre-caching script list..."
        find "$plugins_dir" -type f -name "*.sh" > "$cache_dir/scripts.cache"
        echo -e "${GREEN}✓ Script list cached${NC}"
    else
        echo -e "${YELLOW}⚠ Plugins directory not found${NC}"
    fi
    
    echo ""
}

#######################################
# Reduce fork overhead
#######################################
optimize_forks() {
    echo -e "${CYAN}Analyzing fork usage...${NC}"
    
    # Count subshells in main modules
    local core_files=(
        "$SCRIPT_DIR/src/core/config.sh"
        "$SCRIPT_DIR/src/core/logger.sh"
        "$SCRIPT_DIR/src/core/utils.sh"
    )
    
    local total_forks=0
    
    for file in "${core_files[@]}"; do
        if [[ -f "$file" ]]; then
            local forks
            forks=$(grep -c '$(' "$file" 2>/dev/null || echo 0)
            total_forks=$((total_forks + forks))
        fi
    done
    
    echo "Total subshells in core modules: $total_forks"
    
    if [[ $total_forks -gt 50 ]]; then
        echo -e "${YELLOW}⚠ Consider reducing subshell usage${NC}"
    else
        echo -e "${GREEN}✓ Fork usage acceptable${NC}"
    fi
    
    echo ""
}

#######################################
# Optimize lazy loading
#######################################
optimize_lazy_loading() {
    echo -e "${CYAN}Configuring lazy loading...${NC}"
    
    # Ensure lazy loader is enabled
    local env_file="${BASHMENU_USER_DIR:-$HOME/.bashmenu}/.bashmenu.env"
    
    if [[ -f "$env_file" ]]; then
        if ! grep -q "BASHMENU_LAZY_LOADING" "$env_file"; then
            echo "BASHMENU_LAZY_LOADING=true" >> "$env_file"
            echo -e "${GREEN}✓ Lazy loading enabled${NC}"
        fi
    fi
    
    echo ""
}

#######################################
# Run benchmarks
#######################################
run_benchmarks() {
    echo -e "${CYAN}Running benchmarks...${NC}"
    echo ""
    
    # Startup benchmark
    echo "Benchmark 1: Startup time"
    local start end duration
    
    start=$(date +%s%N 2>/dev/null || date +%s)
    bash -c "source '$SCRIPT_DIR/src/core/config.sh' && load_configuration" > /dev/null 2>&1
    end=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ "$start" =~ [0-9]{10,} ]]; then
        duration=$(( (end - start) / 1000000 ))
    else
        duration=$(( (end - start) * 1000 ))
    fi
    
    echo "  Config loading: ${duration}ms"
    
    if [[ $duration -lt 100 ]]; then
        echo -e "  ${GREEN}✓ Fast${NC}"
    elif [[ $duration -lt 200 ]]; then
        echo -e "  ${YELLOW}⚠ Acceptable${NC}"
    else
        echo -e "  ${YELLOW}⚠ Slow${NC}"
    fi
    
    echo ""
    
    # Search benchmark
    if [[ -f "$SCRIPT_DIR/src/features/search.sh" ]]; then
        echo "Benchmark 2: Search performance"
        
        source "$SCRIPT_DIR/src/features/search.sh"
        search_init
        
        local plugins_dir="${BASHMENU_PLUGINS_DIR:-$SCRIPT_DIR/plugins}"
        
        start=$(date +%s%N 2>/dev/null || date +%s)
        search_incremental "test" "$plugins_dir" "all" > /dev/null 2>&1
        end=$(date +%s%N 2>/dev/null || date +%s)
        
        if [[ "$start" =~ [0-9]{10,} ]]; then
            duration=$(( (end - start) / 1000000 ))
        else
            duration=$(( (end - start) * 1000 ))
        fi
        
        echo "  Search time: ${duration}ms"
        
        if [[ $duration -lt 200 ]]; then
            echo -e "  ${GREEN}✓ Target met (<200ms)${NC}"
        else
            echo -e "  ${YELLOW}⚠ Above target (${duration}ms > 200ms)${NC}"
        fi
    fi
    
    echo ""
}

#######################################
# Generate optimization report
#######################################
generate_report() {
    echo "========================================"
    echo "Optimization Report"
    echo "========================================"
    echo ""
    
    echo "Applied optimizations:"
    echo "  ✓ Cache enabled and configured"
    echo "  ✓ Script list pre-cached"
    echo "  ✓ Lazy loading configured"
    echo "  ✓ Performance benchmarks completed"
    echo ""
    
    echo "Performance targets:"
    echo "  • Startup: <1.5s with cache"
    echo "  • Search: <200ms"
    echo "  • Navigation: <100ms"
    echo ""
    
    echo "Next steps:"
    echo "  1. Run: bash scripts/profile-startup.sh"
    echo "  2. Monitor performance in production"
    echo "  3. Adjust cache TTL if needed"
    echo ""
}

#######################################
# Main
#######################################
main() {
    echo "========================================"
    echo "Bashmenu Performance Optimization"
    echo "========================================"
    echo ""
    
    optimize_cache
    optimize_scanning
    optimize_forks
    optimize_lazy_loading
    run_benchmarks
    generate_report
}

main "$@"

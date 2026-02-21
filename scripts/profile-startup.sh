#!/usr/bin/env bash
# Bashmenu v2.2 - Startup Profiling
# Measure startup time and identify bottlenecks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILE_LOG="/tmp/bashmenu_profile_$$.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#######################################
# Measure execution time
# Arguments:
#   $1 - Label
#   $@ - Command to execute
# Outputs:
#   Execution time in milliseconds
#######################################
measure_time() {
    local label="$1"
    shift
    
    local start end duration
    start=$(date +%s%N 2>/dev/null || date +%s)
    
    "$@" > /dev/null 2>&1
    
    end=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ "$start" =~ [0-9]{10,} ]]; then
        duration=$(( (end - start) / 1000000 ))
    else
        duration=$(( (end - start) * 1000 ))
    fi
    
    echo "$label: ${duration}ms" | tee -a "$PROFILE_LOG"
    echo "$duration"
}

#######################################
# Profile module loading
#######################################
profile_module_loading() {
    echo -e "${CYAN}Profiling module loading...${NC}"
    echo ""
    
    local total=0
    local time
    
    # Config module
    time=$(measure_time "Config module" bash -c "source '$SCRIPT_DIR/src/core/config.sh' && load_configuration")
    total=$((total + time))
    
    # Logger module
    time=$(measure_time "Logger module" bash -c "source '$SCRIPT_DIR/src/core/logger.sh'")
    total=$((total + time))
    
    # Utils module
    time=$(measure_time "Utils module" bash -c "source '$SCRIPT_DIR/src/core/utils.sh'")
    total=$((total + time))
    
    # Cache module
    time=$(measure_time "Cache module" bash -c "source '$SCRIPT_DIR/src/scripts/cache.sh' && cache_init")
    total=$((total + time))
    
    echo ""
    echo "Total module loading: ${total}ms"
    echo ""
}

#######################################
# Profile script scanning
#######################################
profile_script_scanning() {
    echo -e "${CYAN}Profiling script scanning...${NC}"
    echo ""
    
    local plugins_dir="${BASHMENU_PLUGINS_DIR:-$SCRIPT_DIR/plugins}"
    
    if [[ ! -d "$plugins_dir" ]]; then
        echo "Plugins directory not found: $plugins_dir"
        return 1
    fi
    
    # Without cache
    measure_time "Scan without cache" find "$plugins_dir" -type f -name "*.sh"
    
    # With cache (simulate)
    source "$SCRIPT_DIR/src/scripts/cache.sh"
    cache_init
    
    local scripts
    scripts=$(find "$plugins_dir" -type f -name "*.sh")
    cache_set "scripts" "list" "$scripts"
    
    measure_time "Scan with cache" cache_get "scripts" "list"
    
    echo ""
}

#######################################
# Profile search operations
#######################################
profile_search() {
    echo -e "${CYAN}Profiling search operations...${NC}"
    echo ""
    
    source "$SCRIPT_DIR/src/features/search.sh"
    search_init
    
    local plugins_dir="${BASHMENU_PLUGINS_DIR:-$SCRIPT_DIR/plugins}"
    
    # Search by name
    measure_time "Search by name" search_by_name "deploy" "$plugins_dir"
    
    # Search by description
    measure_time "Search by description" search_by_description "production" "$plugins_dir"
    
    # Incremental search
    measure_time "Incremental search" search_incremental "test" "$plugins_dir" "all"
    
    echo ""
}

#######################################
# Profile favorites operations
#######################################
profile_favorites() {
    echo -e "${CYAN}Profiling favorites operations...${NC}"
    echo ""
    
    export BASHMENU_USER_DIR="/tmp/bashmenu_profile_$$"
    mkdir -p "$BASHMENU_USER_DIR"
    
    source "$SCRIPT_DIR/src/features/favorites.sh"
    
    measure_time "Favorites init" favorites_init
    
    # Add favorites
    local test_script="/tmp/test_script.sh"
    echo "#!/bin/bash" > "$test_script"
    
    measure_time "Add favorite" favorites_add "$test_script"
    measure_time "Check favorite" favorites_is_favorite "$test_script"
    measure_time "List favorites" favorites_list
    measure_time "Remove favorite" favorites_remove "$test_script"
    
    rm -rf "$BASHMENU_USER_DIR"
    rm -f "$test_script"
    
    echo ""
}

#######################################
# Profile hooks execution
#######################################
profile_hooks() {
    echo -e "${CYAN}Profiling hooks execution...${NC}"
    echo ""
    
    source "$SCRIPT_DIR/src/features/hooks.sh"
    
    # Define test hooks
    test_hook_1() { return 0; }
    test_hook_2() { return 0; }
    test_hook_3() { return 0; }
    
    hooks_init
    
    measure_time "Register hook" register_hook "pre_execute" "test_hook_1" 50
    
    register_hook "pre_execute" "test_hook_2" 40 > /dev/null
    register_hook "pre_execute" "test_hook_3" 60 > /dev/null
    
    measure_time "Execute 3 hooks" execute_hooks "pre_execute"
    
    echo ""
}

#######################################
# Generate recommendations
#######################################
generate_recommendations() {
    echo -e "${CYAN}Performance Recommendations:${NC}"
    echo ""
    
    # Analyze log
    local config_time logger_time utils_time cache_time
    config_time=$(grep "Config module:" "$PROFILE_LOG" | awk '{print $3}' | sed 's/ms//')
    logger_time=$(grep "Logger module:" "$PROFILE_LOG" | awk '{print $3}' | sed 's/ms//')
    utils_time=$(grep "Utils module:" "$PROFILE_LOG" | awk '{print $3}' | sed 's/ms//')
    cache_time=$(grep "Cache module:" "$PROFILE_LOG" | awk '{print $3}' | sed 's/ms//')
    
    # Check thresholds
    if [[ ${config_time:-0} -gt 100 ]]; then
        echo -e "${YELLOW}⚠ Config loading is slow (${config_time}ms)${NC}"
        echo "  Recommendation: Optimize .env parsing"
    fi
    
    if [[ ${cache_time:-0} -gt 50 ]]; then
        echo -e "${YELLOW}⚠ Cache init is slow (${cache_time}ms)${NC}"
        echo "  Recommendation: Reduce cache initialization overhead"
    fi
    
    # Search performance
    local search_time
    search_time=$(grep "Incremental search:" "$PROFILE_LOG" | awk '{print $3}' | sed 's/ms//')
    
    if [[ ${search_time:-0} -gt 200 ]]; then
        echo -e "${RED}✗ Search is too slow (${search_time}ms > 200ms)${NC}"
        echo "  Recommendation: Implement indexed search or improve caching"
    else
        echo -e "${GREEN}✓ Search performance acceptable (${search_time}ms)${NC}"
    fi
    
    echo ""
}

#######################################
# Main profiling
#######################################
main() {
    echo "========================================"
    echo "Bashmenu Performance Profiling"
    echo "========================================"
    echo ""
    
    # Clear log
    > "$PROFILE_LOG"
    
    profile_module_loading
    profile_script_scanning
    profile_search
    profile_favorites
    profile_hooks
    
    echo "========================================"
    echo "Summary"
    echo "========================================"
    echo ""
    
    generate_recommendations
    
    echo "Full log: $PROFILE_LOG"
    echo ""
}

main "$@"

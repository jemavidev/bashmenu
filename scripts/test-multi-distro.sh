#!/usr/bin/env bash
# Multi-distro testing script for Bashmenu v2.2

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

#######################################
# Detect distribution
#######################################
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

#######################################
# Test installation
#######################################
test_installation() {
    local distro="$1"
    
    echo -e "${CYAN}Testing installation on $distro...${NC}"
    
    # Check if install.sh exists
    if [[ ! -f "$SCRIPT_DIR/install.sh" ]]; then
        echo -e "${RED}✗ install.sh not found${NC}"
        return 1
    fi
    
    # Check if bashmenu executable exists
    if [[ ! -f "$SCRIPT_DIR/bashmenu" ]]; then
        echo -e "${RED}✗ bashmenu executable not found${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Installation files present${NC}"
    return 0
}

#######################################
# Test dependencies
#######################################
test_dependencies() {
    echo -e "${CYAN}Testing dependencies...${NC}"
    
    local missing=0
    
    # Required
    if ! command -v bash >/dev/null 2>&1; then
        echo -e "${RED}✗ bash not found${NC}"
        ((missing++))
    else
        local bash_version
        bash_version=$(bash --version | head -n1 | grep -oP '\d+\.\d+' | head -n1)
        echo -e "${GREEN}✓ bash $bash_version${NC}"
    fi
    
    # Optional
    if command -v fzf >/dev/null 2>&1; then
        echo -e "${GREEN}✓ fzf (optional)${NC}"
    else
        echo -e "${YELLOW}⚠ fzf not installed (optional)${NC}"
    fi
    
    if command -v dialog >/dev/null 2>&1; then
        echo -e "${GREEN}✓ dialog (optional)${NC}"
    else
        echo -e "${YELLOW}⚠ dialog not installed (optional)${NC}"
    fi
    
    if [[ $missing -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Test core functionality
#######################################
test_functionality() {
    echo -e "${CYAN}Testing core functionality...${NC}"
    
    # Test config loading
    if bash -c "source '$SCRIPT_DIR/src/core/config.sh' && load_configuration" 2>/dev/null; then
        echo -e "${GREEN}✓ Config loading${NC}"
    else
        echo -e "${RED}✗ Config loading failed${NC}"
        return 1
    fi
    
    # Test cache
    if bash -c "source '$SCRIPT_DIR/src/scripts/cache.sh' && cache_init" 2>/dev/null; then
        echo -e "${GREEN}✓ Cache system${NC}"
    else
        echo -e "${RED}✗ Cache system failed${NC}"
        return 1
    fi
    
    # Test search
    if bash -c "source '$SCRIPT_DIR/src/features/search.sh' && search_init" 2>/dev/null; then
        echo -e "${GREEN}✓ Search system${NC}"
    else
        echo -e "${RED}✗ Search system failed${NC}"
        return 1
    fi
    
    return 0
}

#######################################
# Test performance
#######################################
test_performance() {
    echo -e "${CYAN}Testing performance...${NC}"
    
    # Startup time
    local start end duration
    start=$(date +%s%N 2>/dev/null || date +%s)
    bash -c "source '$SCRIPT_DIR/src/core/config.sh' && load_configuration" >/dev/null 2>&1
    end=$(date +%s%N 2>/dev/null || date +%s)
    
    if [[ "$start" =~ [0-9]{10,} ]]; then
        duration=$(( (end - start) / 1000000 ))
    else
        duration=$(( (end - start) * 1000 ))
    fi
    
    echo "  Config loading: ${duration}ms"
    
    if [[ $duration -lt 200 ]]; then
        echo -e "${GREEN}✓ Performance acceptable${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Performance slow (${duration}ms)${NC}"
        return 0
    fi
}

#######################################
# Run tests
#######################################
test_suite() {
    echo -e "${CYAN}Running test suite...${NC}"
    
    local passed=0
    local failed=0
    
    # Unit tests
    if [[ -f "$SCRIPT_DIR/tests/unit/features/test_search.sh" ]]; then
        if bash "$SCRIPT_DIR/tests/unit/features/test_search.sh" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Search tests${NC}"
            ((passed++))
        else
            echo -e "${RED}✗ Search tests failed${NC}"
            ((failed++))
        fi
    fi
    
    if [[ -f "$SCRIPT_DIR/tests/unit/features/test_favorites.sh" ]]; then
        if bash "$SCRIPT_DIR/tests/unit/features/test_favorites.sh" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Favorites tests${NC}"
            ((passed++))
        else
            echo -e "${RED}✗ Favorites tests failed${NC}"
            ((failed++))
        fi
    fi
    
    echo "  Passed: $passed, Failed: $failed"
    
    if [[ $failed -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

#######################################
# Main
#######################################
main() {
    local distro
    distro=$(detect_distro)
    
    echo "========================================"
    echo "Bashmenu v2.2 - Multi-Distro Testing"
    echo "========================================"
    echo ""
    echo "Distribution: $distro"
    echo "Bash version: $(bash --version | head -n1)"
    echo ""
    
    local total=0
    local passed=0
    
    # Run tests
    test_installation "$distro" && ((passed++)) || true
    ((total++))
    
    test_dependencies && ((passed++)) || true
    ((total++))
    
    test_functionality && ((passed++)) || true
    ((total++))
    
    test_performance && ((passed++)) || true
    ((total++))
    
    test_suite && ((passed++)) || true
    ((total++))
    
    echo ""
    echo "========================================"
    echo "Summary"
    echo "========================================"
    echo "Distribution: $distro"
    echo "Tests passed: $passed/$total"
    echo ""
    
    if [[ $passed -eq $total ]]; then
        echo -e "${GREEN}✓ All tests passed on $distro${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Some tests failed on $distro${NC}"
        return 1
    fi
}

main "$@"

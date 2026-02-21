#!/usr/bin/env bash
# Run ShellCheck on all bash scripts

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
    echo -e "${RED}Error: shellcheck not installed${NC}"
    echo "Install: sudo apt install shellcheck"
    exit 1
fi

echo "========================================"
echo "Running ShellCheck"
echo "========================================"
echo ""

# Find all .sh files
mapfile -t scripts < <(find "$SCRIPT_DIR" -name "*.sh" -type f ! -path "*/bats-testing/*" ! -path "*/shellcheck-stable/*" ! -path "*/.git/*")

echo "Found ${#scripts[@]} scripts to check"
echo ""

# Counters
total=0
passed=0
warnings=0
errors=0

# Run shellcheck on each file
for script in "${scripts[@]}"; do
    ((total++))
    
    # Run shellcheck
    output=$(shellcheck -x -S warning "$script" 2>&1)
    exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        ((passed++))
        echo -e "${GREEN}✓${NC} $script"
    else
        # Check severity
        if echo "$output" | grep -q "error:"; then
            ((errors++))
            echo -e "${RED}✗${NC} $script"
            echo "$output" | head -n 5
        else
            ((warnings++))
            echo -e "${YELLOW}⚠${NC} $script"
        fi
    fi
done

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo "Total scripts: $total"
echo -e "${GREEN}Passed: $passed${NC}"
echo -e "${YELLOW}Warnings: $warnings${NC}"
echo -e "${RED}Errors: $errors${NC}"
echo ""

if [[ $errors -eq 0 ]]; then
    echo -e "${GREEN}✓ No critical errors found!${NC}"
    exit 0
else
    echo -e "${RED}✗ $errors scripts with errors${NC}"
    exit 1
fi

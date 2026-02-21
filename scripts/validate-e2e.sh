#!/bin/bash
# End-to-End Validation for Skills-On-Demand System
# Tests complete workflow: detection → loading → verification

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/detect-skills.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

echo "🧪 END-TO-END VALIDATION"
echo "======================="
echo ""

# Test cases with expected outcomes
declare -a TEST_CASES=(
    "Implementa API REST con JWT|coder|auth-implementation-patterns"
    "Diseña formulario accesible|ux-designer|accessibility-compliance"
    "Optimiza consultas SQL|coder|sql-optimization-patterns"
    "Escribe tests E2E|tester|e2e-testing-patterns"
    "Explica React hooks|teacher|vercel-react-best-practices"
)

total_tests=${#TEST_CASES[@]}
passed=0
failed=0
total_tokens_saved=0

print_section "Running E2E Tests"
echo ""

for test_case in "${TEST_CASES[@]}"; do
    IFS='|' read -r query agent expected_skill <<< "$test_case"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Query: $query"
    print_info "Agent: $agent"
    print_info "Expected: $expected_skill"
    echo ""
    
    # Step 1: Run detection
    print_info "Step 1: Running detection..."
    DETECTION_OUTPUT=$("$DETECT_SCRIPT" "$query" "$agent" false 2>&1)
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -ne 0 ]; then
        print_error "Detection failed (exit code: $EXIT_CODE)"
        failed=$((failed + 1))
        echo ""
        continue
    fi
    
    # Extract detected skills
    DETECTED_SKILLS=$(echo "$DETECTION_OUTPUT" | grep "Skills:" | sed 's/.*Skills: //')
    
    if [ -z "$DETECTED_SKILLS" ]; then
        print_error "No skills detected"
        failed=$((failed + 1))
        echo ""
        continue
    fi
    
    print_success "Detected: $DETECTED_SKILLS"
    
    # Step 2: Verify expected skill is in detected skills
    print_info "Step 2: Verifying expected skill..."
    if echo "$DETECTED_SKILLS" | grep -q "$expected_skill"; then
        print_success "Expected skill found: $expected_skill"
    else
        print_error "Expected skill NOT found: $expected_skill"
        failed=$((failed + 1))
        echo ""
        continue
    fi
    
    # Step 3: Calculate token savings
    print_info "Step 3: Calculating token savings..."
    TOKENS_USED=$(echo "$DETECTION_OUTPUT" | grep "Total tokens:" | sed 's/.*Total tokens: //' | awk '{print $1}')
    TOKENS_AVAILABLE=$(echo "$DETECTION_OUTPUT" | grep "Available:" | sed 's/.*Available: //' | awk '{print $1}')
    
    if [ -n "$TOKENS_USED" ] && [ -n "$TOKENS_AVAILABLE" ]; then
        TOKENS_SAVED=$((TOKENS_AVAILABLE - TOKENS_USED))
        EFFICIENCY=$((TOKENS_SAVED * 100 / TOKENS_AVAILABLE))
        total_tokens_saved=$((total_tokens_saved + TOKENS_SAVED))
        
        print_success "Tokens: $TOKENS_USED used, $TOKENS_SAVED saved ($EFFICIENCY%)"
    fi
    
    # Step 4: Test passed
    print_success "TEST PASSED"
    passed=$((passed + 1))
    echo ""
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_section "VALIDATION RESULTS"
echo ""
echo "  Total tests: $total_tests"
print_success "Passed: $passed"
if [ $failed -gt 0 ]; then
    print_error "Failed: $failed"
fi
echo ""

accuracy=$((passed * 100 / total_tests))
echo "  Accuracy: $accuracy%"
echo "  Total tokens saved: $total_tokens_saved"
echo ""

# Performance test
print_section "Performance Test"
echo ""
print_info "Testing detection speed..."

start_time=$(date +%s%N)
"$DETECT_SCRIPT" "Implementa autenticación OAuth2" coder false > /dev/null 2>&1
end_time=$(date +%s%N)

duration=$(( (end_time - start_time) / 1000000 ))
echo "  Detection time: ${duration}ms"

if [ $duration -lt 300 ]; then
    print_success "Performance: PASS (<300ms)"
else
    print_error "Performance: FAIL (>300ms)"
fi

echo ""

# Final verdict
if [ $accuracy -ge 80 ] && [ $duration -lt 300 ]; then
    print_success "✅ END-TO-END VALIDATION PASSED"
    echo ""
    echo "  System is ready for production use"
    echo "  - Detection accuracy: $accuracy%"
    echo "  - Performance: ${duration}ms"
    echo "  - Token savings: $total_tokens_saved tokens"
    exit 0
else
    print_error "❌ END-TO-END VALIDATION FAILED"
    echo ""
    echo "  Issues found:"
    [ $accuracy -lt 80 ] && echo "  - Accuracy below 80%: $accuracy%"
    [ $duration -ge 300 ] && echo "  - Performance above 300ms: ${duration}ms"
    exit 1
fi

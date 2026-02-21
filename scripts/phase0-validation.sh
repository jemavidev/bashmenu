#!/bin/bash
# Phase 0 Validation - Test Kiro Capabilities
# MUST pass before implementing Skills-On-Demand

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${BLUE}━━━ $1 ━━━${NC}"; }

echo "🧪 PHASE 0: Kiro Capabilities Validation"
echo "========================================"
echo ""
print_warning "This validation MUST pass before implementing Skills-On-Demand"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0
CRITICAL_FAILED=false

# ============================================
# TEST 1: Create Test Agent
# ============================================
print_section "Test 1: Create Test Agent"
echo ""

TEST_AGENT_FILE="$PROJECT_ROOT/.kiro/steering/agents/test-agent.md"

if [ -f "$TEST_AGENT_FILE" ]; then
    print_warning "Test agent already exists, removing..."
    rm "$TEST_AGENT_FILE"
fi

cat > "$TEST_AGENT_FILE" << 'EOF'
# Agent: Test Agent

## Role
Test agent for validating Kiro capabilities.

## Expertise
- Testing
- Validation

## Instructions
You are a test agent. When invoked, respond with:
"TEST AGENT ACTIVE - Initial state"

## Test Marker
<!-- INITIAL_STATE -->
EOF

if [ -f "$TEST_AGENT_FILE" ]; then
    print_success "Test agent created"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Failed to create test agent"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    CRITICAL_FAILED=true
fi

echo ""

# ============================================
# TEST 2: Verify Test Agent Structure
# ============================================
print_section "Test 2: Verify Test Agent Structure"
echo ""

if grep -q "TEST AGENT ACTIVE" "$TEST_AGENT_FILE"; then
    print_success "Test agent has correct content"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Test agent content incorrect"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

if grep -q "<!-- INITIAL_STATE -->" "$TEST_AGENT_FILE"; then
    print_success "Test marker present"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Test marker missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""

# ============================================
# TEST 3: File Modification Test
# ============================================
print_section "Test 3: File Modification Capability"
echo ""

print_info "Modifying test agent file..."

# Add dynamic content marker
cat >> "$TEST_AGENT_FILE" << 'EOF'

## Dynamic Content Section

<!-- DYNAMIC_CONTENT_START -->
<!-- This section will be modified dynamically -->
<!-- DYNAMIC_CONTENT_END -->
EOF

if grep -q "DYNAMIC_CONTENT_START" "$TEST_AGENT_FILE"; then
    print_success "Dynamic content section added"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Failed to add dynamic content section"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    CRITICAL_FAILED=true
fi

echo ""

# ============================================
# TEST 4: Dynamic Injection Test
# ============================================
print_section "Test 4: Dynamic Content Injection"
echo ""

print_info "Injecting test content..."

# Create temporary test content
TEST_CONTENT_FILE="$PROJECT_ROOT/.kiro/test-content.md"
cat > "$TEST_CONTENT_FILE" << 'EOF'
# Test Content
This is dynamically injected content for testing.
EOF

# Try to inject using #[[file:...]] syntax
TEMP_FILE=$(mktemp)
awk -v content_file="$TEST_CONTENT_FILE" '
    /<!-- DYNAMIC_CONTENT_START -->/ {
        print $0
        getline
        while ($0 !~ /<!-- DYNAMIC_CONTENT_END -->/) {
            getline
        }
        print "<!-- Injected at: " strftime("%Y-%m-%d %H:%M:%S") " -->"
        print "#[[file:" content_file "]]"
        print $0
        next
    }
    { print $0 }
' "$TEST_AGENT_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$TEST_AGENT_FILE"

if grep -q "#\[\[file:" "$TEST_AGENT_FILE"; then
    print_success "Content injection syntax added"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Failed to inject content"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    CRITICAL_FAILED=true
fi

echo ""

# ============================================
# TEST 5: Verify File Integrity
# ============================================
print_section "Test 5: Verify File Integrity"
echo ""

if [ -f "$TEST_AGENT_FILE" ]; then
    FILE_SIZE=$(wc -c < "$TEST_AGENT_FILE")
    if [ "$FILE_SIZE" -gt 0 ]; then
        print_success "Test agent file is valid (${FILE_SIZE} bytes)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_error "Test agent file is empty"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        CRITICAL_FAILED=true
    fi
else
    print_error "Test agent file missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    CRITICAL_FAILED=true
fi

echo ""

# ============================================
# TEST 6: Performance Test
# ============================================
print_section "Test 6: Performance Test"
echo ""

print_info "Testing modification speed..."

START_TIME=$(date +%s%N)

# Simulate detection + injection
for i in {1..10}; do
    echo "<!-- Test iteration $i -->" >> "$TEST_AGENT_FILE"
done

END_TIME=$(date +%s%N)
ELAPSED_MS=$(( (END_TIME - START_TIME) / 1000000 ))

print_info "10 modifications took: ${ELAPSED_MS}ms"

if [ "$ELAPSED_MS" -lt 100 ]; then
    print_success "Performance acceptable (< 100ms for 10 ops)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
elif [ "$ELAPSED_MS" -lt 300 ]; then
    print_warning "Performance marginal (${ELAPSED_MS}ms)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_error "Performance too slow (${ELAPSED_MS}ms)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""

# ============================================
# TEST 7: Cleanup Test
# ============================================
print_section "Test 7: Cleanup"
echo ""

print_info "Cleaning up test files..."

if [ -f "$TEST_CONTENT_FILE" ]; then
    rm "$TEST_CONTENT_FILE"
    print_success "Test content file removed"
else
    print_warning "Test content file already removed"
fi

# Keep test agent for manual testing
print_info "Test agent kept at: $TEST_AGENT_FILE"
print_info "You can test it with: @test-agent \"hello\""

echo ""

# ============================================
# RESULTS SUMMARY
# ============================================
echo "========================================"
echo "📊 VALIDATION RESULTS"
echo "========================================"
echo ""

print_info "Tests Passed: $TESTS_PASSED"
print_info "Tests Failed: $TESTS_FAILED"
echo ""

if [ "$CRITICAL_FAILED" = true ]; then
    print_error "CRITICAL TESTS FAILED"
    echo ""
    print_error "❌ VERDICT: NO-GO"
    echo ""
    print_warning "Skills-On-Demand implementation CANNOT proceed with file-based injection"
    echo ""
    print_info "Recommended Actions:"
    echo "  1. Review failed tests above"
    echo "  2. Consider Prompt-Based Injection alternative"
    echo "  3. See RISK-MITIGATION-PLAN.md for details"
    echo ""
    exit 1
elif [ "$TESTS_FAILED" -gt 0 ]; then
    print_warning "SOME TESTS FAILED"
    echo ""
    print_warning "⚠️  VERDICT: CONDITIONAL GO"
    echo ""
    print_info "Review failed tests and decide if acceptable"
    echo ""
    exit 2
else
    print_success "ALL TESTS PASSED"
    echo ""
    print_success "✅ VERDICT: GO"
    echo ""
    print_info "File-based injection appears feasible"
    print_warning "IMPORTANT: Manual testing still required"
    echo ""
    print_info "Next Steps:"
    echo "  1. Test manually: @test-agent \"test message\""
    echo "  2. Verify Kiro loads the modified agent"
    echo "  3. Check if dynamic content is visible"
    echo "  4. If successful, proceed to Phase 1"
    echo "  5. If not, use Prompt-Based Injection alternative"
    echo ""
    exit 0
fi

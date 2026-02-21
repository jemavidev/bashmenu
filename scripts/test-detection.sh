#!/bin/bash
# Test Suite for Skills Detection Algorithm
# Validates detection accuracy with multiple test cases

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/detect-skills.sh"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo "🧪 SKILLS DETECTION TEST SUITE"
echo "=============================="
echo ""

# Test cases: query|agent|expected_skills (comma-separated)
declare -a TEST_CASES=(
    "Diseña un formulario de login accesible|ux-designer|accessibility-compliance,frontend-design"
    "Implementa API REST con autenticación JWT|coder|auth-implementation-patterns,api-design-principles,nodejs-backend-patterns"
    "Escribe tests E2E con Playwright|tester|e2e-testing-patterns,webapp-testing"
    "Optimiza consultas SQL lentas|coder|sql-optimization-patterns,postgresql-table-design"
    "Crea un dashboard con KPIs|ux-designer|kpi-dashboard-design,ui-ux-pro-max"
    "Dockeriza la aplicación Node.js|devops|docker-expert,nodejs-backend-patterns"
    "Implementa CI/CD con GitHub Actions|devops|github-actions-templates,deployment-pipeline-design"
    "Diseña arquitectura de microservicios|architect|microservices-patterns,architecture-patterns"
    "Migra base de datos PostgreSQL|coder|database-migration,postgresql-table-design"
    "Optimiza rendimiento de Python|coder|python-performance-optimization,async-python-patterns"
    "Crea componentes React accesibles|coder|accessibility-compliance,vercel-react-best-practices"
    "Escribe documentación técnica API|writer|doc-coauthoring,api-design-principles"
    "Audita sitio web para SEO|researcher|audit-website,seo-audit"
    "Implementa autenticación OAuth2|coder|auth-implementation-patterns,api-design-principles"
    "Diseña sistema de design tokens|ux-designer|design-system-patterns,tailwind-design-system"
)

total_tests=${#TEST_CASES[@]}
passed=0
failed=0

for test_case in "${TEST_CASES[@]}"; do
    IFS='|' read -r query agent expected <<< "$test_case"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_info "Query: $query"
    print_info "Agent: $agent"
    print_info "Expected: $expected"
    echo ""
    
    # Run detection
    result=$("$DETECT_SCRIPT" "$query" "$agent" false 2>&1)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Extract selected skills
        selected=$(echo "$result" | grep "Skills:" | sed 's/.*Skills: //' | tr ',' '\n' | sort | tr '\n' ',' | sed 's/,$//')
        
        # Check if at least one expected skill was selected
        match_found=false
        IFS=',' read -ra EXPECTED_SKILLS <<< "$expected"
        for exp_skill in "${EXPECTED_SKILLS[@]}"; do
            if echo "$selected" | grep -q "$exp_skill"; then
                match_found=true
                break
            fi
        done
        
        if [ "$match_found" = true ]; then
            print_success "PASS - Selected: $selected"
            passed=$((passed + 1))
        else
            print_error "FAIL - Selected: $selected (expected one of: $expected)"
            failed=$((failed + 1))
        fi
    else
        print_error "FAIL - No skills selected (fallback triggered)"
        failed=$((failed + 1))
    fi
    
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 RESULTS"
echo "=========="
echo ""
echo "  Total tests: $total_tests"
print_success "Passed: $passed"
if [ $failed -gt 0 ]; then
    print_error "Failed: $failed"
fi
echo ""

accuracy=$((passed * 100 / total_tests))
echo "  Accuracy: $accuracy%"
echo ""

if [ $accuracy -ge 80 ]; then
    print_success "✅ Detection accuracy meets threshold (≥80%)"
    exit 0
else
    print_error "❌ Detection accuracy below threshold (<80%)"
    exit 1
fi

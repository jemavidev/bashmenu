#!/bin/bash

# BetterAgentX - Post Installation Check
# Verifica que la instalación esté 100% completa
# Usage: bash scripts/post-install-check.sh

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_ok() { echo -e "${GREEN}✅ $1${NC}"; }
print_fail() { echo -e "${RED}❌ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "${CYAN}▶ $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 BetterAgentX - Post Installation Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        print_ok "$2"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$3" = "warning" ]; then
            print_warn "$2"
            WARNINGS=$((WARNINGS + 1))
        else
            print_fail "$2"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
        fi
        return 1
    fi
}

# ============================================
# 1. SYSTEM REQUIREMENTS
# ============================================
print_step "Checking system requirements..."

command -v kiro &> /dev/null
check $? "Kiro Code installed"

command -v jq &> /dev/null
check $? "jq installed (recommended)" "warning"

command -v node &> /dev/null
check $? "Node.js installed (optional)" "warning"

echo ""

# ============================================
# 2. DIRECTORY STRUCTURE
# ============================================
print_step "Checking directory structure..."

[ -d ".kiro/steering/agents" ]
check $? "Agents directory exists"

[ -d ".kiro/memory" ]
check $? "Memory directory exists"

[ -d ".kiro/settings" ]
check $? "Settings directory exists"

[ -d ".kiro/hooks" ]
check $? "Hooks directory exists"

[ -d ".kiro/cache" ]
check $? "Cache directory exists"

[ -d ".kiro/skills" ]
check $? "Skills directory exists"

[ -d "scripts" ]
check $? "Scripts directory exists"

echo ""

# ============================================
# 3. AGENTS
# ============================================
print_step "Checking agents..."

AGENTS_COUNT=$(find .kiro/steering/agents -name "*.md" 2>/dev/null | wc -l)
[ $AGENTS_COUNT -ge 13 ]
check $? "Agents installed ($AGENTS_COUNT/13)"

# Check specific agents
REQUIRED_AGENTS=(
    "agentx.md"
    "architect.md"
    "coder.md"
    "critic.md"
    "security.md"
    "tester.md"
)

for agent in "${REQUIRED_AGENTS[@]}"; do
    [ -f ".kiro/steering/agents/$agent" ]
    check $? "Agent: $agent" "warning"
done

echo ""

# ============================================
# 4. MEMORY SYSTEM
# ============================================
print_step "Checking memory system..."

MEMORY_COUNT=$(find .kiro/memory -name "*.json" 2>/dev/null | wc -l)
[ $MEMORY_COUNT -ge 8 ]
check $? "Memory files ($MEMORY_COUNT/8)"

# Check specific memory files
REQUIRED_MEMORY=(
    "active-context.json"
    "decision-log.json"
    "progress.json"
    "patterns.json"
    "memory-stats.json"
    "project-metrics.json"
    "llm-usage.json"
    "project-size.json"
)

for file in "${REQUIRED_MEMORY[@]}"; do
    [ -f ".kiro/memory/$file" ]
    check $? "Memory: $file"
done

[ -f ".kiro/memory/dashboard.html" ]
check $? "Dashboard HTML"

echo ""

# ============================================
# 5. CONFIGURATION
# ============================================
print_step "Checking configuration..."

[ -f ".kiro/settings/betteragents.json" ]
check $? "Main configuration"

[ -f ".kiro/settings/agent-skills.json" ]
check $? "Agent skills configuration"

[ -f ".kiro/settings/skills-registry.json" ]
check $? "Skills registry"

echo ""

# ============================================
# 6. HOOKS
# ============================================
print_step "Checking automation hooks..."

HOOKS_COUNT=$(find .kiro/hooks -name "*.kiro.hook" 2>/dev/null | wc -l)
[ $HOOKS_COUNT -gt 0 ]
check $? "Automation hooks ($HOOKS_COUNT hooks)" "warning"

echo ""

# ============================================
# 7. SCRIPTS
# ============================================
print_step "Checking utility scripts..."

SCRIPTS_COUNT=$(find scripts -name "*.sh" 2>/dev/null | wc -l)
[ $SCRIPTS_COUNT -ge 20 ]
check $? "Utility scripts ($SCRIPTS_COUNT scripts)"

# Check critical scripts
CRITICAL_SCRIPTS=(
    "verify-system.sh"
    "update-dashboard.sh"
    "memory-stats.sh"
    "calculate-tokens.sh"
    "detect-skills.sh"
    "quick-check.sh"
)

for script in "${CRITICAL_SCRIPTS[@]}"; do
    if [ -f "scripts/$script" ]; then
        [ -x "scripts/$script" ]
        check $? "Script: $script (executable)"
    else
        check 1 "Script: $script (missing)" "warning"
    fi
done

echo ""

# ============================================
# 8. CACHE SYSTEM
# ============================================
print_step "Checking cache system..."

[ -f ".kiro/cache/skills-detection-cache.json" ]
check $? "Skills detection cache"

[ -f ".kiro/cache/agent-routing-cache.json" ]
check $? "Agent routing cache" "warning"

echo ""

# ============================================
# 9. SKILLS
# ============================================
print_step "Checking skills..."

[ -d ".kiro/skills/ui-ux-pro-max" ]
check $? "ui-ux-pro-max skill" "warning"

if command -v node &> /dev/null && command -v npx &> /dev/null; then
    SKILLS_INSTALLED=$(npx skills list 2>/dev/null | grep -c "^  " || echo "0")
    [ $SKILLS_INSTALLED -gt 0 ]
    check $? "Additional skills ($SKILLS_INSTALLED installed)" "warning"
fi

echo ""

# ============================================
# 10. GIT CONFIGURATION
# ============================================
print_step "Checking Git configuration..."

[ -f ".gitignore" ]
check $? ".gitignore exists"

if [ -f ".gitignore" ]; then
    grep -q ".kiro/cache/" .gitignore 2>/dev/null
    check $? ".gitignore configured for BetterAgentX" "warning"
fi

echo ""

# ============================================
# 11. SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Post Installation Check Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Total Checks: $TOTAL_CHECKS"
echo "  ✅ Passed: $PASSED_CHECKS"
echo "  ❌ Failed: $FAILED_CHECKS"
echo "  ⚠️  Warnings: $WARNINGS"
echo ""

PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

if [ $FAILED_CHECKS -eq 0 ]; then
    print_ok "Installation is 100% complete! 🎉"
    echo ""
    print_info "System Status: READY"
    echo ""
    echo "  Next steps:"
    echo "  1. Open Kiro Code: kiro ."
    echo "  2. Test AgentX: @agentx Hello!"
    echo "  3. View dashboard: bash scripts/open-dashboard.sh"
    echo ""
    exit 0
elif [ $FAILED_CHECKS -le 3 ]; then
    print_warn "Installation is $PERCENTAGE% complete with minor issues"
    echo ""
    print_info "System Status: FUNCTIONAL (with warnings)"
    echo ""
    echo "  Recommended actions:"
    echo "  1. Review failed checks above"
    echo "  2. Run: bash scripts/activate-all-features.sh"
    echo "  3. Re-check: bash scripts/post-install-check.sh"
    echo ""
    exit 0
else
    print_fail "Installation has $FAILED_CHECKS critical issues"
    echo ""
    print_info "System Status: INCOMPLETE"
    echo ""
    echo "  Required actions:"
    echo "  1. Review all failed checks above"
    echo "  2. Re-run installation: bash scripts/init.sh"
    echo "  3. Activate features: bash scripts/activate-all-features.sh"
    echo "  4. Re-check: bash scripts/post-install-check.sh"
    echo ""
    exit 1
fi

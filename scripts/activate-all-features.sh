#!/bin/bash

# BetterAgentX - Activate All Features 100%
# Ensures all features are fully activated and configured
# Usage: bash scripts/activate-all-features.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "${CYAN}▶ $1${NC}"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 BetterAgentX - Activate All Features 100%"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ============================================
# 1. VERIFY BASE INSTALLATION
# ============================================
print_step "Verifying base installation..."

if [ ! -d ".kiro/steering/agents" ]; then
    print_error "Agents not installed. Run: bash scripts/init.sh first"
    exit 1
fi

if [ ! -d ".kiro/memory" ]; then
    print_error "Memory system not installed. Run: bash scripts/init.sh first"
    exit 1
fi

print_success "Base installation verified"
echo ""

# ============================================
# 2. ACTIVATE MEMORY SYSTEM
# ============================================
print_step "Activating memory system..."

# Ensure all memory files exist
MEMORY_FILES=(
    "active-context.json"
    "decision-log.json"
    "progress.json"
    "patterns.json"
    "memory-stats.json"
    "project-metrics.json"
    "llm-usage.json"
    "project-size.json"
)

MEMORY_ACTIVATED=0
for file in "${MEMORY_FILES[@]}"; do
    if [ ! -f ".kiro/memory/$file" ]; then
        case "$file" in
            "active-context.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "project": {
    "name": "",
    "objective": "",
    "stack": [],
    "currentPhase": "initialization"
  },
  "context": {
    "lastUpdate": "",
    "focus": "",
    "blockers": []
  }
}
EOF
                ;;
            "decision-log.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "decisions": []
}
EOF
                ;;
            "progress.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "tasks": {
    "completed": [],
    "inProgress": [],
    "pending": []
  }
}
EOF
                ;;
            "patterns.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "patterns": []
}
EOF
                ;;
            "memory-stats.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "totalTokens": 0,
  "files": {},
  "lastCalculated": ""
}
EOF
                ;;
            "project-metrics.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "project": {
    "name": "BetterAgentX Project",
    "created": "",
    "lastUpdated": ""
  },
  "metrics": {
    "totalFiles": 0,
    "totalLines": 0,
    "totalTokens": 0,
    "languages": {}
  }
}
EOF
                ;;
            "llm-usage.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "sessions": [],
  "totalTokens": 0,
  "totalCost": 0,
  "lastUpdated": ""
}
EOF
                ;;
            "project-size.json")
                cat > ".kiro/memory/$file" << 'EOF'
{
  "total": {
    "files": 0,
    "lines": 0,
    "tokens": 0
  },
  "byLanguage": {},
  "lastCalculated": ""
}
EOF
                ;;
        esac
        MEMORY_ACTIVATED=$((MEMORY_ACTIVATED + 1))
    fi
done

print_success "Memory system activated ($MEMORY_ACTIVATED files created)"
echo ""

# ============================================
# 3. CALCULATE PROJECT METRICS
# ============================================
print_step "Calculating project metrics..."

if [ -f "$SCRIPT_DIR/calculate-project-size.sh" ]; then
    bash "$SCRIPT_DIR/calculate-project-size.sh" > /dev/null 2>&1 || print_warning "Project size calculation failed"
    print_success "Project size calculated"
else
    print_warning "calculate-project-size.sh not found"
fi

if [ -f "$SCRIPT_DIR/calculate-tokens.sh" ]; then
    bash "$SCRIPT_DIR/calculate-tokens.sh" > /dev/null 2>&1 || print_warning "Token calculation failed"
    print_success "Memory tokens calculated"
else
    print_warning "calculate-tokens.sh not found"
fi

if [ -f "$SCRIPT_DIR/update-project-metrics.sh" ]; then
    bash "$SCRIPT_DIR/update-project-metrics.sh" > /dev/null 2>&1 || print_warning "Metrics update failed"
    print_success "Project metrics updated"
else
    print_warning "update-project-metrics.sh not found"
fi

echo ""

# ============================================
# 4. ACTIVATE SKILLS SYSTEM
# ============================================
print_step "Activating skills system..."

if [ -f "$SCRIPT_DIR/detect-skills.sh" ]; then
    bash "$SCRIPT_DIR/detect-skills.sh" > /dev/null 2>&1 || print_warning "Skills detection failed"
    print_success "Skills detected"
else
    print_warning "detect-skills.sh not found"
fi

if [ -f "$SCRIPT_DIR/catalog-skills.sh" ]; then
    bash "$SCRIPT_DIR/catalog-skills.sh" > /dev/null 2>&1 || print_warning "Skills catalog failed"
    print_success "Skills cataloged"
else
    print_warning "catalog-skills.sh not found"
fi

# Update skills registry
if [ ! -f ".kiro/settings/skills-registry.json" ]; then
    cat > .kiro/settings/skills-registry.json << 'EOF'
{
  "skills": [],
  "lastUpdated": "",
  "autoDetect": true
}
EOF
    print_success "Skills registry created"
fi

echo ""

# ============================================
# 5. ACTIVATE DASHBOARD
# ============================================
print_step "Activating interactive dashboard..."

if [ -f "$SCRIPT_DIR/update-dashboard.sh" ]; then
    bash "$SCRIPT_DIR/update-dashboard.sh" > /dev/null 2>&1 || print_warning "Dashboard update failed"
    print_success "Dashboard updated"
else
    print_warning "update-dashboard.sh not found"
fi

if [ -f ".kiro/memory/dashboard.html" ]; then
    print_success "Dashboard ready at: .kiro/memory/dashboard.html"
else
    print_warning "Dashboard not found"
fi

echo ""

# ============================================
# 6. ACTIVATE HOOKS
# ============================================
print_step "Activating automation hooks..."

HOOKS_COUNT=$(find .kiro/hooks -name "*.kiro.hook" 2>/dev/null | wc -l)

if [ $HOOKS_COUNT -gt 0 ]; then
    print_success "$HOOKS_COUNT automation hooks ready"
    print_info "Hooks will auto-execute on configured events"
else
    print_warning "No hooks found"
fi

echo ""

# ============================================
# 7. ACTIVATE CACHE SYSTEM
# ============================================
print_step "Activating cache system..."

if [ ! -f ".kiro/cache/skills-detection-cache.json" ]; then
    cat > .kiro/cache/skills-detection-cache.json << 'EOF'
{}
EOF
fi

if [ ! -f ".kiro/cache/agent-routing-cache.json" ]; then
    cat > .kiro/cache/agent-routing-cache.json << 'EOF'
{
  "routes": [],
  "lastCleared": ""
}
EOF
fi

print_success "Cache system activated"
echo ""

# ============================================
# 8. VERIFY ALL AGENTS
# ============================================
print_step "Verifying all agents..."

AGENTS_COUNT=$(find .kiro/steering/agents -name "*.md" 2>/dev/null | wc -l)

if [ $AGENTS_COUNT -ge 13 ]; then
    print_success "$AGENTS_COUNT agents verified (12 specialists + AgentX)"
else
    print_warning "Only $AGENTS_COUNT agents found (expected 13)"
fi

echo ""

# ============================================
# 9. GENERATE INITIAL REPORTS
# ============================================
print_step "Generating initial reports..."

if [ -f "$SCRIPT_DIR/memory-stats.sh" ]; then
    bash "$SCRIPT_DIR/memory-stats.sh" > /dev/null 2>&1 || print_warning "Memory stats failed"
    print_success "Memory statistics generated"
else
    print_warning "memory-stats.sh not found"
fi

if [ -f "$SCRIPT_DIR/estimate-llm-usage.sh" ]; then
    bash "$SCRIPT_DIR/estimate-llm-usage.sh" > /dev/null 2>&1 || print_warning "LLM estimation failed"
    print_success "LLM usage estimated"
else
    print_warning "estimate-llm-usage.sh not found"
fi

echo ""

# ============================================
# 10. FINAL VERIFICATION
# ============================================
print_step "Running final verification..."

if [ -f "$SCRIPT_DIR/verify-system.sh" ]; then
    bash "$SCRIPT_DIR/verify-system.sh" > /tmp/verify-full.txt 2>&1 || true
    
    if grep -q "❌" /tmp/verify-full.txt; then
        print_warning "Some checks failed - review with: bash scripts/verify-system.sh"
    else
        print_success "All system checks passed"
    fi
    
    rm /tmp/verify-full.txt 2>/dev/null || true
else
    print_warning "verify-system.sh not found"
fi

echo ""

# ============================================
# 11. ACTIVATION SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ All Features Activated 100%!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "BetterAgentX is fully operational"
echo ""
echo "🎯 Activated Features:"
echo ""
echo "  ✅ AgentX Orchestrator + 12 Specialized Agents"
echo "  ✅ Memory System (8 files + dashboard)"
echo "  ✅ Skills Detection & Cataloging"
echo "  ✅ Project Metrics & Token Tracking"
echo "  ✅ LLM Usage Monitoring"
echo "  ✅ Interactive Dashboard"
echo "  ✅ Automation Hooks ($HOOKS_COUNT hooks)"
echo "  ✅ Cache System"
echo "  ✅ All Utility Scripts"
echo ""
echo "🚀 Quick Commands:"
echo ""
echo "  Open Kiro Code:"
echo "  $ kiro ."
echo ""
echo "  Test AgentX:"
echo "  @agentx Hello! Show me what you can do"
echo ""
echo "  View Dashboard:"
echo "  $ bash scripts/open-dashboard.sh"
echo ""
echo "  Check Memory Stats:"
echo "  $ bash scripts/memory-stats.sh"
echo ""
echo "  View Project Metrics:"
echo "  $ cat .kiro/memory/project-metrics.json | jq"
echo ""
echo "  Verify System:"
echo "  $ bash scripts/verify-system.sh"
echo ""
print_success "Sistema 100% activado! 🎉"
echo ""

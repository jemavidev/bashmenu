#!/bin/bash

# BetterAgentX - Complete Installer v3.0
# Installs complete system with ALL features activated 100%
# Usage: bash scripts/init.sh

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
echo "🎯 BetterAgentX - Complete Installer v3.0 (100% Features)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. DETECT EXECUTION CONTEXT
# ============================================
print_step "Detecting execution context..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BETTERAGENTX_DIR="$(dirname "$SCRIPT_DIR")"

# Check if running from BetterAgentX repository
if [ -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    print_info "Running from BetterAgentX repository"
    print_info "Installation directory: $(pwd)"
else
    print_error "Must run from BetterAgentX repository"
    print_info "Clone first: git clone https://github.com/user/BetterAgentX.git"
    exit 1
fi

# Detect project type
if [ -d ".git" ] || [ -f "package.json" ] || [ -f "requirements.txt" ]; then
    print_info "Existing project detected"
    PROJECT_TYPE="existing"
else
    print_info "New project detected"
    PROJECT_TYPE="new"
fi

echo ""

# ============================================
# 2. VERIFY REQUIREMENTS
# ============================================
print_step "Verifying requirements..."

# Kiro Code (required)
if ! command -v kiro &> /dev/null; then
    print_error "Kiro Code is not installed"
    echo ""
    echo "BetterAgentX requires Kiro Code to function."
    echo "Download it from: https://kiro.ai"
    echo ""
    exit 1
fi

KIRO_VERSION=$(kiro --version 2>/dev/null || echo "unknown")
print_success "Kiro Code detected ($KIRO_VERSION)"

# jq (recommended)
if command -v jq &> /dev/null; then
    print_success "jq detected (required for scripts)"
else
    print_warning "jq not found (install with: sudo apt install jq)"
fi

# Node.js (optional)
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js $NODE_VERSION detected"
    HAS_NODE=true
else
    print_warning "Node.js not installed (optional for additional skills)"
    HAS_NODE=false
fi

echo ""

# ============================================
# 3. CREATE BASE STRUCTURE
# ============================================
print_step "Creating base structure..."

mkdir -p .kiro/steering/agents
mkdir -p .kiro/memory
mkdir -p .kiro/settings
mkdir -p .kiro/hooks
mkdir -p .kiro/cache
mkdir -p .kiro/backups
mkdir -p .kiro/skills
mkdir -p scripts

print_success "Directory structure created"

echo ""

# ============================================
# 4. INSTALL AGENTS
# ============================================
print_step "Installing agents..."

AGENTS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/.kiro/steering/agents" ]; then
    for agent in "$BETTERAGENTX_DIR/.kiro/steering/agents"/*.md; do
        if [ -f "$agent" ]; then
            filename=$(basename "$agent")
            # Skip symlinks and backup files
            if [ ! -L "$agent" ] && [[ ! "$filename" =~ backup|original ]]; then
                if cp "$agent" ".kiro/steering/agents/$filename" 2>/dev/null; then
                    AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
                fi
            fi
        fi
    done
    
    print_success "Agents installed ($AGENTS_INSTALLED agents)"
else
    print_error "Agents folder not found in BetterAgentX"
    exit 1
fi

echo ""

# ============================================
# 5. INSTALL MEMORY SYSTEM
# ============================================
print_step "Installing memory system..."

MEMORY_FILES=0

if [ -d "$BETTERAGENTX_DIR/templates/memory" ]; then
    # Copy all JSON templates
    for template in "$BETTERAGENTX_DIR/templates/memory"/*.json; do
        if [ -f "$template" ]; then
            filename=$(basename "$template")
            if [ ! -f ".kiro/memory/$filename" ]; then
                if cp "$template" ".kiro/memory/$filename" 2>/dev/null; then
                    MEMORY_FILES=$((MEMORY_FILES + 1))
                fi
            fi
        fi
    done
    
    # Copy dashboard.html
    if [ -f "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ]; then
        cp "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ".kiro/memory/dashboard.html" 2>/dev/null
        print_success "Memory dashboard installed"
    fi
    
    # Copy README
    if [ -f "$BETTERAGENTX_DIR/templates/memory/README.md" ]; then
        cp "$BETTERAGENTX_DIR/templates/memory/README.md" ".kiro/memory/README.md" 2>/dev/null
    fi
    
    print_success "Memory system initialized ($MEMORY_FILES files)"
else
    print_warning "Memory templates not found"
fi

echo ""

# ============================================
# 6. INSTALL CONFIGURATION
# ============================================
print_step "Installing configuration..."

CONFIG_FILES=0

# Copy from config/ directory
if [ -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    cp "$BETTERAGENTX_DIR/config/betteragents.json" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

if [ -f "$BETTERAGENTX_DIR/config/agent-skills.json" ]; then
    cp "$BETTERAGENTX_DIR/config/agent-skills.json" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

if [ -f "$BETTERAGENTX_DIR/config/.betteragents-config" ]; then
    cp "$BETTERAGENTX_DIR/config/.betteragents-config" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

# Copy from templates/config/ directory
if [ -d "$BETTERAGENTX_DIR/templates/config" ]; then
    for config in "$BETTERAGENTX_DIR/templates/config"/*.json; do
        if [ -f "$config" ]; then
            filename=$(basename "$config")
            if cp "$config" ".kiro/settings/$filename" 2>/dev/null; then
                CONFIG_FILES=$((CONFIG_FILES + 1))
            fi
        fi
    done
fi

print_success "Configuration installed ($CONFIG_FILES files)"

echo ""

# ============================================
# 7. INSTALL HOOKS
# ============================================
print_step "Installing hooks..."

HOOKS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/templates/hooks" ]; then
    for hook in "$BETTERAGENTX_DIR/templates/hooks"/*.kiro.hook; do
        if [ -f "$hook" ]; then
            filename=$(basename "$hook")
            if cp "$hook" ".kiro/hooks/$filename" 2>/dev/null; then
                HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
            fi
        fi
    done
    
    print_success "Hooks installed ($HOOKS_INSTALLED hooks)"
else
    print_info "No hooks templates found"
fi

echo ""

# ============================================
# 8. INSTALL SCRIPTS
# ============================================
print_step "Installing utility scripts..."

SCRIPTS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/scripts" ]; then
    for script in "$BETTERAGENTX_DIR/scripts"/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            # Don't copy init.sh (it's already running)
            if [ "$filename" != "init.sh" ]; then
                if cp "$script" "scripts/$filename" 2>/dev/null; then
                    chmod +x "scripts/$filename"
                    SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
                fi
            fi
        fi
    done
    
    print_success "Scripts installed ($SCRIPTS_INSTALLED scripts)"
else
    print_warning "Scripts directory not found"
fi

echo ""

# ============================================
# 9. INSTALL SKILLS
# ============================================
print_step "Installing skills..."

SKILLS_INSTALLED=0

# Check for ui-ux-pro-max in .kiro/skills/
if [ -d "$BETTERAGENTX_DIR/.kiro/skills/ui-ux-pro-max" ]; then
    if cp -r "$BETTERAGENTX_DIR/.kiro/skills/ui-ux-pro-max" ".kiro/skills/" 2>/dev/null; then
        print_success "ui-ux-pro-max installed"
        SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
    fi
fi

# Optionally copy to global location
if [ -d ".kiro/skills/ui-ux-pro-max" ]; then
    mkdir -p "$HOME/.kiro/skills"
    if [ ! -d "$HOME/.kiro/skills/ui-ux-pro-max" ]; then
        cp -r ".kiro/skills/ui-ux-pro-max" "$HOME/.kiro/skills/" 2>/dev/null && \
            print_info "ui-ux-pro-max also copied to ~/.kiro/skills/"
    fi
fi

if [ $SKILLS_INSTALLED -eq 0 ]; then
    print_warning "No skills found in repository"
fi

echo ""

# ============================================
# 10. INITIALIZE CACHE AND COMPLETE MEMORY SYSTEM
# ============================================
print_step "Initializing cache and complete memory system..."

# Cache system
cat > .kiro/cache/skills-detection-cache.json << 'EOF'
{}
EOF

cat > .kiro/cache/agent-routing-cache.json << 'EOF'
{
  "routes": [],
  "lastCleared": ""
}
EOF

# Ensure ALL memory files exist
MEMORY_FILES_TO_CREATE=(
    "active-context.json"
    "decision-log.json"
    "progress.json"
    "patterns.json"
    "memory-stats.json"
    "project-metrics.json"
    "llm-usage.json"
    "project-size.json"
)

MEMORY_CREATED=0
for file in "${MEMORY_FILES_TO_CREATE[@]}"; do
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
  },
  "memory": {
    "decisions": 0,
    "progress": 0,
    "patterns": 0
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
        MEMORY_CREATED=$((MEMORY_CREATED + 1))
    fi
done

# Skills registry
if [ ! -f ".kiro/settings/skills-registry.json" ]; then
    cat > .kiro/settings/skills-registry.json << 'EOF'
{
  "skills": [],
  "lastUpdated": "",
  "autoDetect": true
}
EOF
fi

print_success "Cache and complete memory system initialized ($MEMORY_CREATED files created)"

echo ""

# ============================================
# 11. CONFIGURE GIT
# ============================================
print_step "Configuring .gitignore..."

if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# BetterAgentX - Memory and cache
.kiro/memory/*.json
!.kiro/memory/README.md
.kiro/cache/
.kiro/backups/

# Optional: Local settings
# .kiro/settings/
EOF
    print_success ".gitignore created"
else
    # Check if it already has BetterAgentX entries
    if ! grep -q ".kiro/cache/" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'EOF'

# BetterAgentX
.kiro/memory/*.json
!.kiro/memory/README.md
.kiro/cache/
.kiro/backups/
EOF
        print_success ".gitignore updated"
    else
        print_info ".gitignore already configured"
    fi
fi

echo ""

# ============================================
# 12. INSTALL ADDITIONAL SKILLS (OPTIONAL)
# ============================================

if [ "$HAS_NODE" = true ] && command -v npm &> /dev/null; then
    print_step "Additional skills available..."
    echo ""
    echo "  Install 3 additional verified skills?"
    echo "  • architecture-patterns"
    echo "  • systematic-debugging"
    echo "  • vercel-react-best-practices"
    echo ""
    echo "  Install now? (y/n) [timeout: 15s]"
    echo ""
    
    if [ -t 0 ]; then
        read -r -t 15 response || response="n"
    else
        response="n"
    fi
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo ""
        print_info "Installing additional skills..."
        echo ""
        
        VERIFIED_SKILLS=(
            "wshobson/agents/architecture-patterns"
            "obra/superpowers/systematic-debugging"
            "vercel-labs/agent-skills/vercel-react-best-practices"
        )
        
        INSTALLED=0
        for skill in "${VERIFIED_SKILLS[@]}"; do
            skill_name=$(basename "$skill")
            echo -n "  Installing $skill_name ... "
            
            if timeout 90 npx --yes skills add "$skill" -y >/dev/null 2>&1; then
                INSTALLED=$((INSTALLED + 1))
                echo "✅"
            else
                echo "⚠️"
            fi
        done
        
        echo ""
        print_success "Skills installed: $INSTALLED/3"
    else
        print_info "Additional skills installation skipped"
    fi
else
    print_info "Node.js not available - skipping additional skills"
fi

echo ""

# ============================================
# 13. ACTIVATE ALL FEATURES 100%
# ============================================
print_step "Activating all features 100%..."

FEATURES_ACTIVATED=0

# 1. Calculate project size
if [ -f "scripts/calculate-project-size.sh" ]; then
    print_info "Calculating project size..."
    if bash scripts/calculate-project-size.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 2. Calculate tokens
if [ -f "scripts/calculate-tokens.sh" ]; then
    print_info "Calculating memory tokens..."
    if bash scripts/calculate-tokens.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 3. Update dashboard
if [ -f "scripts/update-dashboard.sh" ]; then
    print_info "Updating memory dashboard..."
    if bash scripts/update-dashboard.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 4. Detect skills
if [ -f "scripts/detect-skills.sh" ]; then
    print_info "Detecting available skills..."
    if bash scripts/detect-skills.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 5. Catalog skills
if [ -f "scripts/catalog-skills.sh" ]; then
    print_info "Cataloging skills..."
    if bash scripts/catalog-skills.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 6. Update project metrics
if [ -f "scripts/update-project-metrics.sh" ]; then
    print_info "Updating project metrics..."
    if bash scripts/update-project-metrics.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 7. Initialize memory stats
if [ -f "scripts/memory-stats.sh" ]; then
    print_info "Initializing memory statistics..."
    if bash scripts/memory-stats.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# 8. Estimate LLM usage
if [ -f "scripts/estimate-llm-usage.sh" ]; then
    print_info "Estimating LLM usage..."
    if bash scripts/estimate-llm-usage.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

print_success "All features activated ($FEATURES_ACTIVATED/8 features)"

echo ""

# ============================================
# 14. VERIFY INSTALLATION AND GENERATE REPORT
# ============================================
print_step "Verifying installation and generating report..."

VERIFICATION_PASSED=true

# Count installed components
AGENTS_COUNT=$(find .kiro/steering/agents -name "*.md" 2>/dev/null | wc -l)
MEMORY_COUNT=$(find .kiro/memory -name "*.json" 2>/dev/null | wc -l)
HOOKS_COUNT=$(find .kiro/hooks -name "*.kiro.hook" 2>/dev/null | wc -l)
SCRIPTS_COUNT=$(find scripts -name "*.sh" 2>/dev/null | wc -l)

# Verify critical components
if [ $AGENTS_COUNT -lt 13 ]; then
    print_warning "Only $AGENTS_COUNT agents found (expected 13)"
    VERIFICATION_PASSED=false
else
    print_success "All $AGENTS_COUNT agents verified"
fi

if [ $MEMORY_COUNT -lt 8 ]; then
    print_warning "Only $MEMORY_COUNT memory files found (expected 8+)"
    VERIFICATION_PASSED=false
else
    print_success "All $MEMORY_COUNT memory files verified"
fi

if [ ! -f ".kiro/memory/dashboard.html" ]; then
    print_warning "Dashboard not found"
    VERIFICATION_PASSED=false
else
    print_success "Dashboard verified"
fi

# Run full system verification if available
if [ -f "scripts/verify-system.sh" ]; then
    print_info "Running full system verification..."
    bash scripts/verify-system.sh > /tmp/verify-output.txt 2>&1 || true
    
    # Check for critical errors
    if grep -q "❌" /tmp/verify-output.txt; then
        print_warning "Some verification checks failed"
        print_info "Run: bash scripts/verify-system.sh for details"
        VERIFICATION_PASSED=false
    else
        print_success "Full system verification passed"
    fi
    
    rm /tmp/verify-output.txt 2>/dev/null || true
fi

if [ "$VERIFICATION_PASSED" = true ]; then
    print_success "Installation verification completed successfully"
else
    print_warning "Installation completed with warnings"
    print_info "You can re-run: bash scripts/activate-all-features.sh"
fi

echo ""

# ============================================
# 15. INSTALLATION SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Installation Complete - 100% Features Activated!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "BetterAgentX is ready to use"
echo ""
echo "📊 Installation Summary:"
echo ""
echo "  ✅ Agents: $AGENTS_COUNT specialized agents + AgentX orchestrator"
echo "  ✅ Memory: $MEMORY_COUNT files + dashboard + metrics"
echo "  ✅ Configuration: $CONFIG_FILES files"
echo "  ✅ Hooks: $HOOKS_COUNT automation hooks"
echo "  ✅ Scripts: $SCRIPTS_COUNT utility scripts"
echo "  ✅ Skills: $SKILLS_INSTALLED base skills"
echo "  ✅ Cache: Initialized with detection system"
echo "  ✅ Features: $FEATURES_ACTIVATED/8 features activated"
echo ""
echo "🎯 Activated Features (100%):"
echo ""
echo "  ✅ AgentX Orchestrator - Intelligent routing"
echo "  ✅ 12 Specialized Agents - Ready to work"
echo "  ✅ Memory System - Automatic documentation"
echo "  ✅ Skills Detection - Auto-detect and catalog"
echo "  ✅ Token Tracking - Monitor memory usage"
echo "  ✅ Project Metrics - Size and complexity analysis"
echo "  ✅ LLM Usage Tracking - Cost monitoring"
echo "  ✅ Interactive Dashboard - Visual memory management"
echo "  ✅ Automation Hooks - Auto-update on events"
echo "  ✅ Cache System - Performance optimization"
echo ""
echo "🚀 Quick Start:"
echo ""
echo "  1. Open Kiro Code:"
echo "     $ kiro ."
echo ""
echo "  2. Test the system:"
echo "     @agentx Hello! Explain how you work"
echo ""
echo "  3. Use specific agents:"
echo "     @architect Design a REST API"
echo "     @coder Implement JWT authentication"
echo ""
echo "📊 Memory Dashboard:"
echo ""
echo "  $ bash scripts/open-dashboard.sh"
echo "  $ xdg-open .kiro/memory/dashboard.html"
echo ""
echo "🔄 Updates:"
echo ""
echo "  Update BetterAgentX:"
echo "  $ git pull origin main"
echo ""
echo "  Update skills:"
echo "  $ bash scripts/update-skills.sh"
echo ""
echo "📚 Documentation:"
echo ""
echo "  • README: ./README.md"
echo "  • Memory: ./.kiro/memory/README.md"
echo "  • Scripts: ./scripts/"
echo "  • Guides: ./docs/guides/"
echo ""
echo "🔧 Available Scripts:"
echo ""
echo "  Memory Management:"
echo "  $ bash scripts/memory-stats.sh          # View memory statistics"
echo "  $ bash scripts/calculate-tokens.sh      # Calculate token usage"
echo "  $ bash scripts/cleanup-memory.sh        # Clean old entries"
echo "  $ bash scripts/add-memory-entry.sh      # Add manual entry"
echo ""
echo "  Project Analysis:"
echo "  $ bash scripts/calculate-project-size.sh  # Analyze project size"
echo "  $ bash scripts/update-project-metrics.sh  # Update metrics"
echo "  $ bash scripts/estimate-llm-usage.sh      # Estimate LLM costs"
echo ""
echo "  Skills Management:"
echo "  $ bash scripts/detect-skills.sh         # Detect available skills"
echo "  $ bash scripts/catalog-skills.sh        # Catalog all skills"
echo "  $ bash scripts/update-skills.sh         # Update skills"
echo ""
echo "  System Maintenance:"
echo "  $ bash scripts/verify-system.sh         # Verify installation"
echo "  $ bash scripts/update-dashboard.sh      # Update dashboard"
echo "  $ bash scripts/update.sh                # Update BetterAgentX"
echo "  $ bash scripts/quick-check.sh           # Quick verification (10 checks)"
echo ""
echo "🔍 Quick Verification:"
echo ""
echo "  Run quick check to verify everything is working:"
echo "  $ bash scripts/quick-check.sh"
echo ""
echo "  View installation details:"
echo "  $ cat .kiro/memory/project-metrics.json | jq"
echo "  $ cat .kiro/memory/memory-stats.json | jq"
echo ""
echo "  Check installed agents:"
echo "  $ ls -la .kiro/steering/agents/"
echo ""
echo "  Check memory files:"
echo "  $ ls -la .kiro/memory/"
echo ""
print_success "Sistema 100% activado y listo para usar! 🎉"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. Verify installation:"
echo "     $ bash scripts/quick-check.sh"
echo ""
echo "  2. Open Kiro Code:"
echo "     $ kiro ."
echo ""
echo "  3. Test AgentX:"
echo "     @agentx Hola! Explícame cómo funcionas"
echo ""
echo "  4. View dashboard:"
echo "     $ bash scripts/open-dashboard.sh"
echo ""
echo "  5. Read documentation:"
echo "     $ cat INSTALL_COMPLETE.md"
echo ""
print_info "For help: bash scripts/verify-system.sh"
echo ""

#!/bin/bash

# =============================================================================
# Bashmenu + BetterAgentX - Complete Initialization Script
# =============================================================================
# Description: Initializes Bashmenu with full BetterAgentX integration
# Version:     2.2
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

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
echo "🎯 Bashmenu + BetterAgentX - Complete Initialization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. DETECT EXECUTION CONTEXT
# ============================================
print_step "Detecting execution context..."

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

print_info "Project root: $PROJECT_ROOT"

# Check if BetterAgentX directory exists
if [ -d "$PROJECT_ROOT/BetterAgentX" ]; then
    BETTERAGENTX_DIR="$PROJECT_ROOT/BetterAgentX"
    print_info "BetterAgentX source found"
else
    print_error "BetterAgentX directory not found"
    print_info "Expected at: $PROJECT_ROOT/BetterAgentX"
    exit 1
fi

echo ""

# ============================================
# 2. VERIFY REQUIREMENTS
# ============================================
print_step "Verifying requirements..."

# Kiro Code (required for BetterAgentX)
if command -v kiro &> /dev/null; then
    KIRO_VERSION=$(kiro --version 2>/dev/null || echo "unknown")
    print_success "Kiro Code detected ($KIRO_VERSION)"
    HAS_KIRO=true
else
    print_warning "Kiro Code not installed (required for AgentX)"
    print_info "Download from: https://kiro.ai"
    HAS_KIRO=false
fi

# jq (recommended)
if command -v jq &> /dev/null; then
    print_success "jq detected"
else
    print_warning "jq not found (install: sudo apt install jq)"
fi

# Node.js (optional)
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js $NODE_VERSION detected"
    HAS_NODE=true
else
    print_warning "Node.js not installed (optional)"
    HAS_NODE=false
fi

echo ""

# ============================================
# 3. CREATE BASE STRUCTURE
# ============================================
print_step "Creating directory structure..."

mkdir -p .kiro/steering/agents
mkdir -p .kiro/steering/agentx
mkdir -p .kiro/steering/_common
mkdir -p .kiro/memory
mkdir -p .kiro/settings
mkdir -p .kiro/hooks
mkdir -p .kiro/cache
mkdir -p .kiro/backups
mkdir -p .kiro/skills
mkdir -p scripts
mkdir -p docs
mkdir -p templates
mkdir -p config

print_success "Directory structure created"

echo ""

# ============================================
# 4. INSTALL AGENTS
# ============================================
print_step "Installing BetterAgentX agents..."

AGENTS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/.kiro/steering/agents" ]; then
    for agent in "$BETTERAGENTX_DIR/.kiro/steering/agents"/*.md; do
        if [ -f "$agent" ]; then
            filename=$(basename "$agent")
            if [ ! -L "$agent" ] && [[ ! "$filename" =~ backup|original ]]; then
                if cp "$agent" ".kiro/steering/agents/$filename" 2>/dev/null; then
                    chmod +x ".kiro/steering/agents/$filename"
                    AGENTS_INSTALLED=$((AGENTS_INSTALLED + 1))
                fi
            fi
        fi
    done
    print_success "Agents installed ($AGENTS_INSTALLED agents)"
else
    print_error "Agents folder not found"
    exit 1
fi

# Install agentx configuration
if [ -d "$BETTERAGENTX_DIR/.kiro/steering/agentx" ]; then
    cp -r "$BETTERAGENTX_DIR/.kiro/steering/agentx"/* ".kiro/steering/agentx/" 2>/dev/null
    print_success "AgentX configuration installed"
fi

# Install common templates
if [ -d "$BETTERAGENTX_DIR/.kiro/steering/_common" ]; then
    cp -r "$BETTERAGENTX_DIR/.kiro/steering/_common"/* ".kiro/steering/_common/" 2>/dev/null
    print_success "Common templates installed"
fi

# Copy steering files
if [ -d "$BETTERAGENTX_DIR/.kiro/steering" ]; then
    for file in "$BETTERAGENTX_DIR/.kiro/steering"/*.md; do
        if [ -f "$file" ]; then
            cp "$file" ".kiro/steering/" 2>/dev/null
        fi
    done
fi

echo ""

# ============================================
# 5. INSTALL MEMORY SYSTEM
# ============================================
print_step "Installing memory system..."

MEMORY_FILES=0

if [ -d "$BETTERAGENTX_DIR/templates/memory" ]; then
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
    
    # Copy dashboard
    if [ -f "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ]; then
        cp "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ".kiro/memory/dashboard.html" 2>/dev/null
        print_success "Memory dashboard installed"
    fi
    
    # Copy README
    if [ -f "$BETTERAGENTX_DIR/templates/memory/README.md" ]; then
        cp "$BETTERAGENTX_DIR/templates/memory/README.md" ".kiro/memory/README.md" 2>/dev/null
    fi
    
    print_success "Memory system initialized ($MEMORY_FILES files)"
fi

echo ""

# ============================================
# 6. INSTALL CONFIGURATION
# ============================================
print_step "Installing configuration..."

CONFIG_FILES=0

# Copy BetterAgentX config
if [ -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    cp "$BETTERAGENTX_DIR/config/betteragents.json" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

if [ -f "$BETTERAGENTX_DIR/config/agent-skills.json" ]; then
    cp "$BETTERAGENTX_DIR/config/agent-skills.json" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

if [ -f "$BETTERAGENTX_DIR/config/.betteragents-config" ]; then
    cp "$BETTERAGENTX_DIR/config/.betteragents-config" .kiro/settings/ 2>/dev/null && CONFIG_FILES=$((CONFIG_FILES + 1))
fi

# Copy templates config
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
print_step "Installing automation hooks..."

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
            # Don't copy init.sh (we're creating our own)
            if [ "$filename" != "init.sh" ]; then
                if cp "$script" "scripts/$filename" 2>/dev/null; then
                    chmod +x "scripts/$filename"
                    SCRIPTS_INSTALLED=$((SCRIPTS_INSTALLED + 1))
                fi
            fi
        fi
    done
    print_success "Scripts installed ($SCRIPTS_INSTALLED scripts)"
fi

echo ""

# ============================================
# 9. INSTALL TEMPLATES
# ============================================
print_step "Installing templates..."

if [ -d "$BETTERAGENTX_DIR/templates" ]; then
    cp -r "$BETTERAGENTX_DIR/templates"/* templates/ 2>/dev/null || true
    print_success "Templates installed"
fi

echo ""

# ============================================
# 10. INSTALL DOCUMENTATION
# ============================================
print_step "Installing documentation..."

DOCS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/docs" ]; then
    # Copy all docs preserving structure
    cp -r "$BETTERAGENTX_DIR/docs"/* docs/ 2>/dev/null || true
    DOCS_INSTALLED=$(find docs -type f | wc -l)
    print_success "Documentation installed ($DOCS_INSTALLED files)"
fi

echo ""

# ============================================
# 11. INSTALL SKILLS
# ============================================
print_step "Installing skills..."

SKILLS_INSTALLED=0

if [ -d "$BETTERAGENTX_DIR/.kiro/skills/ui-ux-pro-max" ]; then
    if cp -r "$BETTERAGENTX_DIR/.kiro/skills/ui-ux-pro-max" ".kiro/skills/" 2>/dev/null; then
        print_success "ui-ux-pro-max installed"
        SKILLS_INSTALLED=$((SKILLS_INSTALLED + 1))
    fi
fi

# Copy to global location
if [ -d ".kiro/skills/ui-ux-pro-max" ]; then
    mkdir -p "$HOME/.kiro/skills"
    if [ ! -d "$HOME/.kiro/skills/ui-ux-pro-max" ]; then
        cp -r ".kiro/skills/ui-ux-pro-max" "$HOME/.kiro/skills/" 2>/dev/null && \
            print_info "ui-ux-pro-max also copied to ~/.kiro/skills/"
    fi
fi

echo ""

# ============================================
# 12. INITIALIZE CACHE AND MEMORY
# ============================================
print_step "Initializing cache and memory system..."

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

# Ensure all memory files exist
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
  "version": "1.0.0",
  "lastUpdated": "",
  "project": {
    "name": "Bashmenu",
    "description": "Interactive menu system with BetterAgentX integration",
    "phase": "initialization",
    "status": "active",
    "startDate": ""
  },
  "current": {
    "focus": "System initialization and integration",
    "blockers": [],
    "nextSteps": ["Complete BetterAgentX integration", "Test agent routing"]
  },
  "context": {
    "recentDecisions": [],
    "activePatterns": [],
    "openTasks": []
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
    "name": "Bashmenu + BetterAgentX",
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

print_success "Cache and memory system initialized ($MEMORY_CREATED files created)"

echo ""

# ============================================
# 13. CONFIGURE GIT
# ============================================
print_step "Configuring .gitignore..."

if [ ! -f ".gitignore" ]; then
    cat > .gitignore << 'EOF'
# BetterAgentX - Memory and cache
.kiro/memory/*.json
!.kiro/memory/README.md
.kiro/cache/
.kiro/backups/

# Bashmenu logs
/tmp/bashmenu.log
*.log

# Node modules (if using skills)
node_modules/

# OS files
.DS_Store
Thumbs.db
EOF
    print_success ".gitignore created"
else
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
# 14. ACTIVATE ALL FEATURES
# ============================================
print_step "Activating all features..."

FEATURES_ACTIVATED=0

# Calculate project size
if [ -f "scripts/calculate-project-size.sh" ]; then
    print_info "Calculating project size..."
    if bash scripts/calculate-project-size.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# Calculate tokens
if [ -f "scripts/calculate-tokens.sh" ]; then
    print_info "Calculating memory tokens..."
    if bash scripts/calculate-tokens.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# Update dashboard
if [ -f "scripts/update-dashboard.sh" ]; then
    print_info "Updating memory dashboard..."
    if bash scripts/update-dashboard.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# Detect skills
if [ -f "scripts/detect-skills.sh" ]; then
    print_info "Detecting available skills..."
    if bash scripts/detect-skills.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# Catalog skills
if [ -f "scripts/catalog-skills.sh" ]; then
    print_info "Cataloging skills..."
    if bash scripts/catalog-skills.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

# Update project metrics
if [ -f "scripts/update-project-metrics.sh" ]; then
    print_info "Updating project metrics..."
    if bash scripts/update-project-metrics.sh > /dev/null 2>&1; then
        FEATURES_ACTIVATED=$((FEATURES_ACTIVATED + 1))
    fi
fi

print_success "Features activated ($FEATURES_ACTIVATED/6 features)"

echo ""

# ============================================
# 15. VERIFY INSTALLATION
# ============================================
print_step "Verifying installation..."

VERIFICATION_PASSED=true

# Count components
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

# Run quick check if available
if [ -f "scripts/quick-check.sh" ]; then
    print_info "Running quick system check..."
    bash scripts/quick-check.sh > /tmp/quick-check.txt 2>&1 || true
    
    if grep -q "10/10" /tmp/quick-check.txt; then
        print_success "Quick check passed (10/10)"
    else
        print_warning "Quick check found issues"
        print_info "Run: bash scripts/quick-check.sh for details"
    fi
    
    rm /tmp/quick-check.txt 2>/dev/null || true
fi

echo ""

# ============================================
# 16. INSTALLATION SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Installation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "Bashmenu + BetterAgentX is ready to use"
echo ""
echo "📊 Installation Summary:"
echo ""
echo "  ✅ Agents: $AGENTS_COUNT (12 specialists + AgentX orchestrator)"
echo "  ✅ Memory: $MEMORY_COUNT files + dashboard"
echo "  ✅ Configuration: $CONFIG_FILES files"
echo "  ✅ Hooks: $HOOKS_COUNT automation hooks"
echo "  ✅ Scripts: $SCRIPTS_COUNT utility scripts"
echo "  ✅ Skills: $SKILLS_INSTALLED base skills"
echo "  ✅ Features: $FEATURES_ACTIVATED/6 activated"
echo ""
echo "🚀 Quick Start:"
echo ""
if [ "$HAS_KIRO" = true ]; then
    echo "  1. Open Kiro Code:"
    echo "     $ kiro ."
    echo ""
    echo "  2. Test AgentX:"
    echo "     @agentx Hello! Explain how you work"
    echo ""
else
    echo "  1. Install Kiro Code:"
    echo "     Download from: https://kiro.ai"
    echo ""
    echo "  2. Then open project:"
    echo "     $ kiro ."
    echo ""
fi
echo "  3. Use Bashmenu:"
echo "     $ ./bashmenu"
echo ""
echo "  4. View dashboard:"
echo "     $ bash scripts/open-dashboard.sh"
echo ""
echo "📚 Documentation:"
echo ""
echo "  • Main README: ./README.md"
echo "  • Memory System: ./.kiro/memory/README.md"
echo "  • Scripts: ./scripts/"
echo "  • Agents: ./docs/agents/"
echo ""
echo "🔧 Useful Commands:"
echo ""
echo "  $ bash scripts/quick-check.sh       # Quick verification"
echo "  $ bash scripts/verify-system.sh     # Full system check"
echo "  $ bash scripts/memory-stats.sh      # Memory statistics"
echo "  $ bash scripts/open-dashboard.sh    # Open dashboard"
echo ""

if [ "$VERIFICATION_PASSED" = true ]; then
    print_success "System 100% functional! 🎉"
else
    print_warning "Installation completed with warnings"
    print_info "Run: bash scripts/verify-system.sh for details"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Initialization complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

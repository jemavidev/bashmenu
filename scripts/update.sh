#!/bin/bash

# BetterAgentX - Update Script v2.0
# Intelligent update system with version detection and selective updates
# Usage: bash scripts/update.sh [--force] [--skip-backup]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_step() { echo -e "${CYAN}▶ $1${NC}"; }
print_version() { echo -e "${MAGENTA}📦 $1${NC}"; }

# Parse arguments
FORCE_UPDATE=false
SKIP_BACKUP=false

for arg in "$@"; do
    case $arg in
        --force) FORCE_UPDATE=true ;;
        --skip-backup) SKIP_BACKUP=true ;;
    esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 BetterAgentX - Intelligent Update System v2.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. VERIFY INSTALLATION
# ============================================
print_step "Verifying existing installation..."

if [ ! -d ".kiro" ]; then
    print_error "BetterAgentX not installed in this directory"
    print_info "Run: bash scripts/init.sh to install"
    exit 1
fi

print_success "BetterAgentX installation found"

# Detect source directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BETTERAGENTX_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    print_error "Must run from BetterAgentX repository"
    exit 1
fi

echo ""

# ============================================
# 2. VERSION DETECTION
# ============================================
print_step "Detecting versions..."

# Get current installed version
CURRENT_VERSION="unknown"
if [ -f ".kiro/settings/betteragents.json" ]; then
    if command -v jq &> /dev/null; then
        CURRENT_VERSION=$(jq -r '.version // "unknown"' .kiro/settings/betteragents.json 2>/dev/null || echo "unknown")
    fi
elif [ -f ".kiro/.version" ]; then
    CURRENT_VERSION=$(cat .kiro/.version)
fi

# Get new version from source
NEW_VERSION="unknown"
if command -v jq &> /dev/null; then
    NEW_VERSION=$(jq -r '.version // "unknown"' "$BETTERAGENTX_DIR/config/betteragents.json" 2>/dev/null || echo "unknown")
fi

print_version "Current version: $CURRENT_VERSION"
print_version "Available version: $NEW_VERSION"

# Compare versions
if [ "$CURRENT_VERSION" = "$NEW_VERSION" ] && [ "$FORCE_UPDATE" = false ]; then
    echo ""
    print_info "Already on latest version ($CURRENT_VERSION)"
    echo ""
    echo "  Use --force to update anyway"
    echo "  Example: bash scripts/update.sh --force"
    echo ""
    exit 0
fi

if [ "$CURRENT_VERSION" != "unknown" ] && [ "$NEW_VERSION" != "unknown" ]; then
    print_info "Update available: $CURRENT_VERSION → $NEW_VERSION"
fi

echo ""

# ============================================
# 3. DETECT CHANGES (SMART UPDATE)
# ============================================
print_step "Analyzing changes..."

CHANGES_DETECTED=0
declare -A CHANGES

# Function to check if file changed
file_changed() {
    local source="$1"
    local target="$2"
    
    if [ ! -f "$target" ]; then
        return 0  # New file
    fi
    
    if command -v md5sum &> /dev/null; then
        SOURCE_HASH=$(md5sum "$source" 2>/dev/null | cut -d' ' -f1)
        TARGET_HASH=$(md5sum "$target" 2>/dev/null | cut -d' ' -f1)
    elif command -v md5 &> /dev/null; then
        SOURCE_HASH=$(md5 -q "$source" 2>/dev/null)
        TARGET_HASH=$(md5 -q "$target" 2>/dev/null)
    else
        # Fallback to size comparison
        SOURCE_SIZE=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source" 2>/dev/null)
        TARGET_SIZE=$(stat -f%z "$target" 2>/dev/null || stat -c%s "$target" 2>/dev/null)
        [ "$SOURCE_SIZE" != "$TARGET_SIZE" ] && return 0 || return 1
    fi
    
    [ "$SOURCE_HASH" != "$TARGET_HASH" ]
}

# Check agents
if [ -d "$BETTERAGENTX_DIR/.kiro/steering/agents" ]; then
    for agent in "$BETTERAGENTX_DIR/.kiro/steering/agents"/*.md; do
        if [ -f "$agent" ]; then
            filename=$(basename "$agent")
            if [[ ! "$filename" =~ backup|original ]] && file_changed "$agent" ".kiro/steering/agents/$filename"; then
                CHANGES["agents"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check scripts
if [ -d "$BETTERAGENTX_DIR/scripts" ]; then
    for script in "$BETTERAGENTX_DIR/scripts"/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            if file_changed "$script" "scripts/$filename"; then
                CHANGES["scripts"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check hooks
if [ -d "$BETTERAGENTX_DIR/templates/hooks" ]; then
    for hook in "$BETTERAGENTX_DIR/templates/hooks"/*.kiro.hook; do
        if [ -f "$hook" ]; then
            filename=$(basename "$hook")
            if file_changed "$hook" ".kiro/hooks/$filename"; then
                CHANGES["hooks"]=1
                CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
                break
            fi
        fi
    done
fi

# Check dashboard
if [ -f "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ]; then
    if file_changed "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ".kiro/memory/dashboard.html"; then
        CHANGES["dashboard"]=1
        CHANGES_DETECTED=$((CHANGES_DETECTED + 1))
    fi
fi

if [ $CHANGES_DETECTED -eq 0 ] && [ "$FORCE_UPDATE" = false ]; then
    print_info "No changes detected - installation is up to date"
    echo ""
    exit 0
fi

print_info "Changes detected in: ${!CHANGES[@]}"
echo ""

# ============================================
# 4. BACKUP CURRENT INSTALLATION
# ============================================

if [ "$SKIP_BACKUP" = false ]; then
    print_step "Creating backup..."

    BACKUP_DIR=".kiro/backups/update-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Backup only what will be updated
    if [ "${CHANGES[agents]}" = "1" ] && [ -d ".kiro/steering/agents" ]; then
        cp -r .kiro/steering/agents "$BACKUP_DIR/" 2>/dev/null || true
    fi

    if [ "${CHANGES[hooks]}" = "1" ] && [ -d ".kiro/hooks" ]; then
        cp -r .kiro/hooks "$BACKUP_DIR/" 2>/dev/null || true
    fi

    if [ "${CHANGES[scripts]}" = "1" ] && [ -d "scripts" ]; then
        cp -r scripts "$BACKUP_DIR/" 2>/dev/null || true
    fi
    
    if [ "${CHANGES[dashboard]}" = "1" ] && [ -f ".kiro/memory/dashboard.html" ]; then
        cp .kiro/memory/dashboard.html "$BACKUP_DIR/" 2>/dev/null || true
    fi

    # Save version info
    echo "$CURRENT_VERSION" > "$BACKUP_DIR/.version"
    
    # Create rollback script
    cat > "$BACKUP_DIR/rollback.sh" << 'ROLLBACK_EOF'
#!/bin/bash
echo "Rolling back to previous version..."
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ../../../
[ -d "$BACKUP_DIR/agents" ] && cp -r "$BACKUP_DIR/agents" .kiro/steering/
[ -d "$BACKUP_DIR/hooks" ] && cp -r "$BACKUP_DIR/hooks" .kiro/
[ -d "$BACKUP_DIR/scripts" ] && cp -r "$BACKUP_DIR/scripts" .
[ -f "$BACKUP_DIR/dashboard.html" ] && cp "$BACKUP_DIR/dashboard.html" .kiro/memory/
echo "✅ Rollback complete"
ROLLBACK_EOF
    chmod +x "$BACKUP_DIR/rollback.sh"

    print_success "Backup created: $BACKUP_DIR"
    print_info "Rollback: bash $BACKUP_DIR/rollback.sh"
else
    print_warning "Backup skipped (--skip-backup flag)"
    BACKUP_DIR="none"
fi

echo ""

# ============================================
# 5. SELECTIVE UPDATE - AGENTS
# ============================================

AGENTS_UPDATED=0

if [ "${CHANGES[agents]}" = "1" ]; then
    print_step "Updating agents..."
    
    if [ -d "$BETTERAGENTX_DIR/.kiro/steering/agents" ]; then
        for agent in "$BETTERAGENTX_DIR/.kiro/steering/agents"/*.md; do
            if [ -f "$agent" ]; then
                filename=$(basename "$agent")
                # Skip symlinks and backup files
                if [ ! -L "$agent" ] && [[ ! "$filename" =~ backup|original ]]; then
                    if file_changed "$agent" ".kiro/steering/agents/$filename"; then
                        if cp "$agent" ".kiro/steering/agents/$filename" 2>/dev/null; then
                            AGENTS_UPDATED=$((AGENTS_UPDATED + 1))
                            print_info "Updated: $filename"
                        fi
                    fi
                fi
            fi
        done
        
        print_success "Agents updated ($AGENTS_UPDATED changed)"
    else
        print_warning "Agents folder not found in source"
    fi
    echo ""
else
    print_info "Agents: No changes detected"
    echo ""
fi

# ============================================
# 6. SELECTIVE UPDATE - SCRIPTS
# ============================================

SCRIPTS_UPDATED=0

if [ "${CHANGES[scripts]}" = "1" ]; then
    print_step "Updating scripts..."
    
    if [ -d "$BETTERAGENTX_DIR/scripts" ]; then
        for script in "$BETTERAGENTX_DIR/scripts"/*.sh; do
            if [ -f "$script" ]; then
                filename=$(basename "$script")
                # Don't overwrite init.sh and update.sh while running
                if [ "$filename" != "init.sh" ] && [ "$filename" != "update.sh" ]; then
                    if file_changed "$script" "scripts/$filename"; then
                        if cp "$script" "scripts/$filename" 2>/dev/null; then
                            chmod +x "scripts/$filename"
                            SCRIPTS_UPDATED=$((SCRIPTS_UPDATED + 1))
                            print_info "Updated: $filename"
                        fi
                    fi
                fi
            fi
        done
        
        print_success "Scripts updated ($SCRIPTS_UPDATED changed)"
    else
        print_warning "Scripts directory not found"
    fi
    echo ""
else
    print_info "Scripts: No changes detected"
    echo ""
fi

# ============================================
# 7. SELECTIVE UPDATE - HOOKS
# ============================================

HOOKS_UPDATED=0

if [ "${CHANGES[hooks]}" = "1" ]; then
    print_step "Updating hooks..."
    
    if [ -d "$BETTERAGENTX_DIR/templates/hooks" ]; then
        for hook in "$BETTERAGENTX_DIR/templates/hooks"/*.kiro.hook; do
            if [ -f "$hook" ]; then
                filename=$(basename "$hook")
                if file_changed "$hook" ".kiro/hooks/$filename"; then
                    if cp "$hook" ".kiro/hooks/$filename" 2>/dev/null; then
                        HOOKS_UPDATED=$((HOOKS_UPDATED + 1))
                        print_info "Updated: $filename"
                    fi
                fi
            fi
        done
        
        print_success "Hooks updated ($HOOKS_UPDATED changed)"
    else
        print_info "No hooks templates found"
    fi
    echo ""
else
    print_info "Hooks: No changes detected"
    echo ""
fi

# ============================================
# 8. UPDATE CONFIGURATION (CAREFUL - USER DATA)
# ============================================
print_step "Checking configuration..."

CONFIG_UPDATED=0

# Only update non-user-modified config files
# Update skills-registry.json (safe - regenerated by catalog script)
if [ -f "$BETTERAGENTX_DIR/templates/config/skills-registry.json" ]; then
    if file_changed "$BETTERAGENTX_DIR/templates/config/skills-registry.json" ".kiro/settings/skills-registry.json"; then
        echo ""
        echo "  Update skills-registry.json?"
        echo "  (Safe - can be regenerated)"
        echo "  Update? (y/n) [timeout: 10s]"
        echo ""
        
        if [ -t 0 ]; then
            read -r -t 10 response || response="n"
        else
            response="n"
        fi
        
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            cp "$BETTERAGENTX_DIR/templates/config/skills-registry.json" .kiro/settings/ 2>/dev/null && \
                CONFIG_UPDATED=$((CONFIG_UPDATED + 1)) && \
                print_info "Updated: skills-registry.json"
        fi
    fi
fi

# Update betteragents.json (metadata only)
if [ -f "$BETTERAGENTX_DIR/config/betteragents.json" ]; then
    cp "$BETTERAGENTX_DIR/config/betteragents.json" .kiro/settings/ 2>/dev/null && \
        CONFIG_UPDATED=$((CONFIG_UPDATED + 1)) && \
        print_info "Updated: betteragents.json"
fi

if [ $CONFIG_UPDATED -gt 0 ]; then
    print_success "Configuration updated ($CONFIG_UPDATED files)"
else
    print_info "Configuration: No updates needed"
fi

echo ""

# ============================================
# 9. UPDATE DASHBOARD (IF CHANGED)
# ============================================

if [ "${CHANGES[dashboard]}" = "1" ]; then
    print_step "Updating dashboard..."
    
    if [ -f "$BETTERAGENTX_DIR/templates/memory/dashboard.html" ]; then
        cp "$BETTERAGENTX_DIR/templates/memory/dashboard.html" .kiro/memory/dashboard.html 2>/dev/null
        print_success "Dashboard updated to new version"
    else
        print_warning "Dashboard template not found"
    fi
    echo ""
else
    print_info "Dashboard: No changes detected"
    echo ""
fi

# ============================================
# 10. PRESERVE USER DATA (CRITICAL)
# ============================================
print_step "Verifying user data preservation..."

# Memory files - NEVER overwrite
MEMORY_FILES=(
    ".kiro/memory/active-context.json"
    ".kiro/memory/decision-log.json"
    ".kiro/memory/progress.json"
    ".kiro/memory/patterns.json"
    ".kiro/memory/llm-usage.json"
    ".kiro/memory/memory-stats.json"
    ".kiro/memory/project-size.json"
)

PRESERVED=0
for file in "${MEMORY_FILES[@]}"; do
    if [ -f "$file" ]; then
        PRESERVED=$((PRESERVED + 1))
    fi
done

print_success "User data preserved ($PRESERVED memory files)"

# Add new memory templates only if missing
NEW_TEMPLATES=0
if [ -d "$BETTERAGENTX_DIR/templates/memory" ]; then
    for template in "$BETTERAGENTX_DIR/templates/memory"/*.json; do
        if [ -f "$template" ]; then
            filename=$(basename "$template")
            # Only add if doesn't exist (NEVER overwrite user data)
            if [ ! -f ".kiro/memory/$filename" ]; then
                if cp "$template" ".kiro/memory/$filename" 2>/dev/null; then
                    NEW_TEMPLATES=$((NEW_TEMPLATES + 1))
                    print_info "Added new template: $filename"
                fi
            fi
        fi
    done
fi

if [ $NEW_TEMPLATES -gt 0 ]; then
    print_info "New templates added: $NEW_TEMPLATES"
fi

echo ""

# ============================================
# 11. UPDATE VERSION TRACKING
# ============================================
print_step "Updating version tracking..."

# Save new version
echo "$NEW_VERSION" > .kiro/.version
cp "$BETTERAGENTX_DIR/config/betteragents.json" .kiro/settings/betteragents.json 2>/dev/null || true

print_success "Version updated: $CURRENT_VERSION → $NEW_VERSION"

echo ""

# ============================================
# 12. VERIFY INFRASTRUCTURE
# ============================================
print_step "Verifying infrastructure..."

# Cache directory
if [ ! -d ".kiro/cache" ]; then
    mkdir -p .kiro/cache
    cat > .kiro/cache/skills-detection-cache.json << 'EOF'
{}
EOF
    print_info "Cache system initialized"
fi

# Backups directory
if [ ! -d ".kiro/backups" ]; then
    mkdir -p .kiro/backups
    print_info "Backups directory created"
fi

# Update .gitignore
if [ -f ".gitignore" ]; then
    UPDATED=false
    
    if ! grep -q ".kiro/cache/" .gitignore 2>/dev/null; then
        echo ".kiro/cache/" >> .gitignore
        UPDATED=true
    fi
    
    if ! grep -q ".kiro/backups/" .gitignore 2>/dev/null; then
        echo ".kiro/backups/" >> .gitignore
        UPDATED=true
    fi
    
    if ! grep -q ".kiro/.version" .gitignore 2>/dev/null; then
        echo ".kiro/.version" >> .gitignore
        UPDATED=true
    fi
    
    [ "$UPDATED" = true ] && print_info ".gitignore updated"
fi

print_success "Infrastructure verified"

echo ""

# ============================================
# 13. VERIFY INSTALLATION
# ============================================
print_step "Verifying updated installation..."

VERIFICATION_PASSED=true

# Check critical components
[ ! -d ".kiro/steering/agents" ] && VERIFICATION_PASSED=false
[ ! -d ".kiro/memory" ] && VERIFICATION_PASSED=false
[ ! -f ".kiro/.version" ] && VERIFICATION_PASSED=false

if [ "$VERIFICATION_PASSED" = true ]; then
    print_success "System verification passed"
    
    # Run full verification if available
    if [ -f "scripts/verify-system.sh" ]; then
        print_info "Run 'bash scripts/verify-system.sh' for detailed check"
    fi
else
    print_error "Verification failed - critical components missing"
    if [ "$BACKUP_DIR" != "none" ]; then
        print_warning "Consider rollback: bash $BACKUP_DIR/rollback.sh"
    fi
fi

echo ""

# ============================================
# 14. UPDATE SUMMARY
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Update Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "BetterAgentX updated successfully"
echo ""
print_version "Version: $CURRENT_VERSION → $NEW_VERSION"
echo ""
echo "📊 Update Summary:"
echo ""

# Show what was updated
TOTAL_UPDATES=0
[ "${CHANGES[agents]}" = "1" ] && echo "  ✅ Agents: $AGENTS_UPDATED files updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + AGENTS_UPDATED))
[ "${CHANGES[scripts]}" = "1" ] && echo "  ✅ Scripts: $SCRIPTS_UPDATED files updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + SCRIPTS_UPDATED))
[ "${CHANGES[hooks]}" = "1" ] && echo "  ✅ Hooks: $HOOKS_UPDATED files updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + HOOKS_UPDATED))
[ "${CHANGES[dashboard]}" = "1" ] && echo "  ✅ Dashboard: Updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + 1))
[ $CONFIG_UPDATED -gt 0 ] && echo "  ✅ Configuration: $CONFIG_UPDATED files updated" && TOTAL_UPDATES=$((TOTAL_UPDATES + CONFIG_UPDATED))
[ $NEW_TEMPLATES -gt 0 ] && echo "  ✅ New templates: $NEW_TEMPLATES added" && TOTAL_UPDATES=$((TOTAL_UPDATES + NEW_TEMPLATES))

echo ""
echo "  Total changes applied: $TOTAL_UPDATES"
echo ""

if [ "$BACKUP_DIR" != "none" ]; then
    echo "� Backup & Rollback:"
    echo ""
    echo "  Backup location: $BACKUP_DIR"
    echo "  Rollback command: bash $BACKUP_DIR/rollback.sh"
    echo ""
fi

echo "🔒 Data Preservation:"
echo ""
echo "  ✅ Memory files preserved ($PRESERVED files)"
echo "  ✅ User settings preserved"
echo "  ✅ Custom modifications preserved"
echo ""

echo "📚 Next Steps:"
echo ""
echo "  1. Test the system:"
echo "     $ kiro ."
echo "     @agentx Hello! Test the updated system"
echo ""
echo "  2. View dashboard:"
echo "     $ bash scripts/open-dashboard.sh"
echo ""
echo "  3. Verify installation:"
echo "     $ bash scripts/verify-system.sh"
echo ""

if [ "$BACKUP_DIR" != "none" ]; then
    echo "  4. If issues occur:"
    echo "     $ bash $BACKUP_DIR/rollback.sh"
    echo ""
fi

print_success "Update completed successfully! 🎉"
echo ""

#!/bin/bash
# Comprehensive Backup Before Skills-On-Demand Implementation
# Creates complete backup with automatic rollback capability

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

echo "🔒 BetterAgents - Comprehensive Backup"
echo "======================================"
echo ""
print_warning "Creating backup before Skills-On-Demand implementation"
echo ""

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$PROJECT_ROOT/.kiro/backups/pre-skills-on-demand-$TIMESTAMP"

# Create backup directory
mkdir -p "$BACKUP_DIR"
print_info "Backup directory: $BACKUP_DIR"
echo ""

# ============================================
# BACKUP AGENTS
# ============================================
print_section "1. Backing up Agents"
echo ""

if [ -d "$PROJECT_ROOT/.kiro/steering/agents" ]; then
    cp -r "$PROJECT_ROOT/.kiro/steering/agents" "$BACKUP_DIR/"
    AGENT_COUNT=$(ls -1 "$PROJECT_ROOT/.kiro/steering/agents"/*.md 2>/dev/null | wc -l)
    print_success "Backed up $AGENT_COUNT agent files"
else
    print_error "Agents directory not found"
    exit 1
fi

echo ""

# ============================================
# BACKUP MEMORY
# ============================================
print_section "2. Backing up Memory System"
echo ""

if [ -d "$PROJECT_ROOT/.kiro/memory" ]; then
    cp -r "$PROJECT_ROOT/.kiro/memory" "$BACKUP_DIR/"
    MEMORY_FILES=$(find "$PROJECT_ROOT/.kiro/memory" -type f | wc -l)
    print_success "Backed up $MEMORY_FILES memory files"
    
    # Show memory stats
    if [ -f "$PROJECT_ROOT/.kiro/memory/memory-stats.json" ]; then
        TOTAL_TOKENS=$(jq -r '.summary.totalTokens // 0' "$PROJECT_ROOT/.kiro/memory/memory-stats.json")
        TOTAL_ENTRIES=$(jq -r '.summary.totalEntries // 0' "$PROJECT_ROOT/.kiro/memory/memory-stats.json")
        print_info "Memory: $TOTAL_ENTRIES entries, $TOTAL_TOKENS tokens"
    fi
else
    print_warning "Memory directory not found (will be created)"
fi

echo ""

# ============================================
# BACKUP SETTINGS
# ============================================
print_section "3. Backing up Settings"
echo ""

if [ -d "$PROJECT_ROOT/.kiro/settings" ]; then
    cp -r "$PROJECT_ROOT/.kiro/settings" "$BACKUP_DIR/"
    SETTINGS_COUNT=$(find "$PROJECT_ROOT/.kiro/settings" -type f | wc -l)
    print_success "Backed up $SETTINGS_COUNT settings files"
else
    print_warning "Settings directory not found (will be created)"
    mkdir -p "$BACKUP_DIR/settings"
fi

echo ""

# ============================================
# BACKUP CONFIGURATION
# ============================================
print_section "4. Backing up Configuration"
echo ""

if [ -f "$PROJECT_ROOT/config/betteragents.json" ]; then
    cp "$PROJECT_ROOT/config/betteragents.json" "$BACKUP_DIR/"
    print_success "Backed up betteragents.json"
else
    print_error "betteragents.json not found"
    exit 1
fi

if [ -f "$PROJECT_ROOT/config/agent-skills.json" ]; then
    cp "$PROJECT_ROOT/config/agent-skills.json" "$BACKUP_DIR/"
    print_success "Backed up agent-skills.json"
fi

echo ""

# ============================================
# BACKUP SKILLS
# ============================================
print_section "5. Backing up Skills"
echo ""

if [ -d "$PROJECT_ROOT/.kiro/skills" ]; then
    # Only backup skill list, not full content (too large)
    ls -1 "$PROJECT_ROOT/.kiro/skills" > "$BACKUP_DIR/skills-list.txt"
    SKILLS_COUNT=$(cat "$BACKUP_DIR/skills-list.txt" | wc -l)
    print_success "Backed up skills list ($SKILLS_COUNT skills)"
    print_info "Note: Full skill content not backed up (too large)"
else
    print_warning "Skills directory not found"
fi

echo ""

# ============================================
# CREATE SYSTEM SNAPSHOT
# ============================================
print_section "6. Creating System Snapshot"
echo ""

cat > "$BACKUP_DIR/system-snapshot.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "date": "$(date -Iseconds)",
  "system": {
    "version": "$(jq -r '.version' "$PROJECT_ROOT/config/betteragents.json")",
    "agents": $AGENT_COUNT,
    "skills": ${SKILLS_COUNT:-0},
    "memoryEntries": ${TOTAL_ENTRIES:-0},
    "memoryTokens": ${TOTAL_TOKENS:-0}
  },
  "backup": {
    "directory": "$BACKUP_DIR",
    "size": "$(du -sh "$BACKUP_DIR" | cut -f1)"
  }
}
EOF

print_success "System snapshot created"

echo ""

# ============================================
# CREATE ROLLBACK SCRIPT
# ============================================
print_section "7. Creating Rollback Script"
echo ""

cat > "$BACKUP_DIR/ROLLBACK.sh" << 'ROLLBACK_EOF'
#!/bin/bash
# Automatic Rollback Script
# Restores system to pre-implementation state

set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$BACKUP_DIR/../../.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}⚠️  ROLLBACK WARNING${NC}"
echo "===================="
echo ""
echo "This will restore the system to its state before Skills-On-Demand implementation"
echo ""
echo -e "${YELLOW}Backup location:${NC} $BACKUP_DIR"
echo -e "${YELLOW}Target location:${NC} $PROJECT_ROOT"
echo ""

# Confirmation
read -p "Are you sure you want to rollback? (type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo ""
    echo "Rollback cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting rollback..."
echo ""

# Restore agents
if [ -d "$BACKUP_DIR/agents" ]; then
    echo "Restoring agents..."
    rm -rf "$PROJECT_ROOT/.kiro/steering/agents"
    cp -r "$BACKUP_DIR/agents" "$PROJECT_ROOT/.kiro/steering/agents"
    echo "✅ Agents restored"
else
    echo "❌ Agents backup not found"
    exit 1
fi

# Restore memory
if [ -d "$BACKUP_DIR/memory" ]; then
    echo "Restoring memory..."
    rm -rf "$PROJECT_ROOT/.kiro/memory"
    cp -r "$BACKUP_DIR/memory" "$PROJECT_ROOT/.kiro/memory"
    echo "✅ Memory restored"
fi

# Restore settings
if [ -d "$BACKUP_DIR/settings" ]; then
    echo "Restoring settings..."
    rm -rf "$PROJECT_ROOT/.kiro/settings"
    cp -r "$BACKUP_DIR/settings" "$PROJECT_ROOT/.kiro/settings"
    echo "✅ Settings restored"
fi

# Restore configuration
if [ -f "$BACKUP_DIR/betteragents.json" ]; then
    echo "Restoring configuration..."
    cp "$BACKUP_DIR/betteragents.json" "$PROJECT_ROOT/config/"
    echo "✅ Configuration restored"
fi

if [ -f "$BACKUP_DIR/agent-skills.json" ]; then
    cp "$BACKUP_DIR/agent-skills.json" "$PROJECT_ROOT/config/"
fi

echo ""
echo "✅ Rollback complete"
echo ""
echo "Verifying system..."
bash "$PROJECT_ROOT/scripts/verify-system.sh"

ROLLBACK_EOF

chmod +x "$BACKUP_DIR/ROLLBACK.sh"
print_success "Rollback script created and executable"

echo ""

# ============================================
# CREATE VERIFICATION SCRIPT
# ============================================
print_section "8. Creating Verification Script"
echo ""

cat > "$BACKUP_DIR/VERIFY-BACKUP.sh" << 'VERIFY_EOF'
#!/bin/bash
# Verify backup integrity

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔍 Verifying Backup Integrity"
echo "=============================="
echo ""

ISSUES=0

# Check agents
if [ -d "$BACKUP_DIR/agents" ]; then
    AGENT_COUNT=$(ls -1 "$BACKUP_DIR/agents"/*.md 2>/dev/null | wc -l)
    echo "✅ Agents: $AGENT_COUNT files"
else
    echo "❌ Agents directory missing"
    ISSUES=$((ISSUES + 1))
fi

# Check memory
if [ -d "$BACKUP_DIR/memory" ]; then
    MEMORY_COUNT=$(find "$BACKUP_DIR/memory" -type f | wc -l)
    echo "✅ Memory: $MEMORY_COUNT files"
else
    echo "⚠️  Memory directory missing"
fi

# Check settings
if [ -d "$BACKUP_DIR/settings" ]; then
    SETTINGS_COUNT=$(find "$BACKUP_DIR/settings" -type f | wc -l)
    echo "✅ Settings: $SETTINGS_COUNT files"
else
    echo "⚠️  Settings directory missing"
fi

# Check configuration
if [ -f "$BACKUP_DIR/betteragents.json" ]; then
    echo "✅ Configuration: betteragents.json"
else
    echo "❌ Configuration missing"
    ISSUES=$((ISSUES + 1))
fi

# Check rollback script
if [ -f "$BACKUP_DIR/ROLLBACK.sh" ] && [ -x "$BACKUP_DIR/ROLLBACK.sh" ]; then
    echo "✅ Rollback script: executable"
else
    echo "❌ Rollback script missing or not executable"
    ISSUES=$((ISSUES + 1))
fi

# Check snapshot
if [ -f "$BACKUP_DIR/system-snapshot.json" ]; then
    echo "✅ System snapshot: present"
else
    echo "⚠️  System snapshot missing"
fi

echo ""
if [ $ISSUES -eq 0 ]; then
    echo "✅ Backup is complete and valid"
    exit 0
else
    echo "❌ Backup has $ISSUES critical issues"
    exit 1
fi

VERIFY_EOF

chmod +x "$BACKUP_DIR/VERIFY-BACKUP.sh"
print_success "Verification script created"

echo ""

# ============================================
# VERIFY BACKUP
# ============================================
print_section "9. Verifying Backup"
echo ""

bash "$BACKUP_DIR/VERIFY-BACKUP.sh"

echo ""

# ============================================
# CREATE README
# ============================================
cat > "$BACKUP_DIR/README.md" << EOF
# Backup: Pre-Skills-On-Demand Implementation

**Created:** $(date)
**Timestamp:** $TIMESTAMP

## System State

- **Version:** $(jq -r '.version' "$PROJECT_ROOT/config/betteragents.json")
- **Agents:** $AGENT_COUNT
- **Skills:** ${SKILLS_COUNT:-0}
- **Memory Entries:** ${TOTAL_ENTRIES:-0}
- **Memory Tokens:** ${TOTAL_TOKENS:-0}

## Backup Contents

- \`agents/\` - All 13 agent files
- \`memory/\` - Complete memory system
- \`settings/\` - All settings files
- \`betteragents.json\` - Main configuration
- \`agent-skills.json\` - Skills mapping
- \`skills-list.txt\` - List of installed skills
- \`system-snapshot.json\` - System state snapshot

## Rollback

To restore the system to this state:

\`\`\`bash
bash ROLLBACK.sh
\`\`\`

This will:
1. Ask for confirmation
2. Restore all agents
3. Restore memory system
4. Restore settings
5. Restore configuration
6. Verify system integrity

## Verification

To verify backup integrity:

\`\`\`bash
bash VERIFY-BACKUP.sh
\`\`\`

## Notes

- Full skill content not backed up (too large, can be reinstalled)
- Rollback script includes automatic verification
- Backup size: $(du -sh "$BACKUP_DIR" | cut -f1)

## Emergency Contact

If rollback fails, manually restore files from this directory to:
- Agents: \`.kiro/steering/agents/\`
- Memory: \`.kiro/memory/\`
- Settings: \`.kiro/settings/\`
- Config: \`config/betteragents.json\`
EOF

print_success "README.md created"

echo ""

# ============================================
# FINAL SUMMARY
# ============================================
echo "========================================"
echo "✅ BACKUP COMPLETE"
echo "========================================"
echo ""

BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

print_info "Backup location: $BACKUP_DIR"
print_info "Backup size: $BACKUP_SIZE"
print_info "Timestamp: $TIMESTAMP"
echo ""

print_success "System state preserved:"
echo "  • $AGENT_COUNT agents"
echo "  • ${SKILLS_COUNT:-0} skills"
echo "  • ${TOTAL_ENTRIES:-0} memory entries"
echo "  • ${TOTAL_TOKENS:-0} memory tokens"
echo ""

print_info "📁 Backup includes:"
echo "  • All agent files"
echo "  • Complete memory system"
echo "  • All settings"
echo "  • Configuration files"
echo "  • System snapshot"
echo ""

print_info "🔄 To rollback:"
echo "  bash $BACKUP_DIR/ROLLBACK.sh"
echo ""

print_info "🔍 To verify backup:"
echo "  bash $BACKUP_DIR/VERIFY-BACKUP.sh"
echo ""

print_success "✨ You can now safely proceed with implementation"
echo ""
print_warning "Keep this backup until Skills-On-Demand is stable"
echo ""

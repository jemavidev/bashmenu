#!/bin/bash
# Skills Injection System
# Dynamically injects detected skills into agent files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/.kiro/steering/agents"
SKILLS_DIR="$PROJECT_ROOT/.kiro/steering/skills"
DETECT_SCRIPT="$SCRIPT_DIR/detect-skills.sh"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_section() { echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

# Parse arguments
AGENT_FILE="$1"
QUERY="$2"
AGENT_NAME="$3"

if [ -z "$AGENT_FILE" ] || [ -z "$QUERY" ] || [ -z "$AGENT_NAME" ]; then
    echo "Usage: ./inject-skills.sh <agent-file> <query> <agent-name>"
    echo ""
    echo "Example:"
    echo "  ./inject-skills.sh .kiro/steering/agents/teacher.md \"Explain React hooks\" teacher"
    exit 1
fi

echo "💉 SKILLS INJECTION"
echo "==================="
echo ""
print_info "Agent file: $AGENT_FILE"
print_info "Query: $QUERY"
print_info "Agent: $AGENT_NAME"
echo ""

# Check if agent file exists
if [ ! -f "$AGENT_FILE" ]; then
    print_error "Agent file not found: $AGENT_FILE"
    exit 1
fi

# Check if agent file has injection markers
if ! grep -q "<!-- SKILLS_INJECTION_START -->" "$AGENT_FILE"; then
    print_error "Agent file missing injection markers"
    echo ""
    echo "Add these markers to your agent file:"
    echo "<!-- SKILLS_INJECTION_START -->"
    echo "<!-- SKILLS_INJECTION_END -->"
    exit 1
fi

# ============================================
# STEP 1: Detect Relevant Skills
# ============================================
print_section "1. Detecting Skills"
echo ""

# Run detection
DETECTION_OUTPUT=$("$DETECT_SCRIPT" "$QUERY" "$AGENT_NAME" false 2>&1)
DETECTION_EXIT=$?

if [ $DETECTION_EXIT -eq 0 ]; then
    # Extract selected skills
    SELECTED_SKILLS=$(echo "$DETECTION_OUTPUT" | grep "Skills:" | sed 's/.*Skills: //')
    
    if [ -z "$SELECTED_SKILLS" ]; then
        print_error "No skills detected"
        exit 2
    fi
    
    print_success "Detected: $SELECTED_SKILLS"
    echo ""
else
    # Fallback to core skills
    print_info "Using fallback (core skills)"
    
    # Get core skills from agent-skills.json
    CORE_SKILLS=$(jq -r --arg agent "$AGENT_NAME" '
        .[$agent].recommended[0:2] | join(",")
    ' "$PROJECT_ROOT/config/agent-skills.json" 2>/dev/null || echo "")
    
    if [ -z "$CORE_SKILLS" ]; then
        print_error "No core skills found for agent: $AGENT_NAME"
        exit 2
    fi
    
    SELECTED_SKILLS="$CORE_SKILLS"
    print_success "Core skills: $SELECTED_SKILLS"
    echo ""
fi

# ============================================
# STEP 2: Prepare Skills References
# ============================================
print_section "2. Preparing Skills References"
echo ""

SKILLS_CONTENT=""
SKILLS_COUNT=0

IFS=',' read -ra SKILLS_ARRAY <<< "$SELECTED_SKILLS"
for skill in "${SKILLS_ARRAY[@]}"; do
    skill=$(echo "$skill" | xargs)  # Trim whitespace
    
    print_success "Added: $skill"
    
    # Add skill reference using Kiro's skill loading syntax
    SKILLS_CONTENT+="
📚 **Load Skill:** \`$skill\`
Use the discloseContext tool to activate this skill before responding.
"
    SKILLS_COUNT=$((SKILLS_COUNT + 1))
done

echo ""
print_info "Prepared $SKILLS_COUNT skill references"
echo ""

# ============================================
# STEP 3: Inject into Agent File
# ============================================
print_section "3. Injecting into Agent"
echo ""

# Create backup
BACKUP_FILE="${AGENT_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$AGENT_FILE" "$BACKUP_FILE"
print_success "Backup created: $BACKUP_FILE"

# Create temporary file with injection
TEMP_FILE=$(mktemp)

# Read agent file and inject skills between markers
awk -v skills="$SKILLS_CONTENT" '
    /<!-- SKILLS_INJECTION_START -->/ {
        print
        print "<!-- Injected at: " strftime("%Y-%m-%d %H:%M:%S") " -->"
        print skills
        in_injection = 1
        next
    }
    /<!-- SKILLS_INJECTION_END -->/ {
        in_injection = 0
        print
        next
    }
    !in_injection { print }
' "$AGENT_FILE" > "$TEMP_FILE"

# Replace original file
mv "$TEMP_FILE" "$AGENT_FILE"

print_success "Skills injected into: $AGENT_FILE"
echo ""

# ============================================
# STEP 4: Summary
# ============================================
print_section "4. Summary"
echo ""

echo "  Agent: $AGENT_NAME"
echo "  Skills referenced: $SKILLS_COUNT"
echo "  Skills: $SELECTED_SKILLS"
echo ""
echo "  Backup: $BACKUP_FILE"
echo ""

print_success "Injection complete!"
echo ""
print_info "The agent file now contains the selected skills"
print_info "Kiro will load these skills automatically"

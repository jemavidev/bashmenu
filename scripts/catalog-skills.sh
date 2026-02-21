#!/bin/bash
# Automatically catalog skills with intelligent keywords

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/.kiro/skills"
REGISTRY_FILE="$PROJECT_ROOT/.kiro/settings/skills-registry.json"
AGENT_SKILLS_FILE="$PROJECT_ROOT/config/agent-skills.json"

echo "📦 Cataloging Skills for Registry"
echo "=================================="
echo ""

if [ ! -d "$SKILLS_DIR" ]; then
    echo "❌ Skills directory not found: $SKILLS_DIR"
    exit 1
fi

# Count skills
TOTAL_SKILLS=$(ls -1 "$SKILLS_DIR" | wc -l)
echo "Found $TOTAL_SKILLS skills to catalog"
echo ""

# Create temporary file for building registry
TEMP_REGISTRY=$(mktemp)

# Start JSON structure
cat > "$TEMP_REGISTRY" << 'EOF'
{
  "version": "1.0.0",
  "lastUpdated": "2026-02-17",
  "totalSkills": 0,
  "skills": {
EOF

FIRST=true

# Process each skill
for skill_dir in "$SKILLS_DIR"/*; do
    if [ ! -d "$skill_dir" ]; then
        continue
    fi
    
    skill_name=$(basename "$skill_dir")
    echo "Processing: $skill_name"
    
    # Extract keywords from skill name (split by dash and underscore)
    name_keywords=$(echo "$skill_name" | tr '-' '\n' | tr '_' '\n' | tr '[:upper:]' '[:lower:]')
    
    # Find which agents use this skill
    agents=$(jq -r --arg skill "$skill_name" '
        to_entries | 
        map(select(.value.recommended? and (.value.recommended | index($skill)))) | 
        map(.key) | 
        join(",")
    ' "$AGENT_SKILLS_FILE")
    
    # Determine category based on agent
    category="general"
    if echo "$agents" | grep -q "architect"; then
        category="architecture"
    elif echo "$agents" | grep -q "coder"; then
        category="development"
    elif echo "$agents" | grep -q "ux-designer"; then
        category="design"
    elif echo "$agents" | grep -q "tester"; then
        category="testing"
    elif echo "$agents" | grep -q "devops"; then
        category="operations"
    elif echo "$agents" | grep -q "security"; then
        category="security"
    elif echo "$agents" | grep -q "writer"; then
        category="documentation"
    elif echo "$agents" | grep -q "data-scientist"; then
        category="data-science"
    fi
    
    # Estimate size (count words in markdown files)
    word_count=0
    if [ -d "$skill_dir" ]; then
        word_count=$(find "$skill_dir" -name "*.md" -exec cat {} \; 2>/dev/null | wc -w || echo "0")
    fi
    token_estimate=$((word_count * 4 / 3))
    
    # Add comma if not first entry
    if [ "$FIRST" = false ]; then
        echo "," >> "$TEMP_REGISTRY"
    fi
    FIRST=false
    
    # Generate keywords based on skill name
    keywords="[]"
    case "$skill_name" in
        *react*|*next*|*vue*|*angular*)
            keywords='["react","frontend","ui","components","jsx","hooks","state"]'
            ;;
        *typescript*|*javascript*)
            keywords='["typescript","javascript","types","typing","generics","ts","js"]'
            ;;
        *python*)
            keywords='["python","py","async","performance","optimization"]'
            ;;
        *docker*|*kubernetes*)
            keywords='["docker","container","k8s","kubernetes","deployment","devops"]'
            ;;
        *test*|*testing*)
            keywords='["test","testing","tdd","unit","integration","e2e","qa"]'
            ;;
        *ui*|*ux*|*design*)
            keywords='["design","ui","ux","interface","user","accessibility","wcag"]'
            ;;
        *api*|*rest*|*graphql*)
            keywords='["api","rest","graphql","endpoint","http","web service"]'
            ;;
        *security*|*auth*)
            keywords='["security","authentication","authorization","jwt","oauth","secure"]'
            ;;
        *database*|*sql*|*postgres*)
            keywords='["database","sql","postgres","query","data","schema"]'
            ;;
        *)
            # Default: use name parts as keywords
            keywords=$(echo "$name_keywords" | jq -R -s 'split("\n") | map(select(length > 0))')
            ;;
    esac
    
    # Build JSON entry
    cat >> "$TEMP_REGISTRY" << SKILL_EOF
    "$skill_name": {
      "displayName": "$(echo $skill_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')",
      "description": "Auto-generated entry for $skill_name",
      "size": $token_estimate,
      "priority": "medium",
      "keywords": $keywords,
      "agents": [$(echo "$agents" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')]
,
      "loadStrategy": "on-demand",
      "category": "$category",
      "tags": [],
      "dependencies": [],
      "conflictsWith": [],
      "lastUsed": null,
      "usageCount": 0,
      "avgRelevance": 0
    }
SKILL_EOF
    
done

# Close JSON structure
cat >> "$TEMP_REGISTRY" << 'EOF'
  },
  "loadStrategies": {
    "always": "Carga en todas las llamadas (0% ahorro)",
    "on-demand": "Carga solo cuando se detectan keywords (85-95% ahorro)",
    "explicit": "Carga solo con comando explícito (95-99% ahorro)",
    "never": "Desactivado (100% ahorro)"
  },
  "priorityLevels": {
    "critical": "Siempre cargar si es relevante",
    "high": "Cargar si relevancia > 70%",
    "medium": "Cargar si relevancia > 80%",
    "low": "Cargar si relevancia > 90%"
  }
}
EOF

# Update total skills count
jq --argjson total "$TOTAL_SKILLS" '.totalSkills = $total' "$TEMP_REGISTRY" > "$REGISTRY_FILE"

rm "$TEMP_REGISTRY"

echo ""
echo "✅ Skills registry created: $REGISTRY_FILE"
echo "   Total skills cataloged: $TOTAL_SKILLS"
echo ""
echo "📝 Next steps:"
echo "   1. Review and refine keywords in $REGISTRY_FILE"
echo "   2. Adjust priorities for critical skills"
echo "   3. Add dependencies if needed"
echo ""

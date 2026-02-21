#!/bin/bash
# Memory Audit Script
# Detects gaps in documentation and suggests what to document

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PROJECT_ROOT=$(cd $SCRIPT_DIR/.. && pwd)
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Memory Audit Report${NC}"
echo "=================================="
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Error: jq is required${NC}"
    exit 1
fi

# Load memory files
DECISIONS=$(cat "$MEMORY_DIR/decision-log.json")
TASKS=$(cat "$MEMORY_DIR/progress.json")
PATTERNS=$(cat "$MEMORY_DIR/patterns.json")

# Count entries
TOTAL_DECISIONS=$(echo "$DECISIONS" | jq '.decisions | length')
TOTAL_TASKS=$(echo "$TASKS" | jq '.tasks | length')
TOTAL_PATTERNS=$(echo "$PATTERNS" | jq '.patterns | length')

echo -e "${GREEN}📊 Current State${NC}"
echo "  Tasks: $TOTAL_TASKS"
echo "  Decisions: $TOTAL_DECISIONS"
echo "  Patterns: $TOTAL_PATTERNS"
echo "  Ratio: $TOTAL_TASKS:$TOTAL_DECISIONS:$TOTAL_PATTERNS"
echo ""

# Expected ratio: ~2:1:0.5 (tasks:decisions:patterns)
EXPECTED_DECISIONS=$((TOTAL_TASKS / 2))
EXPECTED_PATTERNS=$((TOTAL_TASKS / 3))

DECISION_GAP=$((EXPECTED_DECISIONS - TOTAL_DECISIONS))
PATTERN_GAP=$((EXPECTED_PATTERNS - TOTAL_PATTERNS))

echo -e "${YELLOW}📈 Expected Ratios${NC}"
echo "  Expected decisions: ~$EXPECTED_DECISIONS (gap: $DECISION_GAP)"
echo "  Expected patterns: ~$EXPECTED_PATTERNS (gap: $PATTERN_GAP)"
echo ""

# Analyze multi-phase features
echo -e "${BLUE}🔄 Multi-Phase Features Analysis${NC}"
echo ""

PHASE_TASKS=$(echo "$TASKS" | jq -r '.tasks[] | select(.title | contains("Phase") or contains("phase")) | "\(.id)|\(.title)|\(.date)|\(.tags)"')

if [ -z "$PHASE_TASKS" ]; then
    echo "  No multi-phase features found"
else
    echo "$PHASE_TASKS" | while IFS='|' read -r id title date tags_json; do
        # Extract phase number
        PHASE=$(echo "$title" | grep -oP '(Phase|phase)\s*\d+' | grep -oP '\d+' || echo "?")
        
        # Check if there are decisions with overlapping tags (individual comparison)
        RELATED_DECISIONS=$(echo "$DECISIONS" | jq -r \
            --argjson task_tags "$tags_json" \
            '.decisions[] | select(.tags as $dtags | $task_tags | any(. as $t | $dtags | contains([$t]))) | .id' | wc -l)
        
        # Check if there are patterns with overlapping tags
        RELATED_PATTERNS=$(echo "$PATTERNS" | jq -r \
            --argjson task_tags "$tags_json" \
            '.patterns[] | select(.tags as $ptags | $task_tags | any(. as $t | $ptags | contains([$t]))) | .id' | wc -l)
        
        # Also check temporal proximity (same day)
        TASK_DATE=$(echo "$date" | cut -d'T' -f1)
        TEMPORAL_DECISIONS=$(echo "$DECISIONS" | jq -r \
            --arg task_date "$TASK_DATE" \
            '.decisions[] | select(.date | startswith($task_date)) | .id' | wc -l)
        
        echo "  $id: Phase $PHASE"
        echo "    Decisions: $RELATED_DECISIONS (temporal: $TEMPORAL_DECISIONS)"
        echo "    Patterns: $RELATED_PATTERNS"
        
        if [ "$RELATED_DECISIONS" -eq 0 ] && [ "$TEMPORAL_DECISIONS" -eq 0 ]; then
            echo -e "    ${RED}⚠️  Missing decisions for this phase${NC}"
        elif [ "$RELATED_DECISIONS" -eq 0 ] && [ "$TEMPORAL_DECISIONS" -gt 0 ]; then
            echo -e "    ${YELLOW}💡 Found $TEMPORAL_DECISIONS decisions same day (check tags)${NC}"
        fi
        
        if [ "$RELATED_PATTERNS" -eq 0 ]; then
            echo -e "    ${YELLOW}⚠️  No patterns documented${NC}"
        fi
        echo ""
    done
fi

# Find tasks without related decisions
echo -e "${BLUE}🎯 Tasks Without Decisions${NC}"
echo ""

HIGH_PRIORITY_TASKS=$(echo "$TASKS" | jq -r '.tasks[] | select(.priority == "high" or .priority == "critical") | "\(.id)|\(.title)|\(.date)|\(.tags)"')

if [ -z "$HIGH_PRIORITY_TASKS" ]; then
    echo "  No high-priority tasks found"
else
    TASKS_WITHOUT_DECISIONS=0
    echo "$HIGH_PRIORITY_TASKS" | while IFS='|' read -r id title date tags_json; do
        # Check if there are decisions with overlapping tags (individual comparison)
        RELATED=$(echo "$DECISIONS" | jq -r \
            --argjson task_tags "$tags_json" \
            '.decisions[] | select(.tags as $dtags | $task_tags | any(. as $t | $dtags | contains([$t]))) | .id' | wc -l)
        
        # Check temporal proximity
        TASK_DATE=$(echo "$date" | cut -d'T' -f1)
        TEMPORAL=$(echo "$DECISIONS" | jq -r \
            --arg task_date "$TASK_DATE" \
            '.decisions[] | select(.date | startswith($task_date)) | .id' | wc -l)
        
        if [ "$RELATED" -eq 0 ] && [ "$TEMPORAL" -eq 0 ]; then
            echo "  $id: $title"
            echo -e "    ${RED}⚠️  No related decisions found${NC}"
            TASKS_WITHOUT_DECISIONS=$((TASKS_WITHOUT_DECISIONS + 1))
        elif [ "$RELATED" -eq 0 ] && [ "$TEMPORAL" -gt 0 ]; then
            # Has temporal decisions but tags don't match - likely related but needs tag update
            : # Skip reporting, temporal match is good enough
        fi
    done
    
    if [ "$TASKS_WITHOUT_DECISIONS" -eq 0 ]; then
        echo -e "  ${GREEN}✅ All high-priority tasks have related decisions${NC}"
    fi
fi
echo ""

# Recommendations
echo -e "${YELLOW}💡 Recommendations${NC}"
echo ""

if [ "$DECISION_GAP" -gt 0 ]; then
    echo "  📝 Document $DECISION_GAP more technical decisions"
    echo "     Focus on: architecture choices, technology selection, trade-offs"
fi

if [ "$PATTERN_GAP" -gt 0 ]; then
    echo "  🧩 Document $PATTERN_GAP more patterns"
    echo "     Focus on: reusable solutions, workarounds, best practices"
fi

if [ "$DECISION_GAP" -le 0 ] && [ "$PATTERN_GAP" -le 0 ]; then
    echo -e "  ${GREEN}✅ Memory documentation is well-balanced${NC}"
fi

echo ""
echo -e "${BLUE}📋 Specific Suggestions${NC}"
echo ""

# Find phases with missing patterns
PHASES_MISSING_PATTERNS=$(echo "$PHASE_TASKS" | while IFS='|' read -r id title date tags_json; do
    RELATED_PATTERNS=$(echo "$PATTERNS" | jq -r \
        --argjson task_tags "$tags_json" \
        '.patterns[] | select(.tags as $ptags | $task_tags | any(. as $t | $ptags | contains([$t]))) | .id' | wc -l)
    
    if [ "$RELATED_PATTERNS" -eq 0 ]; then
        PHASE=$(echo "$title" | grep -oP '(Phase|phase)\s*\d+' | grep -oP '\d+' || echo "?")
        echo "$id|Phase $PHASE|$title"
    fi
done)

if [ -n "$PHASES_MISSING_PATTERNS" ]; then
    echo "  🧩 Document patterns for:"
    echo "$PHASES_MISSING_PATTERNS" | while IFS='|' read -r id phase title; do
        echo "     • $id ($phase): What solutions/learnings emerged?"
    done
    echo ""
fi

# Find recent tasks without decisions
RECENT_TASKS=$(echo "$TASKS" | jq -r '.tasks | sort_by(.date) | reverse | .[0:5] | .[] | "\(.id)|\(.title)|\(.date)|\(.tags)"')
RECENT_WITHOUT_DECISIONS=$(echo "$RECENT_TASKS" | while IFS='|' read -r id title date tags_json; do
    RELATED=$(echo "$DECISIONS" | jq -r \
        --argjson task_tags "$tags_json" \
        '.decisions[] | select(.tags as $dtags | $task_tags | any(. as $t | $dtags | contains([$t]))) | .id' | wc -l)
    
    TASK_DATE=$(echo "$date" | cut -d'T' -f1)
    TEMPORAL=$(echo "$DECISIONS" | jq -r \
        --arg task_date "$TASK_DATE" \
        '.decisions[] | select(.date | startswith($task_date)) | .id' | wc -l)
    
    if [ "$RELATED" -eq 0 ] && [ "$TEMPORAL" -eq 0 ]; then
        echo "$id|$title"
    fi
done)

if [ -n "$RECENT_WITHOUT_DECISIONS" ]; then
    echo "  🎯 Recent tasks without decisions:"
    echo "$RECENT_WITHOUT_DECISIONS" | while IFS='|' read -r id title; do
        echo "     • $id: Were there technical choices made?"
    done
    echo ""
fi

if [ -z "$PHASES_MISSING_PATTERNS" ] && [ -z "$RECENT_WITHOUT_DECISIONS" ]; then
    echo "  ✅ No specific actions needed"
    echo ""
fi

echo -e "${BLUE}📋 General Actions${NC}"
echo ""
echo "  1. Review multi-phase features and document missing patterns"
echo "  2. Check recent high-priority tasks for undocumented decisions"
echo "  3. Update active-context.json if project phase changed"
echo "  4. Run: bash scripts/calculate-tokens.sh (check memory usage)"
echo ""

exit 0

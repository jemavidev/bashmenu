#!/bin/bash
# Generate session summary after agent execution
# Shows completed work, impact, recommendations, and next steps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

# Get current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Read memory files
TASKS=$(cat "$MEMORY_DIR/progress.json" 2>/dev/null || echo '{"tasks":[]}')
DECISIONS=$(cat "$MEMORY_DIR/decision-log.json" 2>/dev/null || echo '{"decisions":[]}')
PATTERNS=$(cat "$MEMORY_DIR/patterns.json" 2>/dev/null || echo '{"patterns":[]}')
CONTEXT=$(cat "$MEMORY_DIR/active-context.json" 2>/dev/null || echo '{}')
LLM_USAGE=$(cat "$MEMORY_DIR/llm-usage.json" 2>/dev/null || echo '{"totals":{"total":0,"input":0,"output":0}}')
PROJECT_SIZE=$(cat "$MEMORY_DIR/project-size.json" 2>/dev/null || echo '{"totalTokens":0,"growth":{"sinceLastCalculation":0}}')

# Extract recent completed tasks (last 5)
RECENT_TASKS=$(echo "$TASKS" | jq -r '[.tasks[] | select(.status == "completed")] | sort_by(.date) | reverse | .[0:5] | .[].title' | head -3)
COMPLETED_COUNT=$(echo "$TASKS" | jq '[.tasks[] | select(.status == "completed")] | length')

# Extract pending tasks
PENDING_TASKS=$(echo "$TASKS" | jq -r '[.tasks[] | select(.status == "in-progress" or .status == "blocked")] | .[0:3] | .[] | "\(.id): \(.title) (\(.status))"')
PENDING_COUNT=$(echo "$TASKS" | jq '[.tasks[] | select(.status == "in-progress" or .status == "blocked")] | length')

# Get recent memory entries (last session)
RECENT_TASK_ENTRIES=$(echo "$TASKS" | jq -r '[.tasks[]] | sort_by(.date) | reverse | .[0:3] | .[] | .id' | wc -l)
RECENT_DECISION_ENTRIES=$(echo "$DECISIONS" | jq -r '[.decisions[]] | sort_by(.date) | reverse | .[0:2] | .[] | .id' | wc -l)

# Get LLM usage
LLM_TOTAL=$(echo "$LLM_USAGE" | jq -r '.totals.total')
LLM_INPUT=$(echo "$LLM_USAGE" | jq -r '.totals.input')
LLM_OUTPUT=$(echo "$LLM_USAGE" | jq -r '.totals.output')

# Get project metrics
PROJECT_TOKENS=$(echo "$PROJECT_SIZE" | jq -r '.totalTokens')
PROJECT_GROWTH=$(echo "$PROJECT_SIZE" | jq -r '.growth.sinceLastCalculation // 0')
GROWTH_PCT=$(LC_NUMERIC=C awk "BEGIN {if ($PROJECT_TOKENS > 0) printf \"%.2f\", ($PROJECT_GROWTH / $PROJECT_TOKENS) * 100; else print \"0.00\"}")

# Get git stats for files modified
FILES_MODIFIED=$(git -C "$PROJECT_ROOT" diff --name-only HEAD~1 2>/dev/null | wc -l || echo "0")

# Memory health
TASK_COUNT=$(echo "$TASKS" | jq '.tasks | length')
DECISION_COUNT=$(echo "$DECISIONS" | jq '.decisions | length')
PATTERN_COUNT=$(echo "$PATTERNS" | jq '.patterns | length')

# Calculate efficiency (from project-metrics if available)
EFFICIENCY="0.00"
if [ -f "$MEMORY_DIR/project-metrics.json" ]; then
    EFFICIENCY=$(cat "$MEMORY_DIR/project-metrics.json" | jq -r '.efficiency.memoryToProject // 0' | LC_NUMERIC=C awk '{printf "%.2f", $1 * 100}')
fi

# Format numbers with K suffix
format_number() {
    local num=$1
    if [ $num -ge 1000 ]; then
        echo "$((num / 1000))K"
    else
        echo "$num"
    fi
}

LLM_TOTAL_FMT=$(format_number $LLM_TOTAL)
LLM_INPUT_FMT=$(format_number $LLM_INPUT)
LLM_OUTPUT_FMT=$(format_number $LLM_OUTPUT)
PROJECT_GROWTH_FMT=$(format_number $PROJECT_GROWTH)

# Build completed summary (first 3 tasks)
COMPLETED_SUMMARY=$(echo "$RECENT_TASKS" | head -3 | sed 's/^/   /' | tr '\n' ' ' | sed 's/   /• /g' | sed 's/• $//')

# Get current focus
CURRENT_FOCUS=$(echo "$CONTEXT" | jq -r '.currentFocus.feature // "No active focus"')

# Output summary
cat << EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SESSION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ COMPLETED
${COMPLETED_SUMMARY}

📊 IMPACT
   Tokens: ${LLM_TOTAL_FMT} total (${LLM_INPUT_FMT} in, ${LLM_OUTPUT_FMT} out)
   Files: ${FILES_MODIFIED} modified • Memory: $((RECENT_TASK_ENTRIES + RECENT_DECISION_ENTRIES)) entries
   Project: +${PROJECT_GROWTH_FMT} tokens (${GROWTH_PCT}% growth)

🧠 SESSION
   Agent: AgentX/Dispatcher • Focus: ${CURRENT_FOCUS}

💡 RECOMMENDATIONS
   1. Review completed work and verify functionality
   2. Test any modified features thoroughly
   3. Update documentation if needed

🎯 NEXT STEPS
   Pending: ${PENDING_COUNT} tasks
$(echo "$PENDING_TASKS" | head -3 | sed 's/^/   → /')

📈 MEMORY HEALTH
   Ratio: ${TASK_COUNT}:${DECISION_COUNT}:${PATTERN_COUNT} (balanced) • Efficiency: ${EFFICIENCY}%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

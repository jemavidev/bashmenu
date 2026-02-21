#!/bin/bash
# Generate Audit Section for Dashboard
# Runs audit-memory.sh and formats output as HTML

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PROJECT_ROOT=$(cd $SCRIPT_DIR/.. && pwd)
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

# Run audit and capture output
AUDIT_OUTPUT=$(bash "$SCRIPT_DIR/audit-memory.sh" 2>&1)

# Extract key metrics (using awk for portability)
TOTAL_TASKS=$(echo "$AUDIT_OUTPUT" | grep "Tasks:" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+$/) {print $i; exit}}')
TOTAL_DECISIONS=$(echo "$AUDIT_OUTPUT" | grep "Decisions:" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+$/) {print $i; exit}}')
TOTAL_PATTERNS=$(echo "$AUDIT_OUTPUT" | grep "Patterns:" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[0-9]+$/) {print $i; exit}}')
DECISION_GAP=$(echo "$AUDIT_OUTPUT" | grep "Expected decisions:" | awk -F'gap: ' '{print $2}' | awk -F')' '{print $1}')
PATTERN_GAP=$(echo "$AUDIT_OUTPUT" | grep "Expected patterns:" | awk -F'gap: ' '{print $2}' | awk -F')' '{print $1}')

# Determine health status
if [ "$DECISION_GAP" -le 0 ] && [ "$PATTERN_GAP" -le 0 ]; then
    HEALTH_STATUS="healthy"
    HEALTH_COLOR="#10b981"
    HEALTH_ICON="✅"
    HEALTH_TEXT="Healthy"
else
    HEALTH_STATUS="needs-attention"
    HEALTH_COLOR="#f59e0b"
    HEALTH_ICON="⚠️"
    HEALTH_TEXT="Needs Attention"
fi

# Generate JSON for dashboard
cat << EOF
{
  "health": {
    "status": "$HEALTH_STATUS",
    "color": "$HEALTH_COLOR",
    "icon": "$HEALTH_ICON",
    "text": "$HEALTH_TEXT"
  },
  "metrics": {
    "tasks": $TOTAL_TASKS,
    "decisions": $TOTAL_DECISIONS,
    "patterns": $TOTAL_PATTERNS,
    "decisionGap": $DECISION_GAP,
    "patternGap": $PATTERN_GAP
  },
  "suggestions": $(echo "$AUDIT_OUTPUT" | sed -n '/📋 Specific Suggestions/,/📋 General Actions/p' | grep "•" | jq -R -s -c 'split("\n") | map(select(length > 0))'),
  "timestamp": "$(date -Iseconds)"
}
EOF

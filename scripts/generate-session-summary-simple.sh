#!/bin/bash
# Simple session summary - Kiro-friendly format

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

# Read memory files
TASKS=$(cat "$MEMORY_DIR/progress.json" 2>/dev/null || echo '{"tasks":[]}')
DECISIONS=$(cat "$MEMORY_DIR/decision-log.json" 2>/dev/null || echo '{"decisions":[]}')
PATTERNS=$(cat "$MEMORY_DIR/patterns.json" 2>/dev/null || echo '{"patterns":[]}')
CONTEXT=$(cat "$MEMORY_DIR/active-context.json" 2>/dev/null || echo '{}')

# Get recent completed tasks
RECENT_TASKS=$(echo "$TASKS" | jq -r '[.tasks[] | select(.status == "completed")] | sort_by(.date) | reverse | .[0:3] | .[].title')
COMPLETED_COUNT=$(echo "$TASKS" | jq '[.tasks[] | select(.status == "completed")] | length')
PENDING_COUNT=$(echo "$TASKS" | jq '[.tasks[] | select(.status == "in-progress" or .status == "blocked")] | length')

# Memory stats
TASK_COUNT=$(echo "$TASKS" | jq '.tasks | length')
DECISION_COUNT=$(echo "$DECISIONS" | jq '.decisions | length')
PATTERN_COUNT=$(echo "$PATTERNS" | jq '.patterns | length')

# Current focus
CURRENT_FOCUS=$(echo "$CONTEXT" | jq -r '.currentFocus.feature // "No active focus"')

# Output simple summary
echo ""
echo "=========================================="
echo "SESSION SUMMARY"
echo "=========================================="
echo ""
echo "COMPLETED TASKS ($COMPLETED_COUNT):"
echo "$RECENT_TASKS" | head -3 | sed 's/^/  - /'
echo ""
echo "MEMORY STATUS:"
echo "  Tasks: $TASK_COUNT | Decisions: $DECISION_COUNT | Patterns: $PATTERN_COUNT"
echo "  Pending: $PENDING_COUNT tasks"
echo ""
echo "CURRENT FOCUS:"
echo "  $CURRENT_FOCUS"
echo ""
echo "=========================================="
echo ""

exit 0

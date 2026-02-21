#!/bin/bash
# Show current project context - use when resuming work
# Quick checkpoint view of where you left off

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTEXT_FILE="$PROJECT_ROOT/.kiro/memory/active-context.json"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Project Context Checkpoint${NC}"
echo "=================================="
echo ""

# Last update
LAST_UPDATE=$(jq -r '.context.stats.lastUpdate // "Never"' "$CONTEXT_FILE")
echo -e "${GREEN}🕐 Last Updated:${NC} $LAST_UPDATE"
echo ""

# Current focus
FOCUS=$(jq -r '.currentFocus.feature // "No active focus"' "$CONTEXT_FILE")
PHASE=$(jq -r '.project.phase // "general"' "$CONTEXT_FILE")
echo -e "${YELLOW}🎯 Current Focus:${NC}"
echo "   $FOCUS"
echo -e "   Phase: $PHASE"
echo ""

# Stats
PENDING=$(jq -r '.context.stats.pendingTasks // 0' "$CONTEXT_FILE")
COMPLETED=$(jq -r '.context.stats.completedTasks // 0' "$CONTEXT_FILE")
echo -e "${BLUE}📊 Progress:${NC}"
echo "   ✅ Completed: $COMPLETED tasks"
echo "   ⏳ Pending: $PENDING tasks"
echo ""

# Recent tasks
echo -e "${GREEN}📝 Recent Work:${NC}"
jq -r '.context.recentTasks[]? | "   • [\(.status)] \(.title)"' "$CONTEXT_FILE" | head -5
echo ""

# Recent decisions
DECISIONS_COUNT=$(jq '.context.recentDecisions | length' "$CONTEXT_FILE")
if [ "$DECISIONS_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}💡 Recent Decisions:${NC}"
    jq -r '.context.recentDecisions[]? | "   • \(.title)"' "$CONTEXT_FILE"
    echo ""
fi

# Blockers
BLOCKERS=$(jq -r '.blockers[]? // empty' "$CONTEXT_FILE")
if [ -n "$BLOCKERS" ]; then
    echo -e "${RED}⚠️  Blockers:${NC}"
    echo "$BLOCKERS" | while read -r blocker; do
        echo "   • $blocker"
    done
    echo ""
fi

# Next steps
NEXT_STEPS=$(jq -r '.nextSteps[]? // empty' "$CONTEXT_FILE")
if [ -n "$NEXT_STEPS" ]; then
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "$NEXT_STEPS" | while read -r step; do
        echo "   • $step"
    done
    echo ""
fi

echo "=================================="
echo -e "${GREEN}💡 Tip:${NC} Run 'bash scripts/open-dashboard.sh' for detailed view"

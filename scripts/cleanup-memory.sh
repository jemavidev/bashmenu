#!/bin/bash
# Memory Cleanup Script
# Archives old entries and recalculates token statistics

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PROJECT_ROOT=$(cd $SCRIPT_DIR/.. && pwd)
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
ARCHIVE_DIR="$MEMORY_DIR/archive"
STATS_FILE="$MEMORY_DIR/memory-stats.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧹 Memory Cleanup Tool${NC}"
echo ""

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Error: jq is required but not installed${NC}"
    exit 1
fi

# Load current stats
if [ ! -f "$STATS_FILE" ]; then
    echo -e "${RED}❌ Error: memory-stats.json not found${NC}"
    echo "Run: bash scripts/calculate-tokens.sh"
    exit 1
fi

TOTAL_TOKENS=$(jq -r '.summary.totalTokens' "$STATS_FILE")
PERCENT_USED=$(jq -r '.cleanupRecommendations.percentUsed' "$STATS_FILE")
THRESHOLD=$(jq -r '.cleanupRecommendations.threshold' "$STATS_FILE")
SUGGESTED_ACTION=$(jq -r '.cleanupRecommendations.suggestedAction' "$STATS_FILE")

echo -e "📊 Current Status:"
echo -e "   Total Tokens: ${TOTAL_TOKENS} / ${THRESHOLD}"
echo -e "   Usage: ${PERCENT_USED}%"
echo -e "   Recommendation: ${SUGGESTED_ACTION}"
echo ""

if [ "$SUGGESTED_ACTION" = "none" ]; then
    echo -e "${GREEN}✅ Memory is healthy, no cleanup needed${NC}"
    exit 0
fi

# Show oldest entries
echo -e "${YELLOW}📋 Oldest Entries:${NC}"
echo ""

echo "Decisions:"
jq -r '.decisions | sort_by(.date) | .[0:3] | .[] | "  • \(.id): \(.title) (\(.date))"' "$MEMORY_DIR/decision-log.json" 2>/dev/null || echo "  None"

echo ""
echo "Tasks:"
jq -r '.tasks | sort_by(.date) | .[0:3] | .[] | "  • \(.id): \(.title) (\(.date))"' "$MEMORY_DIR/progress.json" 2>/dev/null || echo "  None"

echo ""
echo "Patterns:"
jq -r '.patterns | sort_by(.date) | .[0:3] | .[] | "  • \(.id): \(.title // .problem) (\(.date))"' "$MEMORY_DIR/patterns.json" 2>/dev/null || echo "  None"

echo ""
echo -e "${YELLOW}⚠️  Cleanup Options:${NC}"
echo "1. Archive entries older than 30 days"
echo "2. Archive entries older than 60 days"
echo "3. Archive entries older than 90 days"
echo "4. Manual selection (coming soon)"
echo "5. Cancel"
echo ""

read -p "Select option (1-5): " choice

case $choice in
    1) DAYS=30 ;;
    2) DAYS=60 ;;
    3) DAYS=90 ;;
    5) echo "Cancelled"; exit 0 ;;
    *) echo "Invalid option"; exit 1 ;;
esac

# Calculate cutoff date
CUTOFF_DATE=$(date -d "$DAYS days ago" +%Y-%m-%d)
echo ""
echo -e "${BLUE}📦 Archiving entries older than $CUTOFF_DATE...${NC}"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"
ARCHIVE_FILE="$ARCHIVE_DIR/archive_$(date +%Y%m%d_%H%M%S).json"

# Archive old entries
jq -n \
    --arg cutoff "$CUTOFF_DATE" \
    --slurpfile decisions "$MEMORY_DIR/decision-log.json" \
    --slurpfile tasks "$MEMORY_DIR/progress.json" \
    --slurpfile patterns "$MEMORY_DIR/patterns.json" \
    '{
        archivedDate: (now | strftime("%Y-%m-%dT%H:%M:%S%z")),
        cutoffDate: $cutoff,
        decisions: ($decisions[0].decisions | map(select(.date < $cutoff))),
        tasks: ($tasks[0].tasks | map(select(.date < $cutoff))),
        patterns: ($patterns[0].patterns | map(select(.date < $cutoff)))
    }' > "$ARCHIVE_FILE"

# Count archived entries
ARCHIVED_DECISIONS=$(jq '.decisions | length' "$ARCHIVE_FILE")
ARCHIVED_TASKS=$(jq '.tasks | length' "$ARCHIVE_FILE")
ARCHIVED_PATTERNS=$(jq '.patterns | length' "$ARCHIVE_FILE")
TOTAL_ARCHIVED=$((ARCHIVED_DECISIONS + ARCHIVED_TASKS + ARCHIVED_PATTERNS))

if [ $TOTAL_ARCHIVED -eq 0 ]; then
    echo -e "${GREEN}✅ No entries older than $CUTOFF_DATE found${NC}"
    rm "$ARCHIVE_FILE"
    exit 0
fi

echo -e "   Archived: $ARCHIVED_DECISIONS decisions, $ARCHIVED_TASKS tasks, $ARCHIVED_PATTERNS patterns"

# Remove archived entries from active files
jq --arg cutoff "$CUTOFF_DATE" '.decisions |= map(select(.date >= $cutoff))' "$MEMORY_DIR/decision-log.json" > "$MEMORY_DIR/decision-log.json.tmp"
mv "$MEMORY_DIR/decision-log.json.tmp" "$MEMORY_DIR/decision-log.json"

jq --arg cutoff "$CUTOFF_DATE" '.tasks |= map(select(.date >= $cutoff))' "$MEMORY_DIR/progress.json" > "$MEMORY_DIR/progress.json.tmp"
mv "$MEMORY_DIR/progress.json.tmp" "$MEMORY_DIR/progress.json"

jq --arg cutoff "$CUTOFF_DATE" '.patterns |= map(select(.date >= $cutoff))' "$MEMORY_DIR/patterns.json" > "$MEMORY_DIR/patterns.json.tmp"
mv "$MEMORY_DIR/patterns.json.tmp" "$MEMORY_DIR/patterns.json"

echo ""
echo -e "${BLUE}🔢 Recalculating tokens...${NC}"
bash "$SCRIPT_DIR/calculate-tokens.sh"

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo -e "   Archive: $ARCHIVE_FILE"
echo -e "   Entries archived: $TOTAL_ARCHIVED"

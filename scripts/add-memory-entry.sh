#!/bin/bash
# Quick helper to add memory entries
# Usage: ./add-memory-entry.sh <type> <title> <description> <tags>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

TYPE=$1
TITLE=$2
DESCRIPTION=$3
TAGS=$4

# Validate input
if [ -z "$TYPE" ] || [ -z "$TITLE" ]; then
    echo "❌ Error: Type and title required"
    echo ""
    echo "Usage: $0 <type> <title> <description> <tags>"
    echo ""
    echo "Types:"
    echo "  task      - Completed work or milestone"
    echo "  pattern   - Reusable solution or learning"
    echo "  decision  - Technical decision made"
    echo ""
    echo "Example:"
    echo "  $0 task \"Fixed bug\" \"Resolved memory access issue\" \"bug-fix,memory\""
    exit 1
fi

# Map type to file and ID prefix
case $TYPE in
  task)
    MEMORY_FILE="progress"
    ID_PREFIX="TASK"
    ARRAY_KEY="tasks"
    ;;
  pattern)
    MEMORY_FILE="patterns"
    ID_PREFIX="PAT"
    ARRAY_KEY="patterns"
    ;;
  decision)
    MEMORY_FILE="decision-log"
    ID_PREFIX="DEC"
    ARRAY_KEY="decisions"
    ;;
  *)
    echo "❌ Invalid type: $TYPE"
    echo "Valid types: task, pattern, decision"
    exit 1
    ;;
esac

FILE_PATH="$MEMORY_DIR/${MEMORY_FILE}.json"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "❌ File not found: $FILE_PATH"
    exit 1
fi

# Get next ID
LAST_ID=$(jq -r ".${ARRAY_KEY}[]?.id // empty" "$FILE_PATH" | grep "^${ID_PREFIX}" | sort -V | tail -1)
if [ -z "$LAST_ID" ]; then
  NEXT_NUM=1
else
  LAST_NUM=${LAST_ID##*-}
  # Remove leading zeros for arithmetic
  LAST_NUM=$((10#$LAST_NUM))
  NEXT_NUM=$((LAST_NUM + 1))
fi
NEW_ID="${ID_PREFIX}-$(printf "%03d" $NEXT_NUM)"

# Get current date
DATE=$(date -Iseconds)
AGENT="AgentX/Dispatcher"

# Default values
DESCRIPTION=${DESCRIPTION:-"No description provided"}
TAGS=${TAGS:-""}

# Build JSON entry based on type
if [ "$TYPE" = "task" ]; then
    ENTRY=$(jq -n \
      --arg id "$NEW_ID" \
      --arg date "$DATE" \
      --arg title "$TITLE" \
      --arg desc "$DESCRIPTION" \
      --arg agent "$AGENT" \
      --arg tags "$TAGS" \
      '{
        id: $id,
        date: $date,
        title: $title,
        status: "completed",
        description: $desc,
        agent: $agent,
        files_modified: [],
        outcome: $desc,
        tags: (if $tags == "" then [] else ($tags | split(",")) end)
      }')
elif [ "$TYPE" = "pattern" ]; then
    ENTRY=$(jq -n \
      --arg id "$NEW_ID" \
      --arg date "$DATE" \
      --arg title "$TITLE" \
      --arg desc "$DESCRIPTION" \
      --arg agent "$AGENT" \
      --arg tags "$TAGS" \
      '{
        id: $id,
        date: $date,
        name: $title,
        title: $title,
        category: "implementation",
        problem: $title,
        solution: $desc,
        implementation: $desc,
        benefits: [],
        when_to_use: "As needed",
        when_not_to_use: "N/A",
        agent: $agent,
        tags: (if $tags == "" then [] else ($tags | split(",")) end)
      }')
elif [ "$TYPE" = "decision" ]; then
    ENTRY=$(jq -n \
      --arg id "$NEW_ID" \
      --arg date "$DATE" \
      --arg title "$TITLE" \
      --arg desc "$DESCRIPTION" \
      --arg agent "$AGENT" \
      --arg tags "$TAGS" \
      '{
        id: $id,
        date: $date,
        title: $title,
        context: $desc,
        decision: $title,
        consequences: {
          positive: [],
          negative: [],
          risks: []
        },
        alternatives: [],
        agent: $agent,
        tags: (if $tags == "" then [] else ($tags | split(",")) end)
      }')
fi

# Create backup
BACKUP_DIR="$MEMORY_DIR/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp "$FILE_PATH" "$BACKUP_DIR/${MEMORY_FILE}_${TIMESTAMP}.json"

# Add entry to file
jq ".${ARRAY_KEY} += [$ENTRY]" "$FILE_PATH" > "$FILE_PATH.tmp"
mv "$FILE_PATH.tmp" "$FILE_PATH"

echo "✅ Added $NEW_ID to ${MEMORY_FILE}.json"
echo "   Title: $TITLE"
echo "   Backup: ${MEMORY_FILE}_${TIMESTAMP}.json"
echo ""
echo "🔄 Updating dashboard..."
bash "$SCRIPT_DIR/update-dashboard.sh" > /dev/null 2>&1
echo "✅ Dashboard updated"

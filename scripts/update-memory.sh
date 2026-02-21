#!/bin/bash
# Memory Update Helper Script with Token Tracking
# Usage: ./scripts/update-memory.sh <type> < input.json

set -e

MEMORY_TYPE=$1
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PROJECT_ROOT=$(cd $SCRIPT_DIR/.. && pwd)
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
BACKUP_DIR="$MEMORY_DIR/backups"
STATS_FILE="$MEMORY_DIR/memory-stats.json"

# Validate input
if [ -z "$MEMORY_TYPE" ]; then
    echo "❌ Error: Memory type required"
    echo "Usage: $0 <type>"
    echo "Types: progress, patterns, decision-log, active-context"
    exit 1
fi

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Validate type
case $MEMORY_TYPE in
  progress|patterns|decision-log|active-context)
    FILE="$MEMORY_DIR/${MEMORY_TYPE}.json"
    ;;
  *)
    echo "❌ Invalid type: $MEMORY_TYPE"
    echo "Valid types: progress, patterns, decision-log, active-context"
    exit 1
    ;;
esac

# Backup existing file
if [ -f "$FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp "$FILE" "$BACKUP_DIR/${MEMORY_TYPE}_${TIMESTAMP}.json"
    echo "📦 Backup created: ${MEMORY_TYPE}_${TIMESTAMP}.json"
fi

# Read from stdin and write to file
cat > "$FILE"

# Validate JSON
if command -v jq &> /dev/null; then
    if jq empty "$FILE" 2>/dev/null; then
        echo "✅ Updated: ${MEMORY_TYPE}.json (valid JSON)"
        
        # Calculate tokens and update stats
        if [ "$MEMORY_TYPE" != "active-context" ]; then
            echo "🔢 Calculating tokens..."
            bash "$SCRIPT_DIR/calculate-tokens.sh"
        fi
    else
        echo "⚠️  Updated: ${MEMORY_TYPE}.json (JSON validation failed)"
        echo "    Restoring backup..."
        cp "$BACKUP_DIR/${MEMORY_TYPE}_${TIMESTAMP}.json" "$FILE"
        exit 1
    fi
else
    echo "✅ Updated: ${MEMORY_TYPE}.json (jq not available for validation)"
fi

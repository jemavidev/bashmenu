#!/bin/bash
# Consolidate all project metrics into single file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
OUTPUT_FILE="$MEMORY_DIR/project-metrics.json"

# Read individual metric files
PROJECT_SIZE=$(cat "$MEMORY_DIR/project-size.json" 2>/dev/null || echo '{"totalTokens":0}')
MEMORY_STATS=$(cat "$MEMORY_DIR/memory-stats.json" 2>/dev/null || echo '{"summary":{"totalTokens":0}}')
LLM_USAGE=$(cat "$MEMORY_DIR/llm-usage.json" 2>/dev/null || echo '{"totals":{"total":0,"input":0,"output":0}}')

# Extract values
PROJECT_TOKENS=$(echo "$PROJECT_SIZE" | jq -r '.totalTokens')
MEMORY_TOKENS=$(echo "$MEMORY_STATS" | jq -r '.summary.totalTokens')
LLM_TOTAL=$(echo "$LLM_USAGE" | jq -r '.totals.total')
LLM_INPUT=$(echo "$LLM_USAGE" | jq -r '.totals.input')
LLM_OUTPUT=$(echo "$LLM_USAGE" | jq -r '.totals.output')

# Calculate efficiency ratios
if [ "$PROJECT_TOKENS" -gt 0 ] && [ "$LLM_TOTAL" -gt 0 ]; then
    MEMORY_TO_PROJECT=$(LC_NUMERIC=C awk "BEGIN {printf \"%.4f\", $MEMORY_TOKENS / $PROJECT_TOKENS}")
    MEMORY_TO_CONSUMED=$(LC_NUMERIC=C awk "BEGIN {printf \"%.4f\", $MEMORY_TOKENS / $LLM_TOTAL}")
    PROJECT_TO_CONSUMED=$(LC_NUMERIC=C awk "BEGIN {printf \"%.4f\", $PROJECT_TOKENS / $LLM_TOTAL}")
else
    MEMORY_TO_PROJECT=0
    MEMORY_TO_CONSUMED=0
    PROJECT_TO_CONSUMED=0
fi

# Build consolidated JSON
TIMESTAMP=$(date -Iseconds)

cat > "$OUTPUT_FILE" << JSONEOF
{
  "version": "1.0.0",
  "lastUpdated": "$TIMESTAMP",
  "project": $PROJECT_SIZE,
  "memory": $MEMORY_STATS,
  "llm": $LLM_USAGE,
  "efficiency": {
    "memoryToProject": $MEMORY_TO_PROJECT,
    "memoryToConsumed": $MEMORY_TO_CONSUMED,
    "projectToConsumed": $PROJECT_TO_CONSUMED
  }
}
JSONEOF

echo "✅ Project metrics updated:"
echo "   Project: $(printf "%'d" $PROJECT_TOKENS) tokens"
echo "   Memory: $(printf "%'d" $MEMORY_TOKENS) tokens"
echo "   LLM Used: $(printf "%'d" $LLM_TOTAL) tokens"
echo "   Efficiency: $(LC_NUMERIC=C awk "BEGIN {printf \"%.2f%%\", $MEMORY_TO_PROJECT * 100}")"

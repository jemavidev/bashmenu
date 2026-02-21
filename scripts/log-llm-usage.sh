#!/bin/bash
# Log LLM token usage (input/output) manually
# Usage: bash scripts/log-llm-usage.sh <input_tokens> <output_tokens> [description]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
USAGE_FILE="$MEMORY_DIR/llm-usage.json"

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: bash scripts/log-llm-usage.sh <input_tokens> <output_tokens> [description]"
    echo "Example: bash scripts/log-llm-usage.sh 50000 45000 'Implemented dashboard features'"
    exit 1
fi

INPUT_TOKENS=$1
OUTPUT_TOKENS=$2
DESCRIPTION="${3:-Manual token logging}"
TIMESTAMP=$(date -Iseconds)

# Initialize file if doesn't exist
if [ ! -f "$USAGE_FILE" ]; then
    echo '{"sessions": [], "totals": {"input": 0, "output": 0, "total": 0}}' > "$USAGE_FILE"
fi

# Read current totals
CURRENT_INPUT=$(jq -r '.totals.input' "$USAGE_FILE")
CURRENT_OUTPUT=$(jq -r '.totals.output' "$USAGE_FILE")

# Calculate new totals
NEW_INPUT=$((CURRENT_INPUT + INPUT_TOKENS))
NEW_OUTPUT=$((CURRENT_OUTPUT + OUTPUT_TOKENS))
NEW_TOTAL=$((NEW_INPUT + NEW_OUTPUT))

# Add session entry
jq --arg ts "$TIMESTAMP" \
   --argjson input "$INPUT_TOKENS" \
   --argjson output "$OUTPUT_TOKENS" \
   --arg desc "$DESCRIPTION" \
   --argjson new_input "$NEW_INPUT" \
   --argjson new_output "$NEW_OUTPUT" \
   --argjson new_total "$NEW_TOTAL" \
   '.sessions += [{
      timestamp: $ts,
      input: $input,
      output: $output,
      total: ($input + $output),
      description: $desc
   }] | .totals = {
      input: $new_input,
      output: $new_output,
      total: $new_total
   }' "$USAGE_FILE" > "$USAGE_FILE.tmp" && mv "$USAGE_FILE.tmp" "$USAGE_FILE"

echo "✅ Logged LLM usage:"
echo "   Input: $(printf "%'d" $INPUT_TOKENS) tokens"
echo "   Output: $(printf "%'d" $OUTPUT_TOKENS) tokens"
echo "   Total this session: $(printf "%'d" $((INPUT_TOKENS + OUTPUT_TOKENS))) tokens"
echo ""
echo "📊 Cumulative totals:"
echo "   Input: $(printf "%'d" $NEW_INPUT) tokens"
echo "   Output: $(printf "%'d" $NEW_OUTPUT) tokens"
echo "   Total: $(printf "%'d" $NEW_TOTAL) tokens"

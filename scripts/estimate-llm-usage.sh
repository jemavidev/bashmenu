#!/bin/bash
# Estimate LLM token usage based on conversation context
# Runs automatically via hook after agent execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
USAGE_FILE="$MEMORY_DIR/llm-usage.json"

# Initialize file if doesn't exist
if [ ! -f "$USAGE_FILE" ]; then
    echo '{"sessions": [], "totals": {"input": 0, "output": 0, "total": 0}}' > "$USAGE_FILE"
fi

# Estimate tokens based on recent git changes
# This is a rough estimation: 1 token ≈ 4 characters
RECENT_CHANGES=$(git -C "$PROJECT_ROOT" diff --stat HEAD~1 2>/dev/null | tail -1 || echo "0 insertions(+), 0 deletions(-)")

# Extract insertions and deletions
INSERTIONS=$(echo "$RECENT_CHANGES" | grep -oP '\d+(?= insertion)' || echo "0")
DELETIONS=$(echo "$RECENT_CHANGES" | grep -oP '\d+(?= deletion)' || echo "0")

# Estimate tokens (rough approximation)
# Input: Assume context includes modified files + steering + memory (estimate 30K base)
# Output: Based on insertions (characters / 4)
ESTIMATED_INPUT=30000
ESTIMATED_OUTPUT=$((INSERTIONS * 20))  # Rough: 20 tokens per line inserted

# Only log if there's meaningful activity
if [ $ESTIMATED_OUTPUT -lt 100 ]; then
    exit 0
fi

TIMESTAMP=$(date -Iseconds)
DESCRIPTION="Auto-estimated from git changes (+$INSERTIONS/-$DELETIONS lines)"

# Read current totals
CURRENT_INPUT=$(jq -r '.totals.input' "$USAGE_FILE")
CURRENT_OUTPUT=$(jq -r '.totals.output' "$USAGE_FILE")

# Calculate new totals
NEW_INPUT=$((CURRENT_INPUT + ESTIMATED_INPUT))
NEW_OUTPUT=$((CURRENT_OUTPUT + ESTIMATED_OUTPUT))
NEW_TOTAL=$((NEW_INPUT + NEW_OUTPUT))

# Add session entry
jq --arg ts "$TIMESTAMP" \
   --argjson input "$ESTIMATED_INPUT" \
   --argjson output "$ESTIMATED_OUTPUT" \
   --arg desc "$DESCRIPTION" \
   --argjson new_input "$NEW_INPUT" \
   --argjson new_output "$NEW_OUTPUT" \
   --argjson new_total "$NEW_TOTAL" \
   '.sessions += [{
      timestamp: $ts,
      input: $input,
      output: $output,
      total: ($input + $output),
      description: $desc,
      estimated: true
   }] | .totals = {
      input: $new_input,
      output: $new_output,
      total: $new_total
   }' "$USAGE_FILE" > "$USAGE_FILE.tmp" && mv "$USAGE_FILE.tmp" "$USAGE_FILE"

# Silent execution (no output to avoid noise)

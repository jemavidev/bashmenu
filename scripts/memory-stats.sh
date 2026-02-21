#!/bin/bash

# Memory Statistics Script
# Shows current memory usage and costs

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"

echo "📊 BetterAgents Memory Statistics"
echo "=================================="
echo ""

# Count entries
decisions=$(cat "$MEMORY_DIR/decision-log.json" | grep -o '"id":' | wc -l)
tasks=$(cat "$MEMORY_DIR/progress.json" | grep -o '"id":' | wc -l)
patterns=$(cat "$MEMORY_DIR/patterns.json" | grep -o '"id":' | wc -l)

echo "📝 Entries:"
echo "  Decisions: $decisions"
echo "  Tasks: $tasks"
echo "  Patterns: $patterns"
echo "  Total: $((decisions + tasks + patterns))"
echo ""

# Calculate sizes
total_bytes=$(cat "$MEMORY_DIR"/*.json | wc -c)
total_tokens=$((total_bytes / 4))

echo "💾 Storage:"
echo "  Total size: $total_bytes bytes"
echo "  Estimated tokens: ~$total_tokens"
echo ""

# Calculate costs
cost_per_trigger=$(echo "scale=4; $total_tokens * 0.000003 + 500 * 0.000015" | bc)
triggers_per_day=10
cost_per_day=$(echo "scale=2; $cost_per_trigger * $triggers_per_day" | bc)
cost_per_month=$(echo "scale=2; $cost_per_day * 30" | bc)

echo "💰 Estimated Costs (Claude Sonnet):"
echo "  Per trigger: \$$cost_per_trigger"
echo "  Per day (10 triggers): \$$cost_per_day"
echo "  Per month: \$$cost_per_month"
echo ""

# File breakdown
echo "📄 File Breakdown:"
for file in decision-log.json patterns.json progress.json active-context.json; do
    bytes=$(wc -c < "$MEMORY_DIR/$file")
    tokens=$((bytes / 4))
    echo "  $file: $bytes bytes (~$tokens tokens)"
done
echo ""

echo "✅ Memory system is optimized for cost efficiency"

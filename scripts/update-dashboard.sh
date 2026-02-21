#!/bin/bash
# BetterAgents Memory Dashboard Builder
# Reads JSON memory files and generates standalone HTML dashboard with embedded data

set -e

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Paths
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
TEMPLATE="$PROJECT_ROOT/templates/memory/dashboard.html"
OUTPUT="$MEMORY_DIR/dashboard.html"
TEMP_OUTPUT="${OUTPUT}.tmp"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Building Memory Dashboard...${NC}"

# Check if template exists
if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Error: Template not found at $TEMPLATE"
    exit 1
fi

# Check if memory files exist
for file in decision-log.json patterns.json progress.json active-context.json; do
    if [ ! -f "$MEMORY_DIR/$file" ]; then
        echo "❌ Error: Memory file not found: $MEMORY_DIR/$file"
        exit 1
    fi
done

# Read JSON files
DECISIONS=$(cat "$MEMORY_DIR/decision-log.json" | jq -c '.decisions')
PATTERNS=$(cat "$MEMORY_DIR/patterns.json" | jq -c '.patterns')
PROGRESS=$(cat "$MEMORY_DIR/progress.json" | jq -c '.tasks')
CONTEXT=$(cat "$MEMORY_DIR/active-context.json" | jq -c '.')
STATS=$(cat "$MEMORY_DIR/memory-stats.json" | jq -c '.' 2>/dev/null || echo 'null')
METRICS=$(cat "$MEMORY_DIR/project-metrics.json" | jq -c '.' 2>/dev/null || echo 'null')

# Generate audit data
AUDIT_DATA=$(bash "$SCRIPT_DIR/generate-audit-section.sh" 2>/dev/null || echo 'null')

# Get current timestamp
TIMESTAMP=$(date -Iseconds)
READABLE_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# Create new memoryData block
MEMORY_DATA_BLOCK="        let memoryData = {
            decisions: ${DECISIONS},
            tasks: ${PROGRESS},
            patterns: ${PATTERNS},
            context: ${CONTEXT},
            stats: ${STATS},
            metrics: ${METRICS},
            audit: ${AUDIT_DATA},
            lastUpdate: \"${TIMESTAMP}\",
            lastUpdateReadable: \"${READABLE_TIME}\"
        };"

# Process template
IN_MEMORY_BLOCK=false
BRACE_COUNT=0

while IFS= read -r line; do
    # Detect start of memoryData declaration
    if [[ "$line" =~ "let memoryData = {" ]]; then
        IN_MEMORY_BLOCK=true
        BRACE_COUNT=1
        echo "$MEMORY_DATA_BLOCK"
        continue
    fi
    
    # If inside memoryData block, count braces to find the end
    if [ "$IN_MEMORY_BLOCK" = true ]; then
        # Count opening braces
        OPEN_BRACES=$(echo "$line" | grep -o "{" | wc -l)
        BRACE_COUNT=$((BRACE_COUNT + OPEN_BRACES))
        
        # Count closing braces
        CLOSE_BRACES=$(echo "$line" | grep -o "}" | wc -l)
        BRACE_COUNT=$((BRACE_COUNT - CLOSE_BRACES))
        
        # If we've closed all braces and found the semicolon, we're done
        if [ $BRACE_COUNT -le 0 ] && [[ "$line" =~ ";" ]]; then
            IN_MEMORY_BLOCK=false
        fi
        continue
    fi
    
    # Add refresh button after theme toggle button
    if [[ "$line" =~ "toggleTheme()" ]] && [[ "$line" =~ "button" ]]; then
        echo "$line"
        continue
    fi
    
    echo "$line"
done < "$TEMPLATE" > "$TEMP_OUTPUT"

# Move temp file to final location
mv "$TEMP_OUTPUT" "$OUTPUT"

echo -e "${GREEN}✅ Dashboard built successfully!${NC}"
echo -e "   📁 Output: $OUTPUT"
echo -e "   🕐 Updated: $READABLE_TIME"
echo -e ""
echo -e "   📊 Memory Stats:"
echo -e "      • Decisions: $(echo "$DECISIONS" | jq 'length')"
echo -e "      • Patterns: $(echo "$PATTERNS" | jq 'length')"
echo -e "      • Tasks: $(echo "$PROGRESS" | jq 'length')"
echo -e ""
echo -e "${BLUE}🌐 Open dashboard:${NC} xdg-open $OUTPUT"

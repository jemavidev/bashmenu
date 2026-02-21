#!/bin/bash
# Calculate total token size of project files
# Runs automatically via hook or manually

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
OUTPUT_FILE="$MEMORY_DIR/project-size.json"

echo "📊 Calculating project size..."

# Initialize counters
TOTAL_TOKENS=0
declare -A CATEGORY_TOKENS
declare -A FILETYPE_TOKENS
declare -a TOP_FILES

# Patterns to exclude
EXCLUDE_PATTERNS="node_modules|\.git|dist|build|\.kiro/memory/dashboard\.html"

# Function to estimate tokens (rough: 1 token ≈ 4 chars)
estimate_tokens() {
    local file=$1
    local chars=$(wc -c < "$file" 2>/dev/null || echo 0)
    echo $((chars / 4))
}

# Categorize file
categorize_file() {
    local file=$1
    case "$file" in
        *.js|*.ts|*.jsx|*.tsx|*.py|*.java|*.cpp|*.c|*.go|*.rs)
            echo "code" ;;
        *.md|*.txt|*.rst)
            echo "documentation" ;;
        *.json|*.yaml|*.yml|*.toml|*.xml)
            echo "config" ;;
        *.sh|*.bash)
            echo "scripts" ;;
        *.html|*.css|*.scss)
            echo "frontend" ;;
        .kiro/memory/*.json)
            echo "memory" ;;
        .kiro/steering/*.md)
            echo "steering" ;;
        *)
            echo "other" ;;
    esac
}

# Scan all files
while IFS= read -r -d '' file; do
    # Skip excluded patterns
    if echo "$file" | grep -qE "$EXCLUDE_PATTERNS"; then
        continue
    fi
    
    # Skip binary files
    if file "$file" | grep -q "text"; then
        tokens=$(estimate_tokens "$file")
        TOTAL_TOKENS=$((TOTAL_TOKENS + tokens))
        
        # By category
        category=$(categorize_file "$file")
        CATEGORY_TOKENS[$category]=$((${CATEGORY_TOKENS[$category]:-0} + tokens))
        
        # By file type
        ext="${file##*.}"
        FILETYPE_TOKENS[$ext]=$((${FILETYPE_TOKENS[$ext]:-0} + tokens))
        
        # Track for top files
        TOP_FILES+=("$tokens|$file")
    fi
done < <(find "$PROJECT_ROOT" -type f -print0)

# Sort top files
IFS=$'\n' TOP_FILES_SORTED=($(printf '%s\n' "${TOP_FILES[@]}" | sort -rn | head -20))

# Build JSON
TIMESTAMP=$(date -Iseconds)

# Build category JSON
CATEGORY_JSON="{"
first=true
for cat in "${!CATEGORY_TOKENS[@]}"; do
    if [ "$first" = false ]; then CATEGORY_JSON+=","; fi
    CATEGORY_JSON+="\"$cat\":${CATEGORY_TOKENS[$cat]}"
    first=false
done
CATEGORY_JSON+="}"

# Build filetype JSON
FILETYPE_JSON="{"
first=true
for ext in "${!FILETYPE_TOKENS[@]}"; do
    if [ "$first" = false ]; then FILETYPE_JSON+=","; fi
    FILETYPE_JSON+="\".$ext\":${FILETYPE_TOKENS[$ext]}"
    first=false
done
FILETYPE_JSON+="}"

# Build top files JSON
TOPFILES_JSON="["
first=true
for entry in "${TOP_FILES_SORTED[@]}"; do
    tokens="${entry%%|*}"
    filepath="${entry#*|}"
    relpath="${filepath#$PROJECT_ROOT/}"
    percentage=$(LC_NUMERIC=C awk "BEGIN {printf \"%.2f\", ($tokens / $TOTAL_TOKENS) * 100}")
    
    if [ "$first" = false ]; then TOPFILES_JSON+=","; fi
    TOPFILES_JSON+="{\"path\":\"$relpath\",\"tokens\":$tokens,\"percentage\":$percentage}"
    first=false
done
TOPFILES_JSON+="]"

# Read previous size for growth calculation
PREVIOUS_SIZE=0
if [ -f "$OUTPUT_FILE" ]; then
    PREVIOUS_SIZE=$(jq -r '.totalTokens // 0' "$OUTPUT_FILE")
fi
GROWTH=$((TOTAL_TOKENS - PREVIOUS_SIZE))

# Write output
cat > "$OUTPUT_FILE" << JSONEOF
{
  "totalTokens": $TOTAL_TOKENS,
  "lastCalculated": "$TIMESTAMP",
  "byCategory": $CATEGORY_JSON,
  "byFileType": $FILETYPE_JSON,
  "topFiles": $TOPFILES_JSON,
  "growth": {
    "sinceLastCalculation": $GROWTH,
    "percentage": $(LC_NUMERIC=C awk "BEGIN {if ($PREVIOUS_SIZE > 0) printf \"%.2f\", ($GROWTH / $PREVIOUS_SIZE) * 100; else print 0}")
  }
}
JSONEOF

echo "✅ Project size calculated:"
echo "   Total: $(printf "%'d" $TOTAL_TOKENS) tokens"
echo "   Growth: $(printf "%+d" $GROWTH) tokens"
echo "   Output: $OUTPUT_FILE"

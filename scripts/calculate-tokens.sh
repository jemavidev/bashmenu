#!/bin/bash
# Token Calculation and Stats Update Script
# Calculates tokens for all memory entries and updates memory-stats.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
STATS_FILE="$MEMORY_DIR/memory-stats.json"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not available, skipping token calculation"
    exit 0
fi

# Function to calculate tokens for a JSON string
calculate_tokens() {
    local json_str="$1"
    local length=${#json_str}
    echo $(( (length + 3) / 4 ))
}

# Function to add tokens to entries in a file
add_tokens_to_entries() {
    local file="$1"
    local entry_key="$2"  # "decisions", "tasks", or "patterns"
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    # Read file and add tokens to each entry
    local temp_file=$(mktemp)
    jq --arg key "$entry_key" '
        .[$key] |= map(
            . + {
                tokens: (. | tostring | length / 4 | ceil)
            }
        )
    ' "$file" > "$temp_file"
    
    mv "$temp_file" "$file"
}

# Function to calculate file metadata and add to file
add_file_metadata() {
    local file="$1"
    local entry_key="$2"
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    local temp_file=$(mktemp)
    jq --arg key "$entry_key" '
        .[$key] as $entries |
        ($entries | length) as $count |
        ($entries | map(.tokens // 0) | add // 0) as $total |
        (if $count > 0 then ($total / $count | floor) else 0 end) as $avg |
        ($entries | map(.tokens // 0) | min // 0) as $min |
        ($entries | map(.tokens // 0) | max // 0) as $max |
        ($entries | group_by(.agent) | map({key: .[0].agent, value: (map(.tokens // 0) | add)}) | from_entries) as $byAgent |
        ($entries | map(select(.skills != null and .skills != []) | {agent: .agent, skills: .skills, tokens: .tokens}) | 
         map(.skills[] as $skill | {skill: $skill, tokens: .tokens}) | 
         group_by(.skill) | 
         map({key: .[0].skill, value: (map(.tokens) | add)}) | 
         from_entries) as $bySkill |
        . + {
            metadata: {
                totalTokens: $total,
                totalEntries: $count,
                avgTokensPerEntry: $avg,
                minTokens: $min,
                maxTokens: $max,
                tokensByAgent: $byAgent,
                tokensBySkill: $bySkill,
                lastCalculated: (now | strftime("%Y-%m-%dT%H:%M:%S%z"))
            }
        }
    ' "$file" > "$temp_file"
    
    mv "$temp_file" "$file"
}

# Function to calculate file metadata for stats
calculate_file_metadata() {
    local file="$1"
    local entry_key="$2"
    
    if [ ! -f "$file" ]; then
        echo "0 0 0 0 {} {}"
        return
    fi
    
    local result=$(jq -r --arg key "$entry_key" '
        .[$key] as $entries |
        ($entries | length) as $count |
        ($entries | map(.tokens // 0) | add // 0) as $total |
        ($entries | map(.tokens // 0) | min // 0) as $min |
        ($entries | map(.tokens // 0) | max // 0) as $max |
        ($entries | group_by(.agent) | map({key: .[0].agent, value: (map(.tokens // 0) | add)}) | from_entries) as $byAgent |
        ($entries | map(select(.skills != null and .skills != []) | {agent: .agent, skills: .skills, tokens: .tokens}) | 
         map(.skills[] as $skill | {skill: $skill, tokens: .tokens}) | 
         group_by(.skill) | 
         map({key: .[0].skill, value: (map(.tokens) | add)}) | 
         from_entries) as $bySkill |
        "\($total) \($count) \($min) \($max) \($byAgent | @json) \($bySkill | @json)"
    ' "$file")
    
    echo "$result"
}

echo "🔢 Calculating tokens for memory entries..."

# Add tokens field to entries if not present
add_tokens_to_entries "$MEMORY_DIR/decision-log.json" "decisions"
add_tokens_to_entries "$MEMORY_DIR/progress.json" "tasks"
add_tokens_to_entries "$MEMORY_DIR/patterns.json" "patterns"

# Add metadata to each file
add_file_metadata "$MEMORY_DIR/decision-log.json" "decisions"
add_file_metadata "$MEMORY_DIR/progress.json" "tasks"
add_file_metadata "$MEMORY_DIR/patterns.json" "patterns"

# Calculate metadata for each file
read dec_tokens dec_count dec_min dec_max dec_agents dec_skills <<< $(calculate_file_metadata "$MEMORY_DIR/decision-log.json" "decisions")
read task_tokens task_count task_min task_max task_agents task_skills <<< $(calculate_file_metadata "$MEMORY_DIR/progress.json" "tasks")
read pat_tokens pat_count pat_min pat_max pat_agents pat_skills <<< $(calculate_file_metadata "$MEMORY_DIR/patterns.json" "patterns")

# Calculate dashboard size if exists
dashboard_tokens=0
if [ -f "$MEMORY_DIR/dashboard.html" ]; then
    dashboard_size=$(wc -c < "$MEMORY_DIR/dashboard.html")
    dashboard_tokens=$(( (dashboard_size + 3) / 4 ))
fi

# Calculate totals
total_tokens=$((dec_tokens + task_tokens + pat_tokens))
total_entries=$((dec_count + task_count + pat_count))
avg_tokens=0
if [ $total_entries -gt 0 ]; then
    avg_tokens=$((total_tokens / total_entries))
fi

# Calculate input/output tokens
input_tokens=0
output_tokens=0

# If we have previous stats, calculate the difference
if [ -f "$STATS_FILE" ]; then
    prev_total=$(jq -r '.summary.totalTokens // 0' "$STATS_FILE")
    input_tokens=$prev_total
    output_tokens=$((total_tokens - prev_total))
    
    # If output is negative, it means entries were deleted
    if [ $output_tokens -lt 0 ]; then
        output_tokens=0
    fi
else
    # First run: all tokens are output
    output_tokens=$total_tokens
fi

# Calculate min/max across all entries
all_min=$dec_min
[ $task_min -lt $all_min ] && [ $task_min -gt 0 ] && all_min=$task_min
[ $pat_min -lt $all_min ] && [ $pat_min -gt 0 ] && all_min=$pat_min

all_max=$dec_max
[ $task_max -gt $all_max ] && all_max=$task_max
[ $pat_max -gt $all_max ] && all_max=$pat_max

# Merge agent stats
all_agents=$(jq -n --argjson d "$dec_agents" --argjson t "$task_agents" --argjson p "$pat_agents" '
    [$d, $t, $p] | 
    add | 
    to_entries | 
    group_by(.key) | 
    map({key: .[0].key, value: (map(.value) | add)}) | 
    from_entries
')

# Merge skill stats
all_skills=$(jq -n --argjson d "$dec_skills" --argjson t "$task_skills" --argjson p "$pat_skills" '
    [$d, $t, $p] | 
    add | 
    to_entries | 
    group_by(.key) | 
    map({key: .[0].key, value: (map(.value) | add)}) | 
    from_entries
')

# Calculate cleanup recommendations
threshold=50000
percent_used=$((total_tokens * 100 / threshold))
suggested_action="none"
if [ $percent_used -ge 75 ]; then
    suggested_action="cleanup"
elif [ $percent_used -ge 50 ]; then
    suggested_action="review"
fi

# Find oldest entry date
oldest_date=$(jq -r '
    [
        (.decisions // [] | map(.date)),
        (.tasks // [] | map(.date)),
        (.patterns // [] | map(.date))
    ] | 
    add | 
    sort | 
    .[0] // ""
' "$MEMORY_DIR/decision-log.json" "$MEMORY_DIR/progress.json" "$MEMORY_DIR/patterns.json" 2>/dev/null | head -1)

# Get today's date for timeline
today=$(date +%Y-%m-%d)

# Load existing timeline or create new
existing_timeline="{}"
if [ -f "$STATS_FILE" ]; then
    existing_timeline=$(jq -r '.timeline // {}' "$STATS_FILE")
fi

# Calculate tokens added today
tokens_added_today=0
entries_added_today=0

# Check if we have previous stats
if [ -f "$STATS_FILE" ]; then
    prev_total=$(jq -r '.summary.totalTokens // 0' "$STATS_FILE")
    prev_entries=$(jq -r '.summary.totalEntries // 0' "$STATS_FILE")
    tokens_added_today=$((total_tokens - prev_total))
    entries_added_today=$((total_entries - prev_entries))
fi

# Update timeline
updated_timeline=$(echo "$existing_timeline" | jq --arg today "$today" --argjson added "$tokens_added_today" --argjson entries "$entries_added_today" '
    . + {
        ($today): {
            tokensAdded: $added,
            entriesAdded: $entries
        }
    }
')

# Update memory-stats.json
jq -n \
    --arg version "1.0.0" \
    --arg updated "$(date -Iseconds)" \
    --argjson total_tokens "$total_tokens" \
    --argjson total_entries "$total_entries" \
    --argjson avg_tokens "$avg_tokens" \
    --argjson min_tokens "$all_min" \
    --argjson max_tokens "$all_max" \
    --argjson input_tokens "$input_tokens" \
    --argjson output_tokens "$output_tokens" \
    --argjson dec_tokens "$dec_tokens" \
    --argjson task_tokens "$task_tokens" \
    --argjson pat_tokens "$pat_tokens" \
    --argjson dashboard_tokens "$dashboard_tokens" \
    --argjson agents "$all_agents" \
    --argjson skills "$all_skills" \
    --argjson timeline "$updated_timeline" \
    --argjson threshold "$threshold" \
    --argjson percent "$percent_used" \
    --arg oldest "$oldest_date" \
    --arg action "$suggested_action" \
    '{
        version: $version,
        lastUpdated: $updated,
        summary: {
            totalTokens: $total_tokens,
            totalEntries: $total_entries,
            avgTokensPerEntry: $avg_tokens,
            minTokens: $min_tokens,
            maxTokens: $max_tokens,
            inputTokens: $input_tokens,
            outputTokens: $output_tokens,
            byCategory: {
                decisions: $dec_tokens,
                tasks: $task_tokens,
                patterns: $pat_tokens
            },
            byAgent: $agents,
            bySkill: $skills
        },
        fileStats: {
            "decision-log.json": $dec_tokens,
            "progress.json": $task_tokens,
            "patterns.json": $pat_tokens,
            "dashboard.html": $dashboard_tokens
        },
        timeline: $timeline,
        cleanupRecommendations: {
            threshold: $threshold,
            currentUsage: $total_tokens,
            percentUsed: $percent,
            oldestEntry: $oldest,
            suggestedAction: $action
        },
        _comments: {
            purpose: "Global memory token tracking and cleanup recommendations",
            tokenCalculation: "tokens = Math.ceil(JSON.stringify(entry).length / 4)",
            thresholds: {
                "0-50%": "healthy (green)",
                "50-75%": "review (yellow)",
                "75-100%": "cleanup needed (red)"
            }
        }
    }' > "$STATS_FILE"

echo "✅ Token calculation complete:"
echo "   Total: $total_tokens tokens ($percent_used% of threshold)"
echo "   Entries: $total_entries"
echo "   Average: $avg_tokens tokens/entry"
echo "   Range: $all_min - $all_max tokens"
echo "   Dashboard: $dashboard_tokens tokens"
echo "   Status: $suggested_action"

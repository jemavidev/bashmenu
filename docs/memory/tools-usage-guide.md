# Memory Tools Usage Guide

## Problem Identified

The current `update-memory.sh` script expects full JSON via stdin, making it difficult to use for quick updates. This causes:
- Agents trying to use it incorrectly
- Long delays (36+ minutes) due to failed attempts
- Confusion about proper usage

## Available Tools

### 1. update-memory.sh (Current - Complex)

**Current Usage:**
```bash
# Expects full JSON via stdin
cat new-data.json | bash scripts/update-memory.sh progress
```

**Problems:**
- Not intuitive for quick updates
- Requires creating temporary JSON files
- No helper for adding single entries

### 2. Dashboard Tools (Working)

**update-dashboard.sh** ✅
```bash
bash scripts/update-dashboard.sh
```
- Regenerates dashboard HTML
- Works automatically via hook
- No issues

**open-dashboard.sh** ✅
```bash
bash scripts/open-dashboard.sh              # Update + open
bash scripts/open-dashboard.sh --update-only # Update only
```
- Works correctly
- Good UX

### 3. Statistics Tools (Working)

**memory-stats.sh** ✅
```bash
bash scripts/memory-stats.sh
```
- Shows entry counts
- Calculates token usage
- Works correctly

**calculate-tokens.sh** ✅
```bash
bash scripts/calculate-tokens.sh
```
- Updates memory-stats.json
- Tracks token usage
- Works correctly

**audit-memory.sh** ✅
```bash
bash scripts/audit-memory.sh
```
- Checks documentation balance
- Suggests missing items
- Works correctly

## Proposed Solutions

### Solution 1: Create Helper Script (Recommended)

Create `scripts/add-memory-entry.sh`:

```bash
#!/bin/bash
# Quick helper to add memory entries
# Usage: ./add-memory-entry.sh <type> <title> <description> <tags>

TYPE=$1
TITLE=$2
DESCRIPTION=$3
TAGS=$4

case $TYPE in
  task|progress)
    MEMORY_FILE="progress"
    ID_PREFIX="TASK"
    ;;
  pattern)
    MEMORY_FILE="patterns"
    ID_PREFIX="PAT"
    ;;
  decision)
    MEMORY_FILE="decision-log"
    ID_PREFIX="DEC"
    ;;
  *)
    echo "❌ Invalid type: $TYPE"
    echo "Valid: task, pattern, decision"
    exit 1
    ;;
esac

# Get next ID
LAST_ID=$(jq -r ".[] | .id" .kiro/memory/${MEMORY_FILE}.json | grep "^${ID_PREFIX}" | sort -V | tail -1)
if [ -z "$LAST_ID" ]; then
  NEXT_NUM=1
else
  NEXT_NUM=$((${LAST_ID##*-} + 1))
fi
NEW_ID="${ID_PREFIX}-$(printf "%03d" $NEXT_NUM)"

# Create entry
DATE=$(date -Iseconds)
AGENT="AgentX/Dispatcher"

# Build JSON entry
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
    description: $desc,
    agent: $agent,
    tags: ($tags | split(","))
  }')

# Add to file
jq ".tasks += [$ENTRY]" .kiro/memory/${MEMORY_FILE}.json > /tmp/memory.json
mv /tmp/memory.json .kiro/memory/${MEMORY_FILE}.json

echo "✅ Added $NEW_ID to ${MEMORY_FILE}.json"
```

**Usage:**
```bash
bash scripts/add-memory-entry.sh task "Dashboard auto-update" "Created hook system" "automation,dashboard"
```

### Solution 2: Improve update-memory.sh

Add argument parsing to existing script:

```bash
# Add after line 10
TITLE=$2
DESCRIPTION=$3
TAGS=$4

# If arguments provided, generate JSON
if [ -n "$TITLE" ]; then
    # Generate JSON from arguments
    # Then pipe to existing logic
fi
```

### Solution 3: Use jq Directly (Quick Fix)

Create aliases in documentation:

```bash
# Add task
alias add-task='jq ".tasks += [{id: \"TASK-XXX\", date: \"$(date -Iseconds)\", title: \"$1\", description: \"$2\"}]" .kiro/memory/progress.json'

# Add pattern
alias add-pattern='jq ".patterns += [{id: \"PAT-XXX\", date: \"$(date -Iseconds)\", problem: \"$1\", solution: \"$2\"}]" .kiro/memory/patterns.json'
```

## Recommended Workflow

### For Agents (Automated)

1. **Don't try to write directly to .kiro/memory/** - Access denied
2. **Use hooks for automatic updates** - Already working
3. **Suggest manual edits to user** - When needed
4. **Use dashboard for verification** - Read-only access works

### For Users (Manual)

**Quick View:**
```bash
bash scripts/memory-stats.sh          # See counts
bash scripts/open-dashboard.sh        # Visual interface
```

**Add Entry:**
```bash
# Option 1: Use new helper (after creating it)
bash scripts/add-memory-entry.sh task "Title" "Description" "tags"

# Option 2: Edit JSON directly
code .kiro/memory/progress.json

# Option 3: Use jq
jq '.tasks += [{"id":"TASK-001","title":"New task"}]' .kiro/memory/progress.json > tmp.json && mv tmp.json .kiro/memory/progress.json
```

**Verify:**
```bash
bash scripts/open-dashboard.sh        # See in dashboard
```

## Implementation Priority

1. ✅ **Dashboard auto-update** - DONE (hook working)
2. 🔧 **Create add-memory-entry.sh** - HIGH PRIORITY
3. 📝 **Update documentation** - MEDIUM
4. 🔄 **Improve update-memory.sh** - LOW (works, just not intuitive)

## Summary

**Current State:**
- Dashboard tools: ✅ Working perfectly
- Statistics tools: ✅ Working correctly
- Update tools: ⚠️ Work but not user-friendly

**Needed:**
- Simple helper script for adding entries
- Better documentation of existing tools
- Clear workflow for agents vs users

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-18  
**Related:** dashboard-auto-update.md, README.md

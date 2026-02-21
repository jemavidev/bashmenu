#!/bin/bash
# Auto-update active-context.json based on memory state
# Runs automatically via hook after agent execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$PROJECT_ROOT/.kiro/memory"
CONTEXT_FILE="$MEMORY_DIR/active-context.json"

# Read current memory state
DECISIONS=$(jq '.decisions' "$MEMORY_DIR/decision-log.json")
TASKS=$(jq '.tasks' "$MEMORY_DIR/progress.json")
PATTERNS=$(jq '.patterns' "$MEMORY_DIR/patterns.json")

# Get recent items (last 3)
RECENT_DECISIONS=$(echo "$DECISIONS" | jq '[.[] | {id, title, date}] | sort_by(.date) | reverse | .[0:3]')
RECENT_TASKS=$(echo "$TASKS" | jq '[.[] | {id, title, status, date}] | sort_by(.date) | reverse | .[0:5]')
ACTIVE_PATTERNS=$(echo "$PATTERNS" | jq '[.[] | {id, title, date}] | .[0:3]')

# Get open tasks (in-progress or blocked)
OPEN_TASKS=$(echo "$TASKS" | jq '[.[] | select(.status == "in-progress" or .status == "blocked") | {id, title, status, date}]')

# Get pending tasks
PENDING_TASKS=$(echo "$TASKS" | jq '[.[] | select(.status == "in-progress" or .status == "blocked")] | length')
COMPLETED_TASKS=$(echo "$TASKS" | jq '[.[] | select(.status == "completed")] | length')

# Determine current focus from most recent task
CURRENT_FOCUS=$(echo "$TASKS" | jq -r 'sort_by(.date) | reverse | .[0].title // "No active focus"')
CURRENT_PHASE=$(echo "$TASKS" | jq -r 'sort_by(.date) | reverse | .[0].tags[0] // "general"')

# Get project name from git or directory
PROJECT_NAME=$(basename "$PROJECT_ROOT")
if [ -d "$PROJECT_ROOT/.git" ]; then
    GIT_REMOTE=$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null || echo "")
    if [ -n "$GIT_REMOTE" ]; then
        PROJECT_NAME=$(basename "$GIT_REMOTE" .git)
    fi
fi

# Build context JSON
TIMESTAMP=$(date -Iseconds)
READABLE_TIME=$(date "+%Y-%m-%d %H:%M:%S")

cat > "$CONTEXT_FILE" << EOF
{
  "version": "1.0.0",
  "lastUpdated": "$TIMESTAMP",
  "project": {
    "name": "$PROJECT_NAME",
    "description": "Auto-updated from memory",
    "phase": "$CURRENT_PHASE",
    "startDate": ""
  },
  "currentFocus": {
    "feature": "$CURRENT_FOCUS",
    "objective": "Continue work on current tasks",
    "priority": "medium",
    "estimatedCompletion": ""
  },
  "techStack": {
    "languages": [],
    "frameworks": [],
    "databases": [],
    "tools": []
  },
  "team": {
    "size": 1,
    "roles": ["developer"],
    "activeAgents": ["AgentX"]
  },
  "constraints": {
    "timeline": "",
    "budget": "",
    "technical": [],
    "business": []
  },
  "nextSteps": [],
  "blockers": [],
  "context": {
    "recentDecisions": $RECENT_DECISIONS,
    "activePatterns": $ACTIVE_PATTERNS,
    "openTasks": $OPEN_TASKS,
    "recentTasks": $RECENT_TASKS,
    "stats": {
      "pendingTasks": $PENDING_TASKS,
      "completedTasks": $COMPLETED_TASKS,
      "lastUpdate": "$READABLE_TIME"
    }
  },
  "_comments": {
    "dateFormat": "Use ISO 8601 format with timezone",
    "example": "2026-02-16T09:30:00-05:00",
    "autoUpdated": "This file is automatically updated by update-context.sh"
  }
}
EOF

echo "✅ Context updated: $READABLE_TIME"
echo "   Focus: $CURRENT_FOCUS"
echo "   Pending: $PENDING_TASKS tasks"
echo "   Completed: $COMPLETED_TASKS tasks"

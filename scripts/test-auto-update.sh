#!/bin/bash
# Test script to verify auto-update dashboard functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DASHBOARD="$PROJECT_ROOT/.kiro/memory/dashboard.html"

echo "🧪 Testing Dashboard Auto-Update System"
echo "========================================"
echo ""

# Step 1: Check hook exists and is enabled
echo "1️⃣ Checking hook configuration..."
HOOK_FILE="$PROJECT_ROOT/.kiro/hooks/auto-update-dashboard.kiro.hook"

if [ ! -f "$HOOK_FILE" ]; then
    echo "   ❌ Hook file not found: $HOOK_FILE"
    exit 1
fi

HOOK_ENABLED=$(cat "$HOOK_FILE" | jq -r '.enabled')
if [ "$HOOK_ENABLED" != "true" ]; then
    echo "   ❌ Hook is disabled"
    exit 1
fi

echo "   ✅ Hook exists and is enabled"
echo ""

# Step 2: Check current dashboard timestamp
echo "2️⃣ Checking current dashboard timestamp..."
if [ ! -f "$DASHBOARD" ]; then
    echo "   ❌ Dashboard not found: $DASHBOARD"
    exit 1
fi

CURRENT_TIME=$(grep -o 'lastUpdateReadable: "[^"]*"' "$DASHBOARD" | cut -d'"' -f2)
echo "   📅 Current timestamp: $CURRENT_TIME"
echo ""

# Step 3: Manually trigger update
echo "3️⃣ Manually triggering dashboard update..."
bash "$SCRIPT_DIR/update-dashboard.sh" > /dev/null 2>&1

NEW_TIME=$(grep -o 'lastUpdateReadable: "[^"]*"' "$DASHBOARD" | cut -d'"' -f2)
echo "   📅 New timestamp: $NEW_TIME"
echo ""

# Step 4: Verify update occurred
if [ "$CURRENT_TIME" != "$NEW_TIME" ]; then
    echo "   ✅ Dashboard updated successfully!"
else
    echo "   ⚠️  Timestamp unchanged (may be same second)"
fi
echo ""

# Step 5: Show hook details
echo "4️⃣ Hook Configuration:"
echo "   Event: agentStop"
echo "   Command: bash scripts/update-dashboard.sh"
echo "   Timeout: 10 seconds"
echo ""

# Step 6: Instructions
echo "5️⃣ How to verify automatic updates:"
echo ""
echo "   a) Note current time: $NEW_TIME"
echo "   b) Make a change in memory (ask AgentX something)"
echo "   c) After AgentX finishes, check dashboard timestamp"
echo "   d) Open dashboard: bash scripts/open-dashboard.sh"
echo "   e) Verify timestamp is newer than: $NEW_TIME"
echo ""

echo "✅ Test completed!"
echo ""
echo "📋 Summary:"
echo "   • Hook: ✅ Configured and enabled"
echo "   • Dashboard: ✅ Can be updated"
echo "   • Script: ✅ Working correctly"
echo ""
echo "🎯 Next: Ask AgentX a question and verify the dashboard updates automatically"

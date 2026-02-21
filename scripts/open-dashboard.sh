#!/bin/bash
# Script to update and open the Memory Dashboard
# Can also be used to just update without opening

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if --update-only flag is provided
UPDATE_ONLY=false
if [ "$1" == "--update-only" ]; then
    UPDATE_ONLY=true
fi

echo "🔄 Updating Memory Dashboard..."
"$SCRIPT_DIR/update-dashboard.sh"

if [ $? -eq 0 ]; then
    if [ "$UPDATE_ONLY" = false ]; then
        echo ""
        echo "🌐 Opening dashboard..."
        xdg-open "$PROJECT_ROOT/.kiro/memory/dashboard.html"
    else
        echo "✅ Dashboard updated (not opening)"
    fi
else
    echo "❌ Error updating dashboard"
    exit 1
fi

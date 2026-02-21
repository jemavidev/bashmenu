#!/bin/bash
# Inject project metrics card into dashboard template

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$PROJECT_ROOT/templates/memory/dashboard.html"
METRICS_FILE="$PROJECT_ROOT/.kiro/memory/project-metrics.json"

# Read metrics
if [ ! -f "$METRICS_FILE" ]; then
    echo "⚠️  Metrics file not found, run update-project-metrics.sh first"
    exit 0
fi

PROJECT_TOKENS=$(jq -r '.project.totalTokens // 0' "$METRICS_FILE")
MEMORY_TOKENS=$(jq -r '.memory.summary.totalTokens // 0' "$METRICS_FILE")
LLM_TOTAL=$(jq -r '.llm.totals.total // 0' "$METRICS_FILE")
LLM_INPUT=$(jq -r '.llm.totals.input // 0' "$METRICS_FILE")
LLM_OUTPUT=$(jq -r '.llm.totals.output // 0' "$METRICS_FILE")
EFFICIENCY=$(jq -r '.efficiency.memoryToProject // 0' "$METRICS_FILE")

# Format numbers
PROJECT_FORMATTED=$(printf "%'d" $PROJECT_TOKENS)
MEMORY_FORMATTED=$(printf "%'d" $MEMORY_TOKENS)
LLM_FORMATTED=$(printf "%'d" $LLM_TOTAL)
EFFICIENCY_PCT=$(awk "BEGIN {printf \"%.2f\", $EFFICIENCY * 100}")

# Create metrics card HTML
METRICS_CARD=$(cat << 'HTMLEOF'
        
        <-*/-*//-*/-/*-*+++ Project Metrics Section -->
        <div class="stats-card" id="metricsCard" style="display: none;">
            <div class="stats-header">
                <span>📈 Project Metrics</span>
            </div>
            
            <div class="metrics-summary" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0;">
                <div class="metric-card" style="background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; text-align: center;">
                    <div style="font-size: 2em; margin-bottom: 10px;">📦</div>
                    <div style="font-size: 2em; font-weight: bold; color: var(--accent-start);">PROJECT_TOKENS_PLACEHOLDER</div>
                    <div style="color: var(--text-secondary); margin-top: 5px;">Project Size</div>
                    <div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 5px;">Total tokens</div>
                </div>
                
                <div class="metric-card" style="background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; text-align: center;">
                    <div style="font-size: 2em; margin-bottom: 10px;">💾</div>
                    <div style="font-size: 2em; font-weight: bold; color: var(--accent-start);">MEMORY_TOKENS_PLACEHOLDER</div>
                    <div style="color: var(--text-secondary); margin-top: 5px;">Memory Size</div>
                    <div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 5px;">Documented knowledge</div>
                </div>
                
                <div class="metric-card" style="background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; text-align: center;">
                    <div style="font-size: 2em; margin-bottom: 10px;">🔢</div>
                    <div style="font-size: 2em; font-weight: bold; color: var(--accent-start);">LLM_TOKENS_PLACEHOLDER</div>
                    <div style="color: var(--text-secondary); margin-top: 5px;">LLM Consumed</div>
                    <div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 5px;">Total usage</div>
                </div>
                
                <div class="metric-card" style="background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 20px; text-align: center;">
                    <div style="font-size: 2em; margin-bottom: 10px;">⚡</div>
                    <div style="font-size: 2em; font-weight: bold; color: var(--accent-start);">EFFICIENCY_PLACEHOLDER%</div>
                    <div style="color: var(--text-secondary); margin-top: 5px;">Efficiency</div>
                    <div style="font-size: 0.9em; color: var(--text-secondary); margin-top: 5px;">Memory/Project ratio</div>
                </div>
            </div>
            
            <div style="margin-top: 30px; padding: 20px; background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px;">
                <h3 style="margin: 0 0 15px 0; color: var(--text-primary);">📊 Breakdown</h3>
                <div style="display: grid; gap: 10px;">
                    <div style="display: flex; justify-content: space-between; padding: 10px; background: var(--bg-primary); border-radius: 8px;">
                        <span>Project Size:</span>
                        <span style="font-weight: bold;">PROJECT_TOKENS_PLACEHOLDER tokens</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 10px; background: var(--bg-primary); border-radius: 8px;">
                        <span>Memory Documentation:</span>
                        <span style="font-weight: bold;">MEMORY_TOKENS_PLACEHOLDER tokens</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 10px; background: var(--bg-primary); border-radius: 8px;">
                        <span>LLM Input:</span>
                        <span style="font-weight: bold;">LLM_INPUT_PLACEHOLDER tokens</span>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 10px; background: var(--bg-primary); border-radius: 8px;">
                        <span>LLM Output:</span>
                        <span style="font-weight: bold;">LLM_OUTPUT_PLACEHOLDER tokens</span>
                    </div>
                </div>
            </div>
            
            <div style="margin-top: 20px; padding: 15px; background: var(--accent-start); color: white; border-radius: 12px; text-align: center;">
                <div style="font-size: 0.9em; opacity: 0.9;">Memory captures EFFICIENCY_PLACEHOLDER% of project knowledge</div>
                <div style="font-size: 0.8em; margin-top: 5px; opacity: 0.8;">Higher is better - aim for >0.5%</div>
            </div>
        </div>
HTMLEOF
)

# Replace placeholders
METRICS_CARD="${METRICS_CARD//PROJECT_TOKENS_PLACEHOLDER/$PROJECT_FORMATTED}"
METRICS_CARD="${METRICS_CARD//MEMORY_TOKENS_PLACEHOLDER/$MEMORY_FORMATTED}"
METRICS_CARD="${METRICS_CARD//LLM_TOKENS_PLACEHOLDER/$LLM_FORMATTED}"
METRICS_CARD="${METRICS_CARD//LLM_INPUT_PLACEHOLDER/$(printf "%'d" $LLM_INPUT)}"
METRICS_CARD="${METRICS_CARD//LLM_OUTPUT_PLACEHOLDER/$(printf "%'d" $LLM_OUTPUT)}"
METRICS_CARD="${METRICS_CARD//EFFICIENCY_PLACEHOLDER/$EFFICIENCY_PCT}"

# Check if metrics card already exists
if grep -q "id=\"metricsCard\"" "$TEMPLATE"; then
    echo "✅ Metrics card already in template"
else
    # Find tokenStats closing div and insert after it
    # This is a simplified approach - in production would use proper HTML parsing
    echo "⚠️  Metrics card not in template - manual integration needed"
    echo "   Add metricsCard div after tokenStats in dashboard template"
fi

echo "✅ Metrics ready: Project $PROJECT_FORMATTED | Memory $MEMORY_FORMATTED | Efficiency $EFFICIENCY_PCT%"

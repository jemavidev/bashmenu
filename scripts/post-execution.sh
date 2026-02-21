#!/bin/bash

# Post-Execution Tasks
# Runs metrics and dashboard updates (summary has its own hook)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Calculate project size
bash "$SCRIPT_DIR/calculate-project-size.sh" || true

# 2. Update memory dashboard
bash "$SCRIPT_DIR/update-dashboard.sh" || true

# 3. Update project context
bash "$SCRIPT_DIR/update-context.sh" || true

# 4. Estimate LLM usage
bash "$SCRIPT_DIR/estimate-llm-usage.sh" || true

exit 0

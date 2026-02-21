# Token Tracking System

## Overview

The token tracking system monitors memory usage to help manage cleanup decisions and track agent/skill contributions.

## Features

- Automatic token calculation for all memory entries
- Global statistics in `memory-stats.json`
- Dashboard visualization with progress bars
- Agent and skill attribution
- Cleanup recommendations
- Archive functionality

## Token Calculation

Tokens are estimated using the formula:
```
tokens = Math.ceil(JSON.stringify(entry).length / 4)
```

This approximation (4 characters per token) is industry standard and sufficient for tracking purposes.

## Files

### memory-stats.json

Global statistics file containing:
- Total tokens across all memory files
- Breakdown by category (decisions, tasks, patterns)
- Breakdown by agent
- Breakdown by skill (if used)
- Cleanup recommendations

### Scripts

- `calculate-tokens.sh` - Calculates tokens and updates stats
- `cleanup-memory.sh` - Archives old entries
- `update-memory.sh` - Enhanced with automatic token calculation
- `update-dashboard.sh` - Embeds stats in dashboard

## Usage

### View Current Stats

```bash
cat .kiro/memory/memory-stats.json | jq '.summary'
```

### Recalculate Tokens

```bash
bash scripts/calculate-tokens.sh
```

### Cleanup Old Entries

```bash
bash scripts/cleanup-memory.sh
```

The script will:
1. Show current usage
2. List oldest entries
3. Offer archive options (30/60/90 days)
4. Archive selected entries
5. Recalculate statistics

### Dashboard

Token statistics appear automatically in the dashboard:
- Total memory usage with progress bar
- Category breakdown
- Agent attribution
- Skill usage (if applicable)
- Cleanup status indicator

## Thresholds

- 0-50%: ✅ Healthy (green)
- 50-75%: ⚠️ Review (yellow)
- 75-100%: 🚨 Cleanup Needed (red)

Default threshold: 50,000 tokens

## Entry Structure

Each memory entry now includes a `tokens` field:

```json
{
  "id": "DEC-001",
  "date": "2026-02-17T07:00:00-05:00",
  "title": "Example decision",
  "tokens": 145,
  "agent": "AgentX/Architect",
  "skills": ["architecture-patterns"]
}
```

## Automatic Updates

Token calculation runs automatically when:
- Adding new entries via `update-memory.sh`
- Running `calculate-tokens.sh` manually
- After cleanup operations

## Best Practices

1. Run `calculate-tokens.sh` after manual JSON edits
2. Review cleanup recommendations when usage exceeds 50%
3. Archive entries older than 90 days regularly
4. Check dashboard stats periodically

## Troubleshooting

### Tokens not calculating

Ensure jq is installed:
```bash
which jq || sudo apt install jq
```

### Stats not showing in dashboard

Regenerate dashboard:
```bash
bash scripts/update-dashboard.sh
```

### Incorrect token counts

Recalculate:
```bash
bash scripts/calculate-tokens.sh
```

## Implementation Details

- Token calculation uses bash + jq
- Stats aggregation happens in `calculate-tokens.sh`
- Dashboard loads stats from embedded data or fetch
- Cleanup creates timestamped archives in `.kiro/memory/archive/`

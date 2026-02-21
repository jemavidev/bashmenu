# Project Metrics System - Complete Design

## Overview

Track the complete lifecycle of project development: how much context was consumed (LLM tokens), how much the project weighs (all files), and the efficiency of memory generation.

---

## 1. Core Metrics

### 1.1 LLM Token Consumption (Input/Output)
**What:** Total tokens consumed by LLM during development
**Why:** Understand the "cost" of building the project
**How:** Manual logging after each work session

```json
{
  "sessions": [
    {
      "id": "SESSION-001",
      "timestamp": "2026-02-18T08:00:00-05:00",
      "input": 50000,
      "output": 45000,
      "total": 95000,
      "description": "Implemented dashboard clickable links",
      "agent": "AgentX/Coder",
      "tags": ["dashboard", "ux"]
    }
  ],
  "totals": {
    "input": 2000000,
    "output": 1800000,
    "total": 3800000,
    "sessions": 42
  },
  "averages": {
    "perSession": 90476,
    "inputRatio": 0.53,
    "outputRatio": 0.47
  }
}
```

### 1.2 Project Size (Context Weight)
**What:** Total tokens of all project files
**Why:** Understand how much context the project requires to load
**How:** Automatic calculation scanning all files

```json
{
  "totalTokens": 1400000,
  "lastCalculated": "2026-02-18T08:30:00-05:00",
  "byCategory": {
    "code": 800000,
    "documentation": 350000,
    "memory": 7050,
    "steering": 150000,
    "config": 50000,
    "tests": 42950
  },
  "byFileType": {
    ".js": 450000,
    ".md": 400000,
    ".json": 250000,
    ".sh": 200000,
    ".html": 100000
  },
  "topFiles": [
    {
      "path": "templates/memory/dashboard.html",
      "tokens": 33970,
      "percentage": 2.4
    }
  ],
  "growth": {
    "lastWeek": 50000,
    "lastMonth": 200000,
    "trend": "increasing"
  }
}
```

### 1.3 Memory Efficiency
**What:** Relationship between consumed tokens, project size, and memory
**Why:** Measure how efficiently memory captures project knowledge
**How:** Calculated from other metrics

```json
{
  "memorySize": 7050,
  "projectSize": 1400000,
  "consumed": 3800000,
  "ratios": {
    "memoryToProject": 0.005,
    "memoryToConsumed": 0.0019,
    "projectToConsumed": 0.368
  },
  "interpretation": {
    "memoryToProject": "Memory is 0.5% of project size (very efficient)",
    "memoryToConsumed": "Generated 7K memory from 3.8M tokens (0.19% efficiency)",
    "projectToConsumed": "Project is 37% of consumed tokens (good compression)"
  }
}
```

---

## 2. Data Storage Structure

### File: `.kiro/memory/project-metrics.json`

```json
{
  "version": "1.0.0",
  "project": {
    "name": "BetterAgents",
    "startDate": "2025-12-10T00:00:00-05:00",
    "lastUpdated": "2026-02-18T08:30:00-05:00"
  },
  "llm": {
    "sessions": [...],
    "totals": {...},
    "averages": {...},
    "byAgent": {
      "AgentX/Coder": 1200000,
      "AgentX/Architect": 800000,
      "AgentX/DevOps": 600000
    },
    "byPhase": {
      "design": 500000,
      "implementation": 2000000,
      "optimization": 800000,
      "documentation": 500000
    }
  },
  "project": {
    "totalTokens": 1400000,
    "lastCalculated": "2026-02-18T08:30:00-05:00",
    "byCategory": {...},
    "byFileType": {...},
    "topFiles": [...],
    "growth": {...}
  },
  "memory": {
    "size": 7050,
    "entries": 33,
    "byType": {
      "decisions": 3367,
      "tasks": 1886,
      "patterns": 1797
    }
  },
  "efficiency": {
    "memoryToProject": 0.005,
    "memoryToConsumed": 0.0019,
    "projectToConsumed": 0.368
  },
  "costs": {
    "estimatedCost": 11.40,
    "currency": "USD",
    "model": "claude-sonnet-3.5",
    "pricing": {
      "input": 0.003,
      "output": 0.015
    }
  }
}
```

---

## 3. Scripts

### 3.1 `log-llm-usage.sh`
**Purpose:** Manually log LLM token usage after work session

```bash
# Usage
bash scripts/log-llm-usage.sh <input> <output> [description] [agent] [tags]

# Examples
bash scripts/log-llm-usage.sh 50000 45000 "Implemented dashboard" "AgentX/Coder" "dashboard,ux"
bash scripts/log-llm-usage.sh 30000 28000 "Fixed bugs"
```

**Features:**
- Validates input (positive integers)
- Auto-generates session ID
- Calculates cumulative totals
- Updates averages
- Creates backup before write
- Shows summary with formatted numbers

### 3.2 `calculate-project-size.sh`
**Purpose:** Calculate total tokens of all project files

```bash
# Usage
bash scripts/calculate-project-size.sh [--exclude-pattern]

# Examples
bash scripts/calculate-project-size.sh
bash scripts/calculate-project-size.sh --exclude "node_modules,dist"
```

**Features:**
- Scans all files in project
- Respects .gitignore
- Categorizes by file type
- Identifies top 20 largest files
- Calculates growth since last run
- Excludes binary files
- Uses tiktoken for accurate counting

### 3.3 `calculate-metrics.sh`
**Purpose:** Calculate all efficiency metrics

```bash
# Usage
bash scripts/calculate-metrics.sh

# Output
📊 Project Metrics Summary
==========================
LLM Consumed: 3.8M tokens (2M input + 1.8M output)
Project Size: 1.4M tokens
Memory Size: 7K tokens

Efficiency Ratios:
  Memory/Project: 0.5% (very efficient)
  Memory/Consumed: 0.19% (low capture rate)
  Project/Consumed: 37% (good compression)

Estimated Cost: $11.40 USD
```

### 3.4 `show-metrics.sh`
**Purpose:** Display formatted metrics summary

```bash
# Usage
bash scripts/show-metrics.sh [--detailed]

# Output (summary)
📊 BetterAgents Project Metrics
================================
🔢 LLM Usage: 3.8M tokens ($11.40)
📦 Project Size: 1.4M tokens
💾 Memory: 7K tokens (33 entries)
⚡ Efficiency: 0.5% memory/project

# Output (detailed)
[Shows full breakdown by category, agent, phase, timeline]
```

### 3.5 `export-metrics.sh`
**Purpose:** Export metrics to various formats

```bash
# Usage
bash scripts/export-metrics.sh <format> [output-file]

# Formats: json, csv, markdown, html
bash scripts/export-metrics.sh csv metrics.csv
bash scripts/export-metrics.sh markdown report.md
```

---

## 4. Dashboard Integration

### 4.1 New Tab: "Project Metrics"

**Layout:**
```
┌─────────────────────────────────────────────────┐
│ 📊 Project Metrics                              │
├─────────────────────────────────────────────────┤
│                                                 │
│  LLM Token Consumption                          │
│  ┌─────────────────────────────────────────┐   │
│  │ Total: 3.8M tokens                      │   │
│  │ Input: 2M (53%) | Output: 1.8M (47%)   │   │
│  │ Sessions: 42 | Avg: 90K/session        │   │
│  │ Cost: $11.40 USD                        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Project Size                                   │
│  ┌─────────────────────────────────────────┐   │
│  │ Total: 1.4M tokens                      │   │
│  │ Code: 800K | Docs: 350K | Memory: 7K   │   │
│  │ Growth: +50K last week                  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Efficiency Metrics                             │
│  ┌─────────────────────────────────────────┐   │
│  │ Memory/Project: 0.5% ✅                 │   │
│  │ Memory/Consumed: 0.19% ⚠️               │   │
│  │ Project/Consumed: 37% ✅                │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  📈 Timeline Chart                              │
│  [Interactive chart showing growth over time]   │
│                                                 │
│  📊 Breakdown by Agent                          │
│  [Bar chart: Coder 1.2M, Architect 800K, etc]  │
│                                                 │
│  📁 Top Files by Size                           │
│  [Table: dashboard.html 34K, etc]              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 4.2 Metrics Cards (Summary View)

```html
<div class="metrics-summary">
  <div class="metric-card">
    <div class="metric-icon">🔢</div>
    <div class="metric-value">3.8M</div>
    <div class="metric-label">LLM Tokens</div>
    <div class="metric-change">+95K this session</div>
  </div>
  
  <div class="metric-card">
    <div class="metric-icon">📦</div>
    <div class="metric-value">1.4M</div>
    <div class="metric-label">Project Size</div>
    <div class="metric-change">+50K this week</div>
  </div>
  
  <div class="metric-card">
    <div class="metric-icon">💾</div>
    <div class="metric-value">7K</div>
    <div class="metric-label">Memory</div>
    <div class="metric-change">33 entries</div>
  </div>
  
  <div class="metric-card">
    <div class="metric-icon">⚡</div>
    <div class="metric-value">0.5%</div>
    <div class="metric-label">Efficiency</div>
    <div class="metric-change">Memory/Project</div>
  </div>
</div>
```

### 4.3 Interactive Charts

**1. Token Consumption Timeline**
- X-axis: Date
- Y-axis: Cumulative tokens
- Lines: Input (blue), Output (green), Total (purple)
- Hover: Show session details

**2. Project Growth**
- X-axis: Date
- Y-axis: Project size in tokens
- Area chart showing growth
- Annotations for major milestones

**3. Efficiency Over Time**
- X-axis: Date
- Y-axis: Efficiency ratio
- Line chart showing trend
- Target line at optimal efficiency

**4. Token Distribution**
- Pie chart: By category (code, docs, memory, etc)
- Bar chart: By agent
- Stacked bar: By phase

---

## 5. Automation & Hooks

### 5.1 Auto-calculate on agent stop

**Hook:** `.kiro/hooks/auto-calculate-metrics.kiro.hook`

```json
{
  "name": "Auto-Calculate Project Metrics",
  "version": "1.0.0",
  "when": {
    "type": "agentStop"
  },
  "then": {
    "type": "runCommand",
    "command": "bash scripts/calculate-project-size.sh && bash scripts/calculate-metrics.sh"
  }
}
```

### 5.2 Prompt for LLM logging

**Hook:** `.kiro/hooks/prompt-llm-logging.kiro.hook`

```json
{
  "name": "Prompt LLM Token Logging",
  "version": "1.0.0",
  "when": {
    "type": "agentStop"
  },
  "then": {
    "type": "askAgent",
    "prompt": "Session complete. Log LLM tokens? Run: bash scripts/log-llm-usage.sh <input> <output> '<description>'"
  }
}
```

---

## 6. Advanced Features

### 6.1 Session Tagging
Tag sessions by type for better analysis:
- `feature` - New feature implementation
- `bugfix` - Bug fixes
- `refactor` - Code refactoring
- `docs` - Documentation
- `optimization` - Performance optimization

### 6.2 Cost Tracking
Calculate estimated costs based on model pricing:
- Claude Sonnet 3.5: $3/M input, $15/M output
- GPT-4: $10/M input, $30/M output
- Custom pricing support

### 6.3 Benchmarking
Compare against similar projects:
- Tokens per feature
- Memory efficiency
- Cost per 1K lines of code

### 6.4 Alerts & Thresholds
Notify when metrics exceed thresholds:
- Project size > 2M tokens (context limit warning)
- LLM consumption > $50 (budget alert)
- Memory efficiency < 0.1% (under-documenting)

### 6.5 Export & Reporting
Generate reports for:
- Weekly summaries
- Monthly cost reports
- Project completion reports
- Efficiency analysis

---

## 7. Implementation Phases

### Phase 1: Core Tracking (Week 1)
- ✅ `log-llm-usage.sh` - Manual LLM logging
- ✅ `calculate-project-size.sh` - Project size calculation
- ✅ `project-metrics.json` - Data storage
- ✅ Basic metrics calculation

### Phase 2: Dashboard Integration (Week 2)
- Add "Project Metrics" tab to dashboard
- Display summary cards
- Show basic charts (timeline, distribution)
- Real-time updates

### Phase 3: Automation (Week 3)
- Auto-calculate hooks
- Prompt for LLM logging
- Scheduled calculations
- Backup and archiving

### Phase 4: Advanced Features (Week 4)
- Session tagging
- Cost tracking
- Benchmarking
- Alerts and notifications
- Export and reporting

---

## 8. Data Flow

```
┌─────────────────────────────────────────────────┐
│ User Work Session                               │
│ (Using Kiro with LLM)                          │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Manual: log-llm-usage.sh                        │
│ Input: 50K tokens, Output: 45K tokens          │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Update: llm-usage.json                          │
│ Add session, update totals                      │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Auto: calculate-project-size.sh                 │
│ (Triggered by agentStop hook)                   │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Scan all project files                          │
│ Calculate tokens by category                    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Update: project-metrics.json                    │
│ Store project size, growth, breakdown           │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Auto: calculate-metrics.sh                      │
│ Calculate efficiency ratios                     │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Update: project-metrics.json                    │
│ Add efficiency metrics, costs                   │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Auto: update-dashboard.sh                       │
│ Regenerate dashboard with new metrics           │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│ Dashboard displays updated metrics              │
│ User views: LLM usage, project size, efficiency │
└─────────────────────────────────────────────────┘
```

---

## 9. Example Usage Scenarios

### Scenario 1: Daily Development
```bash
# Morning: Start work
bash scripts/show-metrics.sh

# Work on features...
# (Kiro tracks context automatically)

# Evening: Log session
bash scripts/log-llm-usage.sh 60000 55000 "Implemented export feature" "AgentX/Coder" "feature,export"

# View updated metrics
bash scripts/show-metrics.sh --detailed
```

### Scenario 2: Weekly Review
```bash
# Generate weekly report
bash scripts/export-metrics.sh markdown weekly-report.md

# Check efficiency trends
bash scripts/calculate-metrics.sh

# Review dashboard
xdg-open .kiro/memory/dashboard.html
```

### Scenario 3: Project Completion
```bash
# Final metrics calculation
bash scripts/calculate-project-size.sh
bash scripts/calculate-metrics.sh

# Generate completion report
bash scripts/export-metrics.sh html project-completion-report.html

# Archive metrics
cp .kiro/memory/project-metrics.json archives/project-metrics-final.json
```

---

## 10. Best Practices

### 10.1 Logging Discipline
- Log LLM usage after EVERY work session
- Be accurate with token counts (check Kiro UI)
- Add meaningful descriptions
- Tag sessions appropriately

### 10.2 Regular Monitoring
- Check metrics weekly
- Review efficiency trends monthly
- Adjust documentation strategy based on ratios
- Archive old metrics quarterly

### 10.3 Cost Management
- Set budget alerts
- Track costs by phase
- Optimize high-token operations
- Use cheaper models for simple tasks

### 10.4 Data Quality
- Validate token counts before logging
- Review project size calculations
- Check for anomalies in growth
- Backup metrics regularly

---

## 11. Future Enhancements

### 11.1 AI-Powered Insights
- Predict project completion based on token trends
- Suggest optimal documentation points
- Identify inefficient patterns
- Recommend cost optimizations

### 11.2 Multi-Project Support
- Track multiple projects
- Compare metrics across projects
- Aggregate team statistics
- Portfolio-level insights

### 11.3 Integration with Git
- Correlate tokens with commits
- Track tokens per feature branch
- Analyze token efficiency by contributor
- Generate commit-based reports

### 11.4 Real-Time Tracking
- Live token counter during work
- Real-time dashboard updates
- Instant efficiency feedback
- Session time tracking

---

## 12. Success Metrics

**System is successful when:**
- ✅ 100% of work sessions logged
- ✅ Project size calculated daily
- ✅ Efficiency ratios tracked over time
- ✅ Costs stay within budget
- ✅ Memory efficiency > 0.3%
- ✅ Dashboard provides actionable insights
- ✅ Reports generated automatically
- ✅ Team uses metrics for decision-making

---

**Version:** 1.0.0  
**Status:** Design Complete - Ready for Implementation  
**Last Updated:** 2026-02-18  
**Author:** AgentX/Architect


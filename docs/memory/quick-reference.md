# Memory Tools Quick Reference

## ✅ Working Tools (Use These)

### View Memory

```bash
# Statistics
bash scripts/memory-stats.sh

# Visual dashboard
bash scripts/open-dashboard.sh

# Raw JSON
cat .kiro/memory/progress.json | jq '.tasks'
cat .kiro/memory/patterns.json | jq '.patterns'
cat .kiro/memory/decision-log.json | jq '.decisions'
```

### Add Entries (NEW - Easy Way)

```bash
# Add task
bash scripts/add-memory-entry.sh task "Title" "Description" "tag1,tag2"

# Add pattern
bash scripts/add-memory-entry.sh pattern "Problem" "Solution" "tag1,tag2"

# Add decision
bash scripts/add-memory-entry.sh decision "Title" "Context" "tag1,tag2"
```

**Examples:**
```bash
bash scripts/add-memory-entry.sh task "Fixed bug" "Resolved memory issue" "bug-fix"
bash scripts/add-memory-entry.sh pattern "Caching strategy" "Use Redis for session data" "performance"
bash scripts/add-memory-entry.sh decision "Use PostgreSQL" "Better for relational data" "database"
```

### Update Dashboard

```bash
# Manual update
bash scripts/update-dashboard.sh

# Update and open
bash scripts/open-dashboard.sh

# Update only (no browser)
bash scripts/open-dashboard.sh --update-only
```

**Note:** Dashboard updates automatically via hook after agent execution.

### Audit Memory

```bash
# Check documentation balance
bash scripts/audit-memory.sh

# Calculate token usage
bash scripts/calculate-tokens.sh
```

### Test Auto-Update

```bash
# Verify hook is working
bash scripts/test-auto-update.sh
```

## 🔧 Advanced Tools

### Manual JSON Update (Complex)

```bash
# Read JSON from stdin
cat new-data.json | bash scripts/update-memory.sh progress
```

**Use this only when:**
- Bulk importing data
- Restoring from backup
- Complex JSON transformations

**For simple updates, use `add-memory-entry.sh` instead.**

### Direct jq Editing

```bash
# Add entry manually
jq '.tasks += [{"id":"TASK-XXX","title":"New"}]' .kiro/memory/progress.json > tmp.json
mv tmp.json .kiro/memory/progress.json
```

## 📋 Common Workflows

### Document Completed Work

```bash
bash scripts/add-memory-entry.sh task \
  "Implemented feature X" \
  "Added authentication with JWT tokens" \
  "feature,auth,security"
```

### Record Technical Decision

```bash
bash scripts/add-memory-entry.sh decision \
  "Use microservices architecture" \
  "Better scalability and team independence" \
  "architecture,scalability"
```

### Save Reusable Pattern

```bash
bash scripts/add-memory-entry.sh pattern \
  "Repository pattern for data access" \
  "Abstract database operations behind interface" \
  "design-pattern,database"
```

### View Recent Activity

```bash
# Open dashboard
bash scripts/open-dashboard.sh

# Or check stats
bash scripts/memory-stats.sh
```

## 🚨 Troubleshooting

### Dashboard shows old data

```bash
bash scripts/update-dashboard.sh
```

### Hook not updating automatically

```bash
# Check hook exists and is enabled
cat .kiro/hooks/auto-update-dashboard.kiro.hook | jq '.enabled'

# Should return: true
```

### Entry not appearing

```bash
# Verify it was added
jq '.tasks | length' .kiro/memory/progress.json

# Update dashboard
bash scripts/update-dashboard.sh

# Open to verify
bash scripts/open-dashboard.sh
```

### File corrupted or empty

```bash
# Restore from backup
ls -lt .kiro/memory/backups/progress_*.json | head -1

# Copy the latest valid backup
cp .kiro/memory/backups/progress_YYYYMMDD_HHMMSS.json .kiro/memory/progress.json
```

## 📚 File Locations

```
.kiro/memory/
├── progress.json          # Tasks and milestones
├── patterns.json          # Reusable solutions
├── decision-log.json      # Technical decisions
├── active-context.json    # Current project context
├── memory-stats.json      # Token usage statistics
├── dashboard.html         # Visual interface
└── backups/              # Automatic backups
    ├── progress_*.json
    ├── patterns_*.json
    └── decision-log_*.json
```

## 🎯 Best Practices

1. **Use `add-memory-entry.sh`** for quick updates
2. **Let the hook work** - dashboard updates automatically
3. **Check dashboard** regularly for overview
4. **Use tags** consistently for better filtering
5. **Keep descriptions concise** (100-150 tokens)

## ⚡ Quick Commands

```bash
# Most common operations
alias mem-add='bash scripts/add-memory-entry.sh'
alias mem-view='bash scripts/open-dashboard.sh'
alias mem-stats='bash scripts/memory-stats.sh'

# Usage
mem-add task "Title" "Description" "tags"
mem-view
mem-stats
```

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-18  
**See also:** tools-usage-guide.md, dashboard-auto-update.md

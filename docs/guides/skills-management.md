# 🔄 Skills Update Guide - BetterAgents

This guide explains how to keep your skills always updated to get the latest improvements and features.

---

## 📋 Table of Contents

1. [Why Update?](#why-update)
2. [Update Methods](#update-methods)
3. [Automatic Update](#automatic-update)
4. [Manual Update](#manual-update)
5. [Update Verification](#update-verification)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Why Update?

Skills are frequently updated with:

- ✅ **New features** - Enhanced capabilities
- ✅ **Bug fixes** - Better stability
- ✅ **Performance improvements** - Faster responses
- ✅ **New patterns** - Updated best practices
- ✅ **Compatibility** - Support for new versions

**Recommendation:** Update weekly for active projects.

---

## 🚀 Update Methods

### Method 1: Automatic Script (Recommended)

The simplest and safest method:

```bash
./update-skills.sh
```

**Features:**
- ✅ Verifies installed skills
- ✅ Detects available updates
- ✅ Updates all skills
- ✅ Shows change summary
- ✅ Handles errors automatically

**Process:**
1. Run the script
2. Review available updates
3. Confirm the update
4. Wait for completion
5. Done!

---

### Method 2: CLI Commands

For more manual control:

```bash
# 1. Check for updates
npx skills check

# 2. Update all skills
npx skills update

# 3. Verify they were updated
npx skills list
```

---

### Method 3: During Installation

When running `install.sh`, if you already have skills installed:

```bash
./install.sh
```

The script will detect existing skills and offer:
1. Update existing skills
2. Install additional skills
3. Skip skills management

---

## 🤖 Automatic Update

### Configure Automatic Update

Edit `.betteragents-config`:

```bash
# Enable automatic update
AUTO_UPDATE_SKILLS=true

# Check frequency (in days)
UPDATE_CHECK_FREQUENCY=7

# Update without asking
SILENT_UPDATE=true
```

### Create Scheduled Task (Cron)

To automatically update every week:

```bash
# Edit crontab
crontab -e

# Add line (updates every Monday at 9 AM)
0 9 * * 1 cd ~/Documents/GIT/BetterAgents && ./update-skills.sh -y >> ~/betteragents-update.log 2>&1
```

**Cron explanation:**
- `0 9 * * 1` - Monday at 9:00 AM
- `cd ~/Documents/GIT/BetterAgents` - Go to directory
- `./update-skills.sh -y` - Run update (without asking)
- `>> ~/betteragents-update.log 2>&1` - Save log

### Verify Scheduled Task

```bash
# View scheduled tasks
crontab -l

# View update logs
tail -f ~/betteragents-update.log
```

---

## 🔍 Update Verification

### Quick Check

```bash
# Quick check script
./check-updates.sh
```

This script:
- ✅ Verifies if it's time to check (according to configuration)
- ✅ Detects available updates
- ✅ Notifies if there are updates
- ✅ Doesn't update automatically (only informs)

### Manual Verification

```bash
# View available updates
npx skills check

# View installed skills and their versions
npx skills list

# View detailed information about a skill
npx skills info wshobson/agents/architecture-patterns
```

### Detailed Verification

```bash
# View all skills with details
npx skills list --verbose

# Search for specific skill
npx skills find architecture

# View skill changelog (if available)
npx skills info wshobson/agents/architecture-patterns --changelog
```

---

## ⚙️ Configuration

### Configuration File

The `.betteragents-config` file controls update behavior:

```bash
# Automatic skills update
AUTO_UPDATE_SKILLS=false          # true to enable

# Check frequency (in days)
UPDATE_CHECK_FREQUENCY=7          # Check every 7 days

# Last check (timestamp)
LAST_UPDATE_CHECK=0               # Updated automatically

# Notify when updates are available
NOTIFY_UPDATES=true               # Show notifications

# Update skills automatically without asking
SILENT_UPDATE=false               # true to update without confirmation

# Skills to exclude from automatic updates
EXCLUDE_SKILLS=""                 # Comma separated

# Log level (info, warning, error)
LOG_LEVEL=info                    # Detail level

# Save update logs
SAVE_LOGS=true                    # Save history

# Log path
LOG_PATH="./betteragents-update.log"  # Log location
```

### Customize Configuration

```bash
# Edit configuration
nano .betteragents-config

# Or with your preferred editor
code .betteragents-config
```

### Configuration Examples

#### Conservative Configuration
```bash
AUTO_UPDATE_SKILLS=false
UPDATE_CHECK_FREQUENCY=30
SILENT_UPDATE=false
NOTIFY_UPDATES=true
```

#### Aggressive Configuration
```bash
AUTO_UPDATE_SKILLS=true
UPDATE_CHECK_FREQUENCY=1
SILENT_UPDATE=true
NOTIFY_UPDATES=true
```

#### Balanced Configuration (Recommended)
```bash
AUTO_UPDATE_SKILLS=false
UPDATE_CHECK_FREQUENCY=7
SILENT_UPDATE=false
NOTIFY_UPDATES=true
```

---

## 🔧 Advanced Manual Update

### Update Specific Skill

```bash
# Update only one skill
npx skills update wshobson/agents/architecture-patterns

# Update multiple specific skills
npx skills update wshobson/agents/architecture-patterns obra/superpowers/systematic-debugging
```

### Reinstall Skill

If a skill has problems:

```bash
# 1. Uninstall
npx skills remove wshobson/agents/architecture-patterns

# 2. Reinstall
npx skills add wshobson/agents/architecture-patterns
```

### Update with Options

```bash
# Update without confirmation
npx skills update -y

# Update with verbose output
npx skills update --verbose

# Update and show changelog
npx skills update --show-changes
```

---

## 🐛 Troubleshooting

### Problem: "Cannot update skills"

**Solution:**
```bash
# Clear npm cache
npm cache clean --force

# Try updating again
npx skills update
```

---

### Problem: "Permission error"

**Solution:**
```bash
# Check directory permissions
ls -la ~/.npm

# Change owner if necessary
sudo chown -R $USER:$USER ~/.npm

# Try again
npx skills update
```

---

### Problem: "Skill not updating"

**Solution:**
```bash
# Check current version
npx skills list | grep skill-name

# Force reinstallation
npx skills remove skill-name
npx skills add skill-name

# Verify new version
npx skills list | grep skill-name
```

---

### Problem: "Interrupted update"

**Solution:**
```bash
# Check status
npx skills check

# Complete update
npx skills update

# If persists, reinstall problematic skills
npx skills list  # See which are missing
npx skills add missing-skill
```

---

### Problem: "Skills outdated after updating"

**Solution:**
```bash
# Verify update completed
npx skills check

# If there are still pending updates
npx skills update --force

# Verify versions
npx skills list --verbose
```

---

## 📊 Update Monitoring

### View Update History

```bash
# View update log
cat betteragents-update.log

# View last 20 lines
tail -20 betteragents-update.log

# Follow log in real-time
tail -f betteragents-update.log
```

### Skills Statistics

```bash
# Count installed skills
npx skills list | grep -c "^  "

# View skills by category
npx skills list | grep "architecture"
npx skills list | grep "testing"

# View global vs local skills
npx skills list -g  # Global
npx skills list     # Local (project)
```

---

## 🎯 Best Practices

### Update Frequency

| Project Type | Recommended Frequency |
|------------------|------------------------|
| Active development | Weekly |
| Maintenance | Monthly |
| Stable production | Quarterly |
| Before new project | Always |

### Before Updating

1. ✅ Backup your work
2. ✅ Verify there are no unsaved changes
3. ✅ Read changelog of important skills
4. ✅ Have time to test afterwards

### After Updating

1. ✅ Verify agents work
2. ✅ Test critical functionalities
3. ✅ Review logs for errors
4. ✅ Update documentation if necessary

### Recommended Workflow

```bash
# 1. Check available updates
./check-updates.sh

# 2. If there are updates, review what changed
npx skills check

# 3. Make backup (optional)
cp -r .kiro .kiro.backup

# 4. Update
./update-skills.sh

# 5. Test
kiro .
# Test some agents

# 6. If everything works, delete backup
rm -rf .kiro.backup
```

---

## 📚 Quick Reference Commands

```bash
# Verification
npx skills check                    # View available updates
./check-updates.sh                  # Quick check

# Update
npx skills update                   # Update all
./update-skills.sh                  # Automatic script
npx skills update skill-name        # Update specific one

# Information
npx skills list                     # List installed
npx skills list -g                  # List global
npx skills info skill-name          # Info about a skill

# Management
npx skills add skill-name           # Install new
npx skills remove skill-name        # Uninstall
npx skills find keyword             # Search skills

# Configuration
nano .betteragents-config           # Edit config
cat betteragents-update.log         # View logs
```

---

## 🎉 Conclusion

Keeping your skills updated is crucial to:
- Get the latest features
- Improve agent performance
- Fix bugs and issues
- Maintain compatibility

**Final recommendation:** Run `./update-skills.sh` weekly.

---

**Questions?** Open an issue on GitHub or check the main documentation.

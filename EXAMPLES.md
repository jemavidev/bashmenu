# Bashmenu Usage Examples

This document provides practical examples of how to use and extend Bashmenu.

## 📋 Table of Contents

- [Installation and Setup](#installation-and-setup)
- [Basic Usage](#basic-usage)
- [Creating Custom Scripts](#creating-custom-scripts)
- [Advanced Configuration](#advanced-configuration)
- [Common Use Cases](#common-use-cases)

## 🚀 Installation and Setup

### Quick Server Installation

```bash
# Clone repository
git clone https://github.com/jveyes/bashmenu.git
cd bashmenu

# Install (requires sudo)
sudo ./install.sh

# Verify installation
bashmenu --version
```

### First Run

```bash
# Run bashmenu
bashmenu

# You'll see the menu with example scripts:
# 1. Git Status
# 2. Git Pull
# 3. Docker PS
# 4. Docker Logs
# 5. Exit
```

## 💻 Basic Usage

### Menu Navigation

```bash
# Start bashmenu
bashmenu

# Navigation options:
# - Press 1-9 for direct selection
# - Use ↑↓ to navigate
# - Press Enter to execute
# - Press 'd' for dashboard
# - Press 's' for quick status
# - Press 'q' to quit
```

### Real-Time Dashboard

```bash
# From main menu, press 'd'
# You'll see:
# - CPU usage with progress bar
# - Memory usage with progress bar
# - Disk usage with progress bar
# - System information
# - Auto-refresh every 5 seconds
```

### Quick Status Check

```bash
# From main menu, press 's'
# You'll see a quick summary:
# - CPU Usage: 25% ✓
# - Memory Usage: 45% ✓
# - Disk Usage: 60% ✓
# - Service Status: SSH Running ✓
```

## 🔧 Creating Custom Scripts

### Example 1: Simple Backup Script

```bash
# 1. Create the script
sudo nano /opt/bashmenu/plugins/backup_simple.sh
```

```bash
#!/bin/bash
# Simple Backup Script

echo "═══════════════════════════════════════════════"
echo "Simple Backup - Backing up files"
echo "═══════════════════════════════════════════════"
echo ""

# Directory to backup
SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "Backing up: $SOURCE_DIR"
echo "Destination: $BACKUP_FILE"
echo ""

# Create backup
if tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null; then
    echo "✓ Backup completed successfully"
    echo "Size: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "✗ Error creating backup"
    exit 1
fi
```

```bash
# 2. Make it executable
sudo chmod +x /opt/bashmenu/plugins/backup_simple.sh

# 3. Add to scripts.conf
sudo nano /opt/bashmenu/config/scripts.conf
```

Add line:
```
Simple Backup|/opt/bashmenu/plugins/backup_simple.sh|Backup important files|2|
```

### Example 2: Script with Parameters

```bash
# 1. Create deploy script
sudo nano /opt/bashmenu/plugins/deploy_app.sh
```

```bash
#!/bin/bash
# Deploy Script with Parameters

ENVIRONMENT="${1:-staging}"

echo "═══════════════════════════════════════════════"
echo "Deploy Application - Environment: $ENVIRONMENT"
echo "═══════════════════════════════════════════════"
echo ""

case "$ENVIRONMENT" in
    staging)
        echo "Deploying to STAGING..."
        APP_DIR="/var/www/staging"
        ;;
    production)
        echo "Deploying to PRODUCTION..."
        APP_DIR="/var/www/production"
        ;;
    *)
        echo "Error: Unknown environment: $ENVIRONMENT"
        echo "Valid environments: staging, production"
        exit 1
        ;;
esac

echo "Directory: $APP_DIR"
echo ""

# Simulate deploy
echo "1. Stopping application..."
sleep 1
echo "2. Updating code..."
sleep 1
echo "3. Installing dependencies..."
sleep 1
echo "4. Restarting application..."
sleep 1

echo ""
echo "✓ Deploy completed in $ENVIRONMENT"
```

```bash
# 2. Make it executable
sudo chmod +x /opt/bashmenu/plugins/deploy_app.sh

# 3. Add to scripts.conf with default parameter
sudo nano /opt/bashmenu/config/scripts.conf
```

Add lines:
```
Deploy Staging|/opt/bashmenu/plugins/deploy_app.sh|Deploy to staging|2|staging
Deploy Production|/opt/bashmenu/plugins/deploy_app.sh|Deploy to production|3|production
```

### Example 3: Service Monitoring Script

```bash
# 1. Create script
sudo nano /opt/bashmenu/plugins/check_services.sh
```

```bash
#!/bin/bash
# Check Service Status

echo "═══════════════════════════════════════════════"
echo "Service Status Check"
echo "═══════════════════════════════════════════════"
echo ""

# List of services to check
SERVICES=("nginx" "mysql" "redis" "ssh")

for service in "${SERVICES[@]}"; do
    echo -n "Checking $service... "
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "✓ Active"
    else
        echo "✗ Inactive"
    fi
done

echo ""
echo "Check completed"
```

```bash
# 2. Make it executable
sudo chmod +x /opt/bashmenu/plugins/check_services.sh

# 3. Add to scripts.conf
sudo nano /opt/bashmenu/config/scripts.conf
```

Add line:
```
Check Services|/opt/bashmenu/plugins/check_services.sh|Check service status|1|
```

## ⚙️ Advanced Configuration

### Customize Theme

```bash
# Edit configuration
sudo nano /opt/bashmenu/config/config.conf
```

```bash
# Change theme
DEFAULT_THEME="dark"  # Options: default, dark, colorful, minimal, modern
```

### Configure Allowed Directories

```bash
# Edit configuration
sudo nano /opt/bashmenu/config/config.conf
```

```bash
# Add custom directories
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin:/home/user/scripts"
```

### Adjust Logging Level

```bash
# Edit configuration
sudo nano /opt/bashmenu/config/config.conf
```

```bash
# Levels: 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
LOG_LEVEL=1

# Enable debug mode to see logs in terminal
DEBUG_MODE=true
```

## 📚 Common Use Cases

### Use Case 1: Web Server

```bash
# scripts.conf for web server
Restart Nginx|/opt/bashmenu/plugins/restart_nginx.sh|Restart web server|2|
Check Nginx Config|/opt/bashmenu/plugins/check_nginx.sh|Verify configuration|1|
View Access Logs|/opt/bashmenu/plugins/view_logs.sh|View access logs|1|access
View Error Logs|/opt/bashmenu/plugins/view_logs.sh|View error logs|1|error
Backup Website|/opt/bashmenu/plugins/backup_web.sh|Backup website|2|
```

### Use Case 2: Database Server

```bash
# scripts.conf for database server
Backup MySQL|/opt/bashmenu/plugins/backup_mysql.sh|Backup database|2|
Check MySQL Status|/opt/bashmenu/plugins/check_mysql.sh|Check MySQL status|1|
Optimize Tables|/opt/bashmenu/plugins/optimize_mysql.sh|Optimize tables|2|
View Slow Queries|/opt/bashmenu/plugins/slow_queries.sh|View slow queries|1|
```

### Use Case 3: Application Server

```bash
# scripts.conf for application server
Deploy App|/opt/bashmenu/plugins/deploy.sh|Deploy application|3|production
Restart App|/opt/bashmenu/plugins/restart_app.sh|Restart application|2|
View App Logs|/opt/bashmenu/plugins/app_logs.sh|View application logs|1|
Check App Health|/opt/bashmenu/plugins/health_check.sh|Check app health|1|
Run Migrations|/opt/bashmenu/plugins/migrations.sh|Run migrations|3|
```

## 🎯 Tips and Tricks

### Tip 1: Interactive Scripts

```bash
#!/bin/bash
# Script that asks for confirmation

echo "Are you sure you want to continue? (y/n)"
read -r response

if [[ "$response" != "y" ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Continue with operation...
```

### Tip 2: Input Validation

```bash
#!/bin/bash
# Script with validation

PARAM="${1:-}"

if [[ -z "$PARAM" ]]; then
    echo "Error: Parameter required"
    echo "Usage: $0 <parameter>"
    exit 1
fi

# Validate it's numeric
if ! [[ "$PARAM" =~ ^[0-9]+$ ]]; then
    echo "Error: Parameter must be numeric"
    exit 1
fi

# Continue...
```

### Tip 3: Error Handling

```bash
#!/bin/bash
# Script with robust error handling

set -e  # Exit if any command fails

# Cleanup function
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f /tmp/temp_file
}

# Run cleanup on exit
trap cleanup EXIT

# Your code here...
```

## 🔍 Troubleshooting

### Problem: Script not appearing in menu

```bash
# Verify script exists
ls -la /opt/bashmenu/plugins/my_script.sh

# Verify permissions
sudo chmod +x /opt/bashmenu/plugins/my_script.sh

# Verify scripts.conf
sudo cat /opt/bashmenu/config/scripts.conf

# View logs
tail -f /tmp/bashmenu.log
```

### Problem: Permission error

```bash
# Check allowed directories
grep ALLOWED_SCRIPT_DIRS /opt/bashmenu/config/config.conf

# Add directory if needed
sudo nano /opt/bashmenu/config/config.conf
```

### Problem: Script fails to execute

```bash
# Test syntax
bash -n /opt/bashmenu/plugins/my_script.sh

# Run directly to see errors
/opt/bashmenu/plugins/my_script.sh

# View detailed logs
sudo nano /opt/bashmenu/config/config.conf
# Change: LOG_LEVEL=0
# Change: DEBUG_MODE=true
```

## 📖 Additional Resources

- [README.md](README.md) - Main documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guide
- [LICENSE](LICENSE) - Project license

---

Have more examples or use cases? Contribute to the project!

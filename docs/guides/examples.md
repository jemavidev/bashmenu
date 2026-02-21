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

## �  Role-Based Permission System

### Understanding Permission Levels

Bashmenu includes a 3-level permission system to control who can execute which scripts.

#### The Three Levels

1. **Level 1 - User** (Basic user)
   - Any user can execute
   - For read-only, safe operations
   - Examples: view logs, check status, list resources

2. **Level 2 - Admin** (Administrator)
   - Only admin users or root can execute
   - For operations that modify system state
   - Examples: restart services, deploy to staging, backups

3. **Level 3 - Root** (Superuser)
   - Only root user can execute
   - For critical, dangerous operations
   - Examples: deploy to production, system updates, deletions

### Enabling the Permission System

By default, permissions are **DISABLED** for simplicity. To enable:

```bash
# Edit configuration
sudo nano /opt/bashmenu/config/config.conf
```

```bash
# Change this line
ENABLE_PERMISSIONS=true
```

### How User Levels Are Detected

The system automatically detects the user level:

```bash
# Detection logic
if user is "root" → Level 3
elif user is "admin" → Level 2
else → Level 1
```

You can test with different users:

```bash
# Run as regular user (Level 1)
bashmenu

# Run as admin (Level 2) - if you have admin user
sudo -u admin bashmenu

# Run as root (Level 3)
sudo bashmenu
```

### Configuring Script Permissions

When adding scripts to `scripts.conf`, specify the required level in the 4th field:

```bash
# Format: Name|Path|Description|Level|Parameters

# Level 1 - Anyone can execute
Git Status|/opt/bashmenu/plugins/git_operations.sh|Show repository status|1|status
Docker PS|/opt/bashmenu/plugins/docker_manager.sh|Show containers|1|ps
View Logs|/opt/bashmenu/plugins/view_logs.sh|View application logs|1|

# Level 2 - Admin or root only
Git Pull|/opt/bashmenu/plugins/git_operations.sh|Pull latest changes|2|pull
Restart Nginx|/opt/bashmenu/plugins/restart_nginx.sh|Restart web server|2|
Backup Database|/opt/bashmenu/plugins/backup_db.sh|Backup database|2|

# Level 3 - Root only
Deploy Production|/opt/bashmenu/plugins/deploy.sh|Deploy to production|3|production
Update System|/opt/bashmenu/plugins/update_system.sh|Update system packages|3|
Delete Old Backups|/opt/bashmenu/plugins/cleanup.sh|Delete old backups|3|
```

### What Users See

#### Regular User (Level 1)

When a regular user runs bashmenu:

```
═══════════════════════════════════════════════
          System Administration Menu
═══════════════════════════════════════════════

  1  Git Status (Show repository status)
  2  Docker PS (Show containers)
  3  View Logs (View application logs)
🔒 4  Git Pull (Pull latest changes) - Requires Admin
🔒 5  Restart Nginx (Restart web server) - Requires Admin
🔒 6  Deploy Production (Deploy to production) - Requires Root
  7  Exit
```

If they try to execute a restricted script:

```
✗ Access denied: Git Pull requires level 2 (you have level 1)
```

#### Admin User (Level 2)

Admin users can execute Level 1 and 2 scripts:

```
═══════════════════════════════════════════════
          System Administration Menu
═══════════════════════════════════════════════

  1  Git Status (Show repository status)
  2  Docker PS (Show containers)
  3  View Logs (View application logs)
  4  Git Pull (Pull latest changes)
  5  Restart Nginx (Restart web server)
🔒 6  Deploy Production (Deploy to production) - Requires Root
  7  Exit
```

#### Root User (Level 3)

Root can execute all scripts:

```
═══════════════════════════════════════════════
          System Administration Menu
═══════════════════════════════════════════════

  1  Git Status (Show repository status)
  2  Docker PS (Show containers)
  3  View Logs (View application logs)
  4  Git Pull (Pull latest changes)
  5  Restart Nginx (Restart web server)
  6  Deploy Production (Deploy to production)
  7  Exit
```

### Practical Example: Multi-User Server

Let's set up a server with different user roles:

#### 1. Create the scripts

```bash
# View script (Level 1)
sudo nano /opt/bashmenu/plugins/view_status.sh
```

```bash
#!/bin/bash
echo "═══════════════════════════════════════════════"
echo "System Status - Read Only"
echo "═══════════════════════════════════════════════"
echo ""
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
echo "Memory: $(free -h | awk 'NR==2{print $3 "/" $2}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3 "/" $2}')"
```

```bash
# Restart script (Level 2)
sudo nano /opt/bashmenu/plugins/restart_service.sh
```

```bash
#!/bin/bash
SERVICE="${1:-nginx}"
echo "═══════════════════════════════════════════════"
echo "Restart Service - Admin Operation"
echo "═══════════════════════════════════════════════"
echo ""
echo "Restarting $SERVICE..."
sudo systemctl restart "$SERVICE"
echo "✓ Service restarted successfully"
```

```bash
# Deploy script (Level 3)
sudo nano /opt/bashmenu/plugins/deploy_production.sh
```

```bash
#!/bin/bash
echo "═══════════════════════════════════════════════"
echo "Deploy to Production - ROOT ONLY"
echo "═══════════════════════════════════════════════"
echo ""
echo "⚠️  WARNING: This will deploy to PRODUCTION"
echo ""
read -p "Are you absolutely sure? (type 'YES' to confirm): " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "Deployment cancelled"
    exit 1
fi

echo "Deploying to production..."
# Your deployment commands here
echo "✓ Deployment completed"
```

#### 2. Make scripts executable

```bash
sudo chmod +x /opt/bashmenu/plugins/view_status.sh
sudo chmod +x /opt/bashmenu/plugins/restart_service.sh
sudo chmod +x /opt/bashmenu/plugins/deploy_production.sh
```

#### 3. Configure scripts.conf

```bash
sudo nano /opt/bashmenu/config/scripts.conf
```

```bash
# Level 1 - All users
View Status|/opt/bashmenu/plugins/view_status.sh|View system status|1|

# Level 2 - Admin only
Restart Nginx|/opt/bashmenu/plugins/restart_service.sh|Restart Nginx|2|nginx
Restart MySQL|/opt/bashmenu/plugins/restart_service.sh|Restart MySQL|2|mysql

# Level 3 - Root only
Deploy Production|/opt/bashmenu/plugins/deploy_production.sh|Deploy to production|3|
```

#### 4. Enable permissions

```bash
sudo nano /opt/bashmenu/config/config.conf
```

```bash
ENABLE_PERMISSIONS=true
```

### Customizing User Detection

You can customize how users are classified by editing `src/utils.sh`:

```bash
sudo nano /opt/bashmenu/src/utils.sh
```

Find the `get_user_level()` function and modify it:

```bash
get_user_level() {
    local username=$(whoami)
    
    # Root always gets level 3
    if [[ "$username" == "root" ]]; then
        echo "3"
        return
    fi
    
    # Check if user is in specific groups
    if groups "$username" | grep -q "admin\|sudo\|wheel"; then
        echo "2"
        return
    fi
    
    # Check specific usernames
    case "$username" in
        # Admin users
        admin|sysadmin|devops|deploy)
            echo "2"
            ;;
        # Power users (optional intermediate level)
        poweruser|developer)
            echo "2"
            ;;
        # Regular users
        *)
            echo "1"
            ;;
    esac
}
```

### Advanced: Group-Based Permissions

You can also use Linux groups for permission management:

```bash
get_user_level() {
    local username=$(whoami)
    
    # Root is always level 3
    if [[ "$username" == "root" ]]; then
        echo "3"
        return
    fi
    
    # Check group membership
    local user_groups=$(groups "$username")
    
    # Level 3 - Root group
    if echo "$user_groups" | grep -q "root"; then
        echo "3"
        return
    fi
    
    # Level 2 - Admin groups
    if echo "$user_groups" | grep -qE "admin|sudo|wheel|operators"; then
        echo "2"
        return
    fi
    
    # Level 1 - Everyone else
    echo "1"
}
```

### Logging and Auditing

All permission checks are logged:

```bash
# View permission-related logs
tail -f /tmp/bashmenu.log | grep -E "Access denied|Permission"

# Example log entries:
# [2024-11-02 10:30:45] [WARN] Access denied for user john: Deploy Production
# [2024-11-02 10:31:12] [INFO] User admin executed: Restart Nginx (Status: success)
# [2024-11-02 10:32:05] [INFO] User root executed: Deploy Production (Status: success)
```

View command history:

```bash
# Check who executed what
cat ~/.bashmenu_history.log

# Example entries:
# [2024-11-02 10:30:45] [john] View Status - Status: success
# [2024-11-02 10:31:12] [admin] Restart Nginx - Status: success
# [2024-11-02 10:32:05] [root] Deploy Production - Status: success
```

### Security Best Practices

#### 1. Always Set File Permissions

Even with bashmenu permissions, set proper file permissions:

```bash
# Scripts that should only run as root
sudo chown root:root /opt/bashmenu/plugins/deploy_production.sh
sudo chmod 700 /opt/bashmenu/plugins/deploy_production.sh

# Scripts that admins can run
sudo chown root:admin /opt/bashmenu/plugins/restart_service.sh
sudo chmod 750 /opt/bashmenu/plugins/restart_service.sh

# Scripts anyone can run
sudo chmod 755 /opt/bashmenu/plugins/view_status.sh
```

#### 2. Use sudo Within Scripts

For scripts that need elevated privileges:

```bash
#!/bin/bash
# Script that requires root privileges

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root"
    echo "Please run bashmenu with sudo"
    exit 1
fi

# Your root-level commands here
systemctl restart critical-service
```

#### 3. Add Confirmation for Dangerous Operations

```bash
#!/bin/bash
# Dangerous operation script

echo "⚠️  WARNING: This will delete all old backups"
echo ""
read -p "Type 'DELETE' to confirm: " confirm

if [[ "$confirm" != "DELETE" ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Proceed with deletion
rm -rf /backup/old/*
echo "✓ Old backups deleted"
```

#### 4. Validate User Input

```bash
#!/bin/bash
# Script with parameter validation

SERVICE="${1:-}"

# Validate service name
if [[ -z "$SERVICE" ]]; then
    echo "Error: Service name required"
    exit 1
fi

# Whitelist allowed services
case "$SERVICE" in
    nginx|apache|mysql|redis)
        echo "Restarting $SERVICE..."
        sudo systemctl restart "$SERVICE"
        ;;
    *)
        echo "Error: Service '$SERVICE' not allowed"
        echo "Allowed services: nginx, apache, mysql, redis"
        exit 1
        ;;
esac
```

### Testing Permissions

```bash
# Test as different users
# 1. Test as regular user
bashmenu

# 2. Test as admin (if you have admin user)
sudo -u admin bashmenu

# 3. Test as root
sudo bashmenu

# 4. Check logs
tail -f /tmp/bashmenu.log

# 5. Try to execute restricted script as regular user
# You should see "Access denied" message
```

### Disabling Permissions

If you want to disable permissions (allow all users to execute all scripts):

```bash
sudo nano /opt/bashmenu/config/config.conf
```

```bash
# Disable permission checks
ENABLE_PERMISSIONS=false
```

This is useful for:
- Single-user systems
- Development environments
- Testing
- Personal servers

## 📚 Common Use Cases

### Use Case 1: Web Server (with Permissions)

```bash
# scripts.conf for web server with role-based access

# Level 1 - Any user can view
Check Nginx Config|/opt/bashmenu/plugins/check_nginx.sh|Verify configuration|1|
View Access Logs|/opt/bashmenu/plugins/view_logs.sh|View access logs|1|access
View Error Logs|/opt/bashmenu/plugins/view_logs.sh|View error logs|1|error
Check SSL Cert|/opt/bashmenu/plugins/check_ssl.sh|Check SSL certificate|1|

# Level 2 - Admin can restart and backup
Restart Nginx|/opt/bashmenu/plugins/restart_nginx.sh|Restart web server|2|
Reload Nginx|/opt/bashmenu/plugins/reload_nginx.sh|Reload configuration|2|
Backup Website|/opt/bashmenu/plugins/backup_web.sh|Backup website|2|
Test Config|/opt/bashmenu/plugins/test_nginx.sh|Test and reload config|2|

# Level 3 - Root only for critical operations
Update Nginx|/opt/bashmenu/plugins/update_nginx.sh|Update Nginx package|3|
Restore Backup|/opt/bashmenu/plugins/restore_web.sh|Restore from backup|3|
```

### Use Case 2: Database Server (with Permissions)

```bash
# scripts.conf for database server with role-based access

# Level 1 - Any user can monitor
Check MySQL Status|/opt/bashmenu/plugins/check_mysql.sh|Check MySQL status|1|
View Slow Queries|/opt/bashmenu/plugins/slow_queries.sh|View slow queries|1|
Show Connections|/opt/bashmenu/plugins/mysql_connections.sh|Show active connections|1|
Database Size|/opt/bashmenu/plugins/db_size.sh|Show database sizes|1|

# Level 2 - Admin can backup and optimize
Backup MySQL|/opt/bashmenu/plugins/backup_mysql.sh|Backup database|2|
Optimize Tables|/opt/bashmenu/plugins/optimize_mysql.sh|Optimize tables|2|
Restart MySQL|/opt/bashmenu/plugins/restart_mysql.sh|Restart MySQL service|2|
Kill Long Queries|/opt/bashmenu/plugins/kill_queries.sh|Kill long-running queries|2|

# Level 3 - Root only for dangerous operations
Restore Database|/opt/bashmenu/plugins/restore_mysql.sh|Restore from backup|3|
Drop Database|/opt/bashmenu/plugins/drop_db.sh|Drop database|3|
Reset Root Password|/opt/bashmenu/plugins/reset_mysql_pass.sh|Reset root password|3|
```

### Use Case 3: Application Server (with Permissions)

```bash
# scripts.conf for application server with role-based access

# Level 1 - Developers can view
View App Logs|/opt/bashmenu/plugins/app_logs.sh|View application logs|1|
Check App Health|/opt/bashmenu/plugins/health_check.sh|Check app health|1|
View Queue Status|/opt/bashmenu/plugins/queue_status.sh|View job queue status|1|
Check API Status|/opt/bashmenu/plugins/api_status.sh|Check API endpoints|1|

# Level 2 - DevOps can restart and deploy to staging
Restart App|/opt/bashmenu/plugins/restart_app.sh|Restart application|2|
Deploy Staging|/opt/bashmenu/plugins/deploy.sh|Deploy to staging|2|staging
Clear Cache|/opt/bashmenu/plugins/clear_cache.sh|Clear application cache|2|
Restart Workers|/opt/bashmenu/plugins/restart_workers.sh|Restart queue workers|2|

# Level 3 - Only root for production
Deploy Production|/opt/bashmenu/plugins/deploy.sh|Deploy to production|3|production
Run Migrations|/opt/bashmenu/plugins/migrations.sh|Run database migrations|3|
Rollback Deploy|/opt/bashmenu/plugins/rollback.sh|Rollback deployment|3|
Update Dependencies|/opt/bashmenu/plugins/update_deps.sh|Update dependencies|3|
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

### Problem: Permission denied / Access denied

```bash
# Check if permissions are enabled
grep ENABLE_PERMISSIONS /opt/bashmenu/config/config.conf

# Check your user level
whoami
groups

# Check script required level in scripts.conf
grep "My Script" /opt/bashmenu/config/scripts.conf

# View permission logs
tail -f /tmp/bashmenu.log | grep "Access denied"

# Solutions:
# 1. Run as appropriate user
sudo bashmenu  # Run as root for level 3 scripts

# 2. Change script level in scripts.conf
# Edit the 4th field to lower level (e.g., 3 → 2 or 1)

# 3. Disable permissions entirely
sudo nano /opt/bashmenu/config/config.conf
# Set: ENABLE_PERMISSIONS=false
```

### Problem: All users can execute restricted scripts

```bash
# Check if permissions are enabled
grep ENABLE_PERMISSIONS /opt/bashmenu/config/config.conf

# Should be:
ENABLE_PERMISSIONS=true

# If false, enable it:
sudo nano /opt/bashmenu/config/config.conf
# Change to: ENABLE_PERMISSIONS=true

# Restart bashmenu
bashmenu
```

## 📖 Additional Resources

- [README.md](README.md) - Main documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guide
- [LICENSE](LICENSE) - Project license

---

Have more examples or use cases? Contribute to the project!

# Bashmenu - Interactive Menu System for System Administration

[![Version](https://img.shields.io/badge/version-2.1-blue.svg)](https://github.com/jveyes/bashmenu)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0+-orange.svg)](https://www.gnu.org/software/bash/)

An interactive and modular menu system for Linux system administration. Designed to simplify administrative tasks through an intuitive and extensible menu interface.

## 🌟 Key Features

### 🎨 Visual Interface
- **Real-Time Dashboard**: System monitoring with auto-refresh
- **Quick Status Check**: Instant system health overview
- **Visual Progress Bars**: Color-coded indicators
- **Multiple Themes**: Default, Dark, Colorful, Minimal, and Modern
- **Clean Interface**: Professional and easy-to-use menu system

### 🔧 External Scripts System
- **Simple Configuration**: Add scripts via configuration file
- **Auto-loading**: Scripts automatically appear in menu
- **Security Validation**: Multi-layer validation before execution
- **Real-time Output**: View output as it runs
- **Parameter Support**: Interactive or default parameters
- **Example Scripts**: Includes Git and Docker examples

### 🛡️ Security & Permissions
- **Role-based Access Control**: 3-level permission system (User/Admin/Root)
- **Flexible Permission Management**: Enable/disable as needed
- **Input Validation**: Complete input sanitization
- **Path Validation**: Whitelist-based restrictions
- **Command Logging**: Complete audit trail with permission checks
- **Secure Execution**: Robust error handling

### 📊 Logging and Monitoring
- **Multi-level Logging**: DEBUG, INFO, WARN, ERROR
- **Command History**: Track executed commands
- **Silent Mode**: Log to file only
- **Auto-creation**: Automatic log directory creation

## 🚀 Quick Installation

### System-wide Installation (Recommended)
```bash
# Clone repository
git clone https://github.com/jveyes/bashmenu.git
cd bashmenu

# Run installer with sudo
sudo ./install.sh

# Start bashmenu
bashmenu
```

### Development Installation (Current Setup)
```bash
# For development/testing (no installation needed)
cd /home/stk/GIT/Bashmenu

# Make executable and run directly
chmod +x bashmenu
./bashmenu
```

### User Installation
```bash
# Install for current user only
./install.sh --user

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Start bashmenu
bashmenu
```

## 📖 Basic Usage

```bash
# Run with default settings
bashmenu

# Run with dark theme
bashmenu --theme dark

# Run with debug logging
bashmenu --debug

# Show help
bashmenu --help

# Show version
bashmenu --version

# Show system information
bashmenu --info
```

### ⌨️ Keyboard Shortcuts

Inside the menu:
- **`1-9`** - Direct number selection
- **`↑↓`** - Navigate with arrows
- **`Enter`** - Select option
- **`d`** - Real-time dashboard
- **`s`** - Quick status check
- **`r`** - Refresh menu
- **`q`** - Quick exit

## 📁 Project Structure

```
bashmenu/
├── bashmenu                    # Main execution script
├── install.sh                  # Installation script
├── src/                        # Source code
│   ├── main.sh                # Main entry point
│   ├── utils.sh               # Utility functions
│   ├── menu.sh                # Menu system (HIERARCHICAL)
│   ├── logger.sh              # Logging system
│   ├── commands.sh            # System commands
│   ├── script_loader.sh       # External scripts loader
│   ├── script_validator.sh    # Validation and security
│   └── script_executor.sh     # Execution engine
├── config/                     # Configuration
│   ├── config.conf            # Main configuration file
│   ├── scripts.conf           # External scripts config
│   └── scripts.conf.example   # Configuration example
├── plugins/                    # Scripts directory
│   ├── examples/              # Example scripts (auto-detected)
│   │   ├── cleanup_logs.sh    # Log cleanup utility
│   │   ├── monitor_resources.sh # Resource monitoring
│   │   └── backup_system.sh   # System backup
│   └── paqueteria/            # Production scripts (manual config)
│       ├── 01_deploy_production.sh # Production deployment
│       ├── 02_pull_only.sh    # Code updates
│       ├── 03_rollback.sh     # Rollback operations
│       ├── 04_status_logs.sh  # Monitoring & logs
│       ├── 05_health_check.sh # Health verification
│       ├── 06_restart_app.sh  # Service restart
│       ├── 07_git_push.sh     # Git operations
│       ├── 08_verify_system.sh # System diagnostics
│       └── common.sh          # Shared functions
├── OPORTUNIDAD DE MEJORAS.md   # Improvement roadmap
├── CONTRIBUTING.md            # Contribution guidelines
├── EXAMPLES.md                # Usage examples
├── LICENSE                    # MIT License
└── README.md                  # Main documentation
```

## 🔧 Configuration

### Main Configuration File (`config/config.conf`)

```bash
# Menu Settings
MENU_TITLE="SAM - System Administration Menu"
ENABLE_COLORS=true
AUTO_REFRESH=false
SHOW_TIMESTAMP=true
DEFAULT_THEME="modern"

# Logging Settings
LOG_LEVEL=1
LOG_FILE="/tmp/bashmenu.log"
DEBUG_MODE=true
ENABLE_HISTORY=true

# Security Settings
ENABLE_PERMISSIONS=false
ENABLE_PLUGINS=true
PLUGIN_DIR="$PROJECT_ROOT/plugins"
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin:/home/stk/GIT/Bashmenu/plugins"

# Plugin Auto-Scan Settings
ENABLE_AUTO_SCAN=false
ENABLE_MANUAL_SCRIPTS=true
PLUGIN_SCAN_DEPTH=3
PLUGIN_EXTENSIONS=".sh"
```

### Scripts Configuration File (`config/scripts.conf`)

```bash
# Manual script configuration (highest priority)
🚀 Deploy to Production|/home/stk/GIT/Bashmenu/plugins/paqueteria/01_deploy_production.sh|Deploy, hot reload or server setup|1|
📥 Update Code|/home/stk/GIT/Bashmenu/plugins/paqueteria/02_pull_only.sh|Pull from GitHub without rebuild|1|

# Auto-detected script name mappings (optional, for auto-scanned scripts)
SCRIPT_NAME_MAPPING["cleanup_logs.sh"]="🔍 JMV"
SCRIPT_NAME_MAPPING["monitor_resources.sh"]="📊 Monitor Resources"
SCRIPT_NAME_MAPPING["backup_system.sh"]="💾 System Backup"
```

## 📝 External Scripts System

### Quick Start

After installation, Bashmenu includes example scripts enabled by default:

```bash
bashmenu
```

You'll see Git and Docker scripts in the menu, ready to use.

### Add Your Own Scripts

#### **Option 1: Manual Configuration (Recommended for Important Scripts)**

1. **Create your script**:
```bash
sudo nano /opt/bashmenu/plugins/my_script.sh
```

```bash
#!/bin/bash
echo "Hello from my script!"
echo "Current directory: $(pwd)"
```

2. **Make it executable**:
```bash
sudo chmod +x /opt/bashmenu/plugins/my_script.sh
```

3. **Add to scripts.conf**:
```bash
sudo nano /opt/bashmenu/config/scripts.conf
```

Add this line:
```
🚀 My Script|/opt/bashmenu/plugins/my_script.sh|My custom script description|1|
```

4. **Run Bashmenu** - your script will appear in the menu!

#### **Option 2: Auto-Detection with Custom Names**

For scripts that appear automatically, you can customize their display names:

```bash
# In scripts.conf, add mappings for auto-detected scripts:
SCRIPT_NAME_MAPPING["my_script.sh"]="🚀 My Custom Script Name"
SCRIPT_NAME_MAPPING["another_script.sh"]="📊 Another Custom Name"
```

### Configuration Format

The `scripts.conf` file uses a pipe-separated format:

```
Display Name|Absolute Path|Description|Level|Parameters
```

**Examples:**
```bash
# Manual configuration (complete control)
🚀 Deploy Production|/opt/bashmenu/plugins/deploy.sh|Deploy to production server|3|production
📊 System Monitor|/opt/bashmenu/plugins/monitor.sh|Monitor system resources|1|

# Auto-detected script name mappings (optional)
SCRIPT_NAME_MAPPING["cleanup_logs.sh"]="🧹 Log Cleanup"
SCRIPT_NAME_MAPPING["backup_system.sh"]="💾 System Backup"
```

### System Architecture

Bashmenu uses a **hybrid configuration system**:

#### **Manual Configuration Scripts:**
- Full control over name, description, and permissions
- Higher priority than auto-detection
- Best for critical/production scripts

#### **Auto-Detected Scripts:**
- Automatically discovered from plugin directories
- Use filename-based names (with optional custom mappings)
- Perfect for development/testing scripts

#### **Priority Order:**
1. **Manual Configuration** (highest priority)
2. **Custom Mappings** (for auto-detected scripts)
3. **Auto-Generated Names** (fallback)

### Example Scripts Included

#### 1. Paquetería Scripts (Manual Configuration)
Production-ready scripts with custom names and descriptions:
- `🚀 Deploy to Production` - Deploy, hot reload or server setup
- `📥 Update Code` - Pull from GitHub without rebuild
- `⬆️ Push Changes` - Controlled commit and push to repository
- `↩️ Rollback Changes` - Rollback to previous commit or tag
- `📊 Status & Logs` - Monitoring, tail and log streaming
- `🔄 Restart Services` - Restart containers, systemd or Nginx
- `🏥 Health Check` - Comprehensive service verification
- `🔍 System Diagnostic` - Complete server diagnostic

#### 2. Examples Scripts (Auto-Detected with Mappings)
Development scripts with custom display names:
- `🔍 JMV` - Log cleanup utility
- `📊 Monitor Resources` - System resource monitoring
- `💾 System Backup` - Backup system files

## 🎨 Themes

### Available Themes

1. **Default**: Classic interface with cyan accents
2. **Dark**: Dark mode with purple accents
3. **Colorful**: Bright colors with double-line frames
4. **Minimal**: Clean, minimal interface
5. **Modern**: Modern look with 256-color support (current default)

### Change Theme

```bash
# From command line
bashmenu --theme dark

# Or edit config.conf
DEFAULT_THEME="dark"
```

### Current Theme Configuration
- **Default Theme**: `modern`
- **Colors**: Enabled
- **Timestamp**: Enabled in header

## 🔒 Security Features

### Role-Based Permission System

Bashmenu includes a flexible 3-level permission system to control script access:

#### Permission Levels

1. **Level 1 - User**: Basic users (read-only operations)
2. **Level 2 - Admin**: Administrators (modify operations)
3. **Level 3 - Root**: Superuser (critical operations)

#### How It Works

The system automatically detects user level based on who's running bashmenu:

```bash
# User level detection
- root user → Level 3
- admin user → Level 2
- other users → Level 1
```

Each script in `scripts.conf` has a required permission level:

```bash
# Format: Name|Path|Description|Level|Parameters
Git Status|/opt/bashmenu/plugins/git_operations.sh|Show status|1|status
Restart Nginx|/opt/bashmenu/plugins/restart_nginx.sh|Restart server|2|
Deploy Production|/opt/bashmenu/plugins/deploy.sh|Deploy to prod|3|production
```

#### Enabling Permissions

Permissions are **disabled by default**. To enable, edit `config/config.conf`:

```bash
# Enable permission-based access control
ENABLE_PERMISSIONS=true
```

#### What Users See

**Regular User (Level 1):**
- Can execute Level 1 scripts
- Sees 🔒 lock icon on Level 2 and 3 scripts
- Gets "Access denied" message if trying to execute restricted scripts

**Admin User (Level 2):**
- Can execute Level 1 and 2 scripts
- Sees 🔒 lock icon on Level 3 scripts

**Root User (Level 3):**
- Can execute all scripts (Level 1, 2, and 3)

#### Best Practices

**Level 1 Scripts** (Any user):
- View logs and status
- Check system information
- List resources
- Read-only operations

**Level 2 Scripts** (Admin only):
- Restart services
- Deploy to staging
- Backup operations
- Configuration changes

**Level 3 Scripts** (Root only):
- Deploy to production
- System updates
- Delete operations
- Critical system changes

#### Customizing User Detection

You can customize user level detection by modifying `src/utils.sh`:

```bash
get_user_level() {
    local username=$(whoami)
    
    # Root always gets level 3
    if [[ "$username" == "root" ]]; then
        echo "3"
        return
    fi
    
    # Check if user is in admin group
    if groups "$username" | grep -q "admin\|sudo\|wheel"; then
        echo "2"
        return
    fi
    
    # Specific admin users
    case "$username" in
        admin|sysadmin|devops)
            echo "2"
            ;;
        *)
            echo "1"
            ;;
    esac
}
```

#### Security Notes

- Permissions are **advisory** - they control menu access only
- Always set proper **file permissions** on scripts:
  ```bash
  sudo chown root:root /opt/bashmenu/plugins/critical_script.sh
  sudo chmod 700 /opt/bashmenu/plugins/critical_script.sh
  ```
- All permission checks are **logged** for audit trail
- Use `sudo` within scripts for actual privilege elevation

### Script Path Validation

Bashmenu validates all external scripts before execution:

- **Absolute Path Requirement**: Scripts must use absolute paths
- **Directory Whitelist**: Only scripts in allowed directories can execute
- **Path Sanitization**: Prevents directory traversal attacks
- **Symbolic Link Resolution**: Validates the real path of symlinks

Configure allowed directories in `config/config.conf`:

```bash
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin"
```

## 🐛 Troubleshooting

### Empty Menu (only Exit option)

- This means `scripts.conf` is empty or all entries are commented
- Edit `/opt/bashmenu/config/scripts.conf` and uncomment example scripts
- Or add your own scripts to the configuration

### Script Not Appearing in Menu

- Check that scripts.conf exists and is readable
- Verify script path is absolute (starts with `/`)
- Ensure script is in ALLOWED_SCRIPT_DIRS
- Check logs: `tail -f /tmp/bashmenu.log`
- Verify the script file exists: `ls -la /path/to/script.sh`

### Permission Denied

- Make script executable: `chmod +x script.sh`
- Check file ownership: `ls -l script.sh`
- Verify ALLOWED_SCRIPT_DIRS includes script location

### Script Fails to Execute

- Test script syntax: `bash -n script.sh`
- Run script directly: `./script.sh`
- Check logs and error messages
- Verify all dependencies are installed

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**JESUS MARIA VILLALOBOS**

## 📋 Recent Updates (v2.1)

### ✅ **Implemented Features**

- **Hierarchical Menu System**: Navigate scripts by directory structure
- **Hybrid Configuration**: Manual + auto-detected scripts with priority system
- **Script Name Mappings**: Custom display names for auto-detected scripts
- **Enhanced Security**: Path validation and permission controls
- **Modern UI**: Updated themes and improved user experience

### 🔧 **Technical Improvements**

- Fixed AUTO_SCRIPTS unbound variable error
- Improved script execution logic for different command types
- Enhanced logging and debugging capabilities
- Updated configuration with current settings

### 📁 **Current Project Structure**

- **Scripts Directory**: `plugins/` with `paqueteria/` and `examples/` subdirectories
- **Configuration**: Hybrid system with manual config taking precedence
- **Theme**: Modern theme with colors and timestamps enabled
- **Auto-scan**: Disabled (manual configuration preferred for production)

## 🙏 Acknowledgments

- Bash scripting community
- Open source contributors
- System administration tools inspiration

---

**Bashmenu v2.1** - Making system administration easier, one menu at a time! 🚀

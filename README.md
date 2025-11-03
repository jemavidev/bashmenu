# Bashmenu v2.0 - Enhanced System Administration Menu

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/jveyes/bashmenu)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0+-orange.svg)](https://www.gnu.org/software/bash/)

A powerful, modular, and extensible Bash script providing an interactive menu system for system administration tasks. This enhanced version includes advanced features like external scripts system, theming, logging, security controls, and comprehensive validation.

## 🆕 What's New in v2.0

- **🔌 External Scripts System** - Simple configuration-based script integration
- **🎨 Multiple Themes** - 5 built-in themes (default, dark, colorful, minimal, modern)
- **📊 Comprehensive Logging** - Multi-level logging with file output
- **🔒 Security Validation** - Path validation, syntax checking, parameter sanitization
- **⚙️ Modular Architecture** - Clean separation of concerns with dedicated modules

[See full changelog](CHANGELOG.md)

## ✨ Features

### 🎨 **Visual Features**
- **Multiple Themes**: Default, Dark, Colorful, Minimal, and Modern themes
- **Dynamic Menus**: Responsive menu with proper framing
- **Color-coded Output**: Success, error, warning, and info messages
- **Timestamp Display**: Optional timestamps for all operations
- **Clean Interface**: Professional-looking menu system

### 🔧 **System Administration**
- **External Scripts Integration**: Run any bash script from the menu
- **Example Scripts Included**: Git and Docker management scripts
- **Real-time Output**: See script execution output as it happens
- **Parameter Support**: Interactive or default parameters for scripts
- **Execution Logging**: Complete audit trail of all script executions

### 🛡️ **Security & Permissions**
- **Role-based Access**: User level permissions (1-3)
- **Input Validation**: Comprehensive sanitization and validation
- **Script Path Validation**: Whitelist-based directory restrictions
- **Command Logging**: Complete audit trail of all operations
- **Secure Execution**: Safe command execution with error handling
- **Syntax Validation**: Pre-execution validation of all scripts and plugins

### 🔌 **External Scripts System** (NEW!)
- **Simple Configuration**: Add scripts via easy-to-edit `scripts.conf` file
- **Auto-loading**: Scripts automatically appear in menu on startup
- **Security Validation**: Multi-layer validation before execution
- **Real-time Output**: See script output as it runs with color-coded stderr
- **Parameter Support**: Pass parameters to scripts interactively or via defaults
- **Example Scripts**: Git and Docker management scripts included
- **No Code Required**: Just drop your scripts and configure - no bash coding needed

### 🔌 **Plugin System** (Legacy - Deprecated)
- **Note**: The plugin system is deprecated in favor of the simpler External Scripts system
- **Modular Architecture**: Easy to extend with custom plugins
- **Auto-loading**: Automatic plugin discovery and loading
- **Syntax Validation**: Pre-load validation prevents crashes
- **Duplicate Prevention**: Automatic detection of duplicate menu items
- **Error Isolation**: Plugin failures don't affect core functionality
- **Plugin API**: Simple interface for creating new plugins

### 📊 **Logging & Monitoring**
- **Multi-level Logging**: DEBUG, INFO, WARN, ERROR levels
- **Configurable Logging**: Customizable log files and levels
- **Command History**: Track all executed commands with timestamps
- **Performance Monitoring**: Built-in benchmarking tools
- **Silent Mode**: Logs to file without cluttering terminal output
- **Automatic Log Directory Creation**: Creates log directories as needed

### ⚙️ **Configuration Management**
- **External Configuration**: Separate config file for easy customization
- **Environment Validation**: Automatic system requirement checking
- **Backup System**: Automatic configuration backups
- **Theme Management**: Easy theme switching and customization

## 🚀 Quick Start

### Installation

#### System-wide Installation (Recommended)
```bash
# Clone the repository
git clone https://github.com/jveyes/bashmenu.git
cd bashmenu

# Run installer with sudo
sudo ./install.sh

# Start using bashmenu
bashmenu
```

#### User Installation
```bash
# Install for current user only
./install.sh --user

# Add to PATH if needed
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Start using bashmenu
bashmenu
```

### Basic Usage

```bash
# Run with default settings
bashmenu

# Run with dark theme
bashmenu --theme dark

# Run with debug logging
bashmenu --debug

# Run with custom config
bashmenu --config /path/to/config.conf

# Show help
bashmenu --help

# Show version
bashmenu --version

# Show system information
bashmenu --info

# Show configuration
bashmenu --config
```

### ⌨️ Keyboard Shortcuts

Once inside the menu:
- **`1-9`** - Direct number selection
- **`↑↓`** - Navigate with arrow keys
- **`Enter`** - Select option
- **`r`** - Refresh menu
- **`q`** - Quick exit

## 📁 Project Structure

```
bashmenu/
├── bashmenu                        # Main execution script
├── install.sh                      # Installation script
├── src/                            # Source code
│   ├── main.sh                    # Main entry point with CLI
│   ├── utils.sh                   # Utility functions
│   ├── menu.sh                    # Menu system with themes
│   ├── logger.sh                  # Logging system
│   ├── script_loader.sh           # External scripts loader
│   ├── script_validator.sh        # Script validation & security
│   └── script_executor.sh         # Script execution engine
├── config/                         # Configuration
│   ├── config.conf                # Main configuration file
│   └── scripts.conf.example       # External scripts config example (NEW)
├── plugins/                        # Scripts directory
│   └── examples/                  # Example scripts (NEW)
│       ├── git_operations.sh      # Git management script
│       └── docker_manager.sh      # Docker management script
├── README.md                       # Main documentation
├── CHANGELOG.md                    # Version history
└── tests/                          # Test suite
    └── test_script_system.sh      # External scripts system tests
```

## 🔒 Security Features

### Script Path Validation

Bashmenu validates all external scripts before execution:

- **Absolute Path Requirement**: Scripts must use absolute paths
- **Directory Whitelist**: Only scripts in allowed directories can execute
- **Path Sanitization**: Prevents directory traversal attacks
- **Symbolic Link Resolution**: Validates the real path of symlinks

Configure allowed directories in `config/config.conf`:

```bash
# Allowed directories for external scripts (colon-separated)
ALLOWED_SCRIPT_DIRS="/opt/scripts:/usr/local/bin:/opt/bashmenu"
```

### Plugin Security

- **Syntax Validation**: All plugins validated before loading
- **Error Isolation**: Plugin failures don't crash the system
- **Duplicate Prevention**: Prevents duplicate menu items
- **Safe Loading**: Plugins loaded in isolated context

### Configuration Validation

- **Syntax Checking**: Config files validated before loading
- **Value Validation**: Boolean and numeric values verified
- **Fallback Defaults**: System continues with defaults if config fails
- **Detailed Logging**: All validation issues logged

## ⚙️ Configuration

### Main Configuration File (`config/config.conf`)

```bash
# Menu Settings
MENU_TITLE="System Administration Menu"
ENABLE_COLORS=true
AUTO_REFRESH=false
SHOW_TIMESTAMP=true

# Theme Settings
DEFAULT_THEME="default"
AVAILABLE_THEMES=("default" "dark" "colorful" "minimal")

# Logging Settings
LOG_LEVEL=1
LOG_FILE="/tmp/bashmenu.log"
ENABLE_HISTORY=true
HISTORY_FILE="$HOME/.bashmenu_history.log"

# Security Settings
ENABLE_PERMISSIONS=false
ADMIN_USERS=("root" "admin")

# Plugin Settings
ENABLE_PLUGINS=true
PLUGIN_DIR="plugins"

# Notification Settings
ENABLE_NOTIFICATIONS=true
NOTIFICATION_DURATION=3000

# Backup Settings
AUTO_BACKUP=true
BACKUP_RETENTION_DAYS=7
BACKUP_DIR="$HOME/.bashmenu/backups"
```

## 🎨 Themes

### Available Themes

1. **Default Theme**: Classic framed interface with cyan accents
2. **Dark Theme**: Dark mode with purple accents
3. **Colorful Theme**: Bright colors with double-line frames
4. **Minimal Theme**: Clean, minimal interface without frames

### Custom Themes

Create custom themes by adding them to the themes array in `src/menu.sh`:

```bash
themes["custom"]=(
    "frame_top=╔═══════════════════════════════════════════════╗"
    "frame_bottom=╚═══════════════════════════════════════════════╝"
    "frame_left=║"
    "frame_right=║"
    "title_color=\033[1;35m"
    "option_color=\033[0;36m"
    "selected_color=\033[1;33m"
    "error_color=\033[1;31m"
    "success_color=\033[1;32m"
    "warning_color=\033[1;33m"
)
```

## 📝 External Scripts System

### Overview

The External Scripts system is the **recommended way** to add custom functionality to Bashmenu. It's simpler than the plugin system and requires no bash coding knowledge - just drop your scripts and configure them.

**Key Differences:**
- **External Scripts**: Simple, configuration-based, no coding required (recommended)
- **Plugins**: Advanced, requires bash coding, for complex integrations (legacy)

### Quick Start

**After Installation:**

Bashmenu comes with example scripts already enabled! Just run:
```bash
bashmenu
```

You'll see Git and Docker management scripts in the menu. These are ready to use if you have Git or Docker installed.

**To Add Your Own Scripts:**

1. **Create your script**:
```bash
# Create a simple script
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
My Script|/opt/bashmenu/plugins/my_script.sh|My custom script|1|
```

4. **Run Bashmenu** - your script will appear in the menu!

**Note:** Make sure to configure at least one script in `scripts.conf`, otherwise the menu will be empty.

### Menu Behavior

Bashmenu shows only the scripts you configure:

**After Fresh Installation:**
- Shows 4 example scripts (Git Status, Git Pull, Docker PS, Docker Logs)
- Plus the Exit option
- Ready to use immediately!

**Custom Configuration:**
- Shows only your configured scripts from `scripts.conf`
- Plus the Exit option
- Complete control over your menu

**Empty Configuration:**
- If `scripts.conf` is empty, only Exit option will appear
- Configure at least one script to populate the menu

### Configuration Format

The `scripts.conf` file uses a simple pipe-separated format:

```
Display Name|Absolute Path|Description|Level|Parameters
```

**Fields:**
- **Display Name**: Text shown in menu (max 50 chars)
- **Absolute Path**: Full path to script (must be executable)
- **Description**: Brief description (max 100 chars)
- **Level**: Permission level (1=user, 2=admin, 3=root)
- **Parameters**: Optional default parameters

**Example:**
```bash
# Git operations
Git Pull|/opt/bashmenu/plugins/examples/git_operations.sh|Pull latest changes|1|pull
Git Status|/opt/bashmenu/plugins/examples/git_operations.sh|Show repo status|1|status

# Docker operations
Docker PS|/opt/bashmenu/plugins/examples/docker_manager.sh|Show containers|1|ps
Docker Build|/opt/bashmenu/plugins/examples/docker_manager.sh|Build containers|2|build

# Custom scripts
Backup DB|/opt/bashmenu/plugins/backup_db.sh|Backup database|2|
Deploy App|/opt/bashmenu/plugins/deploy.sh|Deploy to production|3|production
```

### Example Scripts Included

Bashmenu includes two example scripts that are **enabled by default** after installation:

#### 1. Git Operations (`git_operations.sh`)
Manage Git repositories with common operations:
- `status` - Show repository status ✅ *Enabled by default*
- `pull` - Pull latest changes from remote ✅ *Enabled by default*
- `log` - Show recent commits
- `branch` - Show branch information

**Default configuration in scripts.conf:**
```
Git Status|/opt/bashmenu/plugins/examples/git_operations.sh|Show repository status|1|status
Git Pull|/opt/bashmenu/plugins/examples/git_operations.sh|Pull latest changes|1|pull
```

#### 2. Docker Manager (`docker_manager.sh`)
Manage Docker containers and images:
- `ps` - Show running containers ✅ *Enabled by default*
- `logs` - Show container logs ✅ *Enabled by default*
- `build` - Build containers
- `restart` - Restart containers
- `images` - List Docker images

**Default configuration in scripts.conf:**
```
Docker PS|/opt/bashmenu/plugins/examples/docker_manager.sh|Show containers|1|ps
Docker Logs|/opt/bashmenu/plugins/examples/docker_manager.sh|Show container logs|1|logs
```

**Note:** These examples are automatically enabled after installation. You can comment them out in `/opt/bashmenu/config/scripts.conf` if you don't need them.

### Security Features

External scripts are validated before execution:

1. **Path Validation**: Scripts must be in allowed directories
2. **Permission Check**: Scripts must be executable
3. **Syntax Validation**: Bash scripts are checked for syntax errors
4. **Parameter Sanitization**: User input is sanitized to prevent injection
5. **Execution Logging**: All executions are logged with timestamps

**Configure allowed directories** in `config.conf`:
```bash
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin"
```

### Advanced Features

#### Interactive Parameters

Scripts can prompt for parameters at runtime:

```bash
# In scripts.conf - no default parameters
My Script|/opt/bashmenu/plugins/my_script.sh|Interactive script|1|

# User will be prompted for parameters when executing
```

#### Default Parameters

Provide default parameters that users can override:

```bash
# In scripts.conf - with default parameters
Deploy|/opt/bashmenu/plugins/deploy.sh|Deploy application|2|staging

# User can press Enter to use "staging" or type a different environment
```

#### Real-time Output

Scripts show output in real-time with color-coded stderr:
- Standard output (stdout) - normal color
- Error output (stderr) - red color
- Exit code and duration displayed after completion

#### Execution Timeout

Configure maximum execution time in `config.conf`:
```bash
SCRIPT_EXECUTION_TIMEOUT=300  # 5 minutes
```

### Creating Your Own Scripts

**Best Practices:**

1. **Use absolute paths** in scripts.conf
2. **Add shebang** at the top: `#!/bin/bash`
3. **Make executable**: `chmod +x script.sh`
4. **Add description** as comment on line 2
5. **Handle errors** with proper exit codes
6. **Validate inputs** before processing
7. **Provide usage** information

**Example Script Template:**
```bash
#!/bin/bash
# My Custom Script - Does something useful

# Configuration
SETTING="value"

# Functions
show_usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  start  - Start the service"
    echo "  stop   - Stop the service"
}

# Main
main() {
    local action="${1:-start}"
    
    case "$action" in
        start)
            echo "Starting service..."
            # Your code here
            ;;
        stop)
            echo "Stopping service..."
            # Your code here
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
```

### Troubleshooting

**Empty menu (only Exit option):**
- This means `scripts.conf` is empty or all entries are commented
- Edit `/opt/bashmenu/config/scripts.conf` and uncomment example scripts
- Or add your own scripts to the configuration

**Script not appearing in menu:**
- Check that scripts.conf exists and is readable
- Verify script path is absolute (starts with `/`)
- Ensure script is in ALLOWED_SCRIPT_DIRS
- Check logs: `tail -f /tmp/bashmenu.log`
- Verify the script file exists: `ls -la /path/to/script.sh`

**Permission denied:**
- Make script executable: `chmod +x script.sh`
- Check file ownership: `ls -l script.sh`
- Verify ALLOWED_SCRIPT_DIRS includes script location

**Script fails to execute:**
- Test script manually: `bash -n script.sh` (syntax check)
- Run script directly: `./script.sh` (test execution)
- Check script logs and error messages
- Verify all dependencies are installed (git, docker, etc.)

**Example scripts not working:**
- Git scripts require git to be installed: `sudo apt install git`
- Docker scripts require docker to be installed: `curl -fsSL https://get.docker.com | sh`
- Check that you're in a git repository when using git scripts

## 🔌 Plugin Development (Legacy)

### Creating a Plugin

Create a new plugin file in the `plugins/` directory:

```bash
#!/bin/bash

# Plugin Information
PLUGIN_NAME="My Plugin"
PLUGIN_VERSION="1.0"
PLUGIN_DESCRIPTION="My custom plugin"

# Plugin Functions
cmd_my_function() {
    print_header "My Custom Function"
    echo "This is my custom function!"
    echo ""
    echo -e "${CYAN}Press Enter to continue...${NC}"
    read -s
}

# Register plugin commands
add_menu_item "My Function" "cmd_my_function" "Execute my custom function" 1
```

### Plugin API

- `add_menu_item`: Add a new menu option
- `print_header`: Display a formatted header
- `print_success/error/warning/info`: Display colored messages
- `log_info/debug/warn/error`: Log messages

## 🧪 Testing

Run the test suite to verify functionality:

```bash
# Run all tests
./tests/test_bashmenu.sh

# Run specific test categories
./tests/test_bashmenu.sh --file-existence
./tests/test_bashmenu.sh --module-loading
./tests/test_bashmenu.sh --menu-functionality
```

## 📝 Logging

### Log Levels

- **DEBUG (0)**: Detailed debugging information
- **INFO (1)**: General information messages
- **WARN (2)**: Warning messages
- **ERROR (3)**: Error messages

### Log Configuration

```bash
# Set log level
LOG_LEVEL=1

# Set log file
LOG_FILE="/var/log/bashmenu.log"

# Enable command history
ENABLE_HISTORY=true
HISTORY_FILE="$HOME/.bashmenu_history.log"
```

## 🔧 Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   chmod +x bashmenu
   chmod +x src/*.sh
   ```

2. **Configuration Not Found**
   ```bash
   # Check if config file exists
   ls -la config/config.conf
   
   # Bashmenu will use defaults if config is missing
   # Check logs for details: tail -f /tmp/bashmenu.log
   ```

3. **Plugin Not Loading**
   ```bash
   # Check plugin directory
   ls -la plugins/
   
   # Check plugin permissions
   chmod +x plugins/*.sh
   
   # Check logs for syntax errors
   tail -f /tmp/bashmenu.log
   ```

4. **Script Validation Failed**
   ```bash
   # Error: "Script path not in allowed directories"
   # Solution: Add script directory to ALLOWED_SCRIPT_DIRS in config.conf
   
   # Example:
   ALLOWED_SCRIPT_DIRS="/opt/scripts:/usr/local/bin:/your/script/path"
   ```

5. **Configuration Syntax Errors**
   ```bash
   # Bashmenu validates config before loading
   # Check logs for specific syntax errors
   tail -f /tmp/bashmenu.log
   
   # Test config syntax manually
   bash -n config/config.conf
   ```

6. **Theme Not Loading**
   ```bash
   # Bashmenu automatically falls back to default theme
   # Check logs for theme loading issues
   tail -f /tmp/bashmenu.log
   ```

### Debug Mode

Enable debug logging for troubleshooting:

```bash
# Set debug level in config.conf
LOG_LEVEL=0

# Enable debug output to terminal
DEBUG_MODE=true

# Run bashmenu and check logs
bashmenu
tail -f /tmp/bashmenu.log
```

### Validation Errors

If you encounter validation errors:

1. **Plugin Syntax Errors**: Bashmenu validates plugins before loading
   - Check the specific plugin file for syntax errors
   - Run: `bash -n plugins/your_plugin.sh`

2. **Script Path Validation**: External scripts must be in allowed directories
   - Update `ALLOWED_SCRIPT_DIRS` in config.conf
   - Use absolute paths for all scripts

3. **Function Verification Failed**: Required functions are missing
   - Reinstall Bashmenu: `sudo ./install.sh`
   - Check that all source files are present

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**JESUS VILLALOBOS** - Enhanced with AI assistance

## 🙏 Acknowledgments

- Bash scripting community
- Open source contributors
- System administration tools inspiration

---

**Bashmenu v2.0** - Making system administration easier, one menu at a time! 🚀

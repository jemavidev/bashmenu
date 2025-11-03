# Bashmenu v2.1 - Enhanced System Administration Menu

[![Version](https://img.shields.io/badge/version-2.1-blue.svg)](https://github.com/jveyes/bashmenu)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0+-orange.svg)](https://www.gnu.org/software/bash/)

A powerful, modular, and extensible Bash script providing an interactive menu system for system administration tasks. This enhanced version includes advanced features like real-time dashboard, visual progress bars, theming, logging, plugins, security controls, and much more.

## 🆕 What's New in v2.1

- **📊 Real-Time Dashboard** - Press `d` for live system monitoring
- **⚡ Quick Status** - Press `s` for instant health check
- **🎨 Visual Progress Bars** - Color-coded resource indicators
- **⌨️ Enhanced Shortcuts** - Faster navigation with new hotkeys
- **🎯 Better UX** - Improved visual feedback throughout

[See full changelog](CHANGELOG.md) | [UX Improvements Guide](UX_IMPROVEMENTS.md)

## ✨ Features

### 🎨 **Visual Enhancements** (NEW in v2.1!)
- **Real-Time Dashboard**: Live system monitoring with auto-refresh (Press `d`)
- **Quick Status Check**: Instant system health overview (Press `s`)
- **Visual Progress Bars**: Color-coded resource usage indicators
- **Multiple Themes**: Default, Dark, Colorful, Minimal, and Modern themes
- **Dynamic Menus**: Responsive menu with proper framing
- **Color-coded Output**: Success, error, warning, and info messages
- **Enhanced Feedback**: Better visual indicators throughout
- **Timestamp Display**: Optional timestamps for all operations

### 🔧 **System Administration**
- **System Information**: Detailed system and hardware information
- **Resource Monitoring**: Real-time CPU, memory, and disk monitoring
- **Process Management**: Process analysis and management tools
- **Network Tools**: Network status and analysis
- **Package Management**: Support for apt, yum, and dnf
- **System Maintenance**: Automated maintenance tasks

### 🛡️ **Security & Permissions**
- **Role-based Access**: User level permissions (1-3)
- **Input Validation**: Comprehensive sanitization and validation
- **Script Path Validation**: Whitelist-based directory restrictions
- **Command Logging**: Complete audit trail of all operations
- **Secure Execution**: Safe command execution with error handling
- **Syntax Validation**: Pre-execution validation of all scripts and plugins

### 🔌 **Plugin System**
- **Modular Architecture**: Easy to extend with custom plugins
- **Auto-loading**: Automatic plugin discovery and loading
- **Syntax Validation**: Pre-load validation prevents crashes
- **Duplicate Prevention**: Automatic detection of duplicate menu items
- **Error Isolation**: Plugin failures don't affect core functionality
- **Plugin API**: Simple interface for creating new plugins
- **Example Plugins**: System tools plugin included

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

### ⌨️ Keyboard Shortcuts (NEW!)

Once inside the menu:
- **`d`** - Quick dashboard access (real-time monitoring)
- **`s`** - Quick status check (instant health overview)
- **`h`** - Show help
- **`r`** - Refresh menu
- **`q`** - Quick exit
- **`1-9`** - Direct number selection
- **`↑↓`** - Navigate with arrow keys
- **`Enter`** - Select option

### 📊 Quick Start Examples

```bash
# Check system health instantly
bashmenu
# Then press 's' for quick status

# Monitor system in real-time
bashmenu
# Then press 'd' for dashboard

# Navigate fast with numbers
bashmenu
# Then press '1', '2', '3', etc.
```

## 📁 Project Structure

```
bashmenu/
├── bashmenu                        # Main execution script
├── install.sh                      # Installation script
├── src/                            # Source code
│   ├── main.sh                    # Main entry point with CLI
│   ├── utils.sh                   # Utility functions
│   ├── commands.sh                # Command implementations
│   ├── menu.sh                    # Menu system with themes
│   └── logger.sh                  # Logging system
├── config/                         # Configuration
│   └── config.conf                # Main configuration file
├── plugins/                        # Plugin directory
│   └── system_tools.sh            # System tools plugin
├── README.md                       # Main documentation
├── CHANGELOG.md                    # Version history
├── MEJORAS_IMPLEMENTADAS.md       # Improvements documentation (Spanish)
├── ANTI_FLICKERING_GUIDE.md       # Anti-flickering guide
└── PERMISSIONS_GUIDE.md            # Permissions system guide
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

## 🔌 Plugin Development

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

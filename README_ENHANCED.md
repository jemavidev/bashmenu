# Bashmenu v2.0 - Enhanced System Administration Menu

[![Version](https://img.shields.io/badge/version-2.0-blue.svg)](https://github.com/jveyes/bashmenu)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-4.0+-orange.svg)](https://www.gnu.org/software/bash/)

A powerful, modular, and extensible Bash script providing an interactive menu system for system administration tasks. This enhanced version includes advanced features like theming, logging, plugins, security controls, and much more.

## ✨ Features

### 🎨 **Visual Enhancements**
- **Multiple Themes**: Default, Dark, Colorful, and Minimal themes
- **Dynamic Menus**: Responsive menu with proper framing
- **Color-coded Output**: Success, error, warning, and info messages
- **Progress Bars**: Visual feedback for long-running operations
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
- **Input Validation**: Sanitization and validation of user input
- **Command Logging**: Complete audit trail of all operations
- **Secure Execution**: Safe command execution with error handling

### 🔌 **Plugin System**
- **Modular Architecture**: Easy to extend with custom plugins
- **Auto-loading**: Automatic plugin discovery and loading
- **Plugin API**: Simple interface for creating new plugins
- **Example Plugins**: System tools plugin included

### 📊 **Logging & Monitoring**
- **Multi-level Logging**: DEBUG, INFO, WARN, ERROR levels
- **Configurable Logging**: Customizable log files and levels
- **Command History**: Track all executed commands
- **Performance Monitoring**: Built-in benchmarking tools

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
```

## 📁 Project Structure

```
bashmenu/
├── src/                    # Source code
│   ├── main.sh            # Main entry point
│   ├── utils.sh           # Utility functions
│   ├── commands.sh        # Command implementations
│   └── menu.sh            # Menu system
├── config/                 # Configuration
│   └── config.conf        # Main configuration file
├── plugins/               # Plugin directory
│   └── system_tools.sh    # Example plugin
├── tests/                 # Test suite
│   └── test_bashmenu.sh   # Comprehensive tests
├── docs/                  # Documentation
├── install.sh             # Installation script
├── README_ENHANCED.md     # This file
└── README.md              # Original README
```

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
LOG_LEVEL="INFO"
LOG_FILE="/var/log/bashmenu.log"
ENABLE_HISTORY=true
HISTORY_FILE="$HOME/.bashmenu_history.log"

# Security Settings
ENABLE_PERMISSIONS=false
ADMIN_USERS=("root" "admin")

# Commands Configuration
COMMANDS=(
    "System Information|uname -a|Show detailed system information|1"
    "Disk Usage|df -h|Show disk space usage|1"
    "Memory Usage|free -h|Show memory usage|1"
    "Running Processes|ps aux --sort=-%cpu|Show running processes|1"
    "Network Status|netstat -tuln|Show network connections|2"
    "System Load|uptime|Show system load|1"
    "User Management|who|Show logged users|1"
    "Package Updates|apt list --upgradable 2>/dev/null|Show available updates|2"
)

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

1. Create a new file in the `plugins/` directory
2. Follow the plugin template:

```bash
#!/bin/bash

# Plugin Information
PLUGIN_NAME="My Plugin"
PLUGIN_VERSION="1.0"
PLUGIN_DESCRIPTION="Description of my plugin"

# Source utilities if needed
if [[ -z "$RED" ]]; then
    source "$(dirname "$0")/../src/utils.sh"
fi

# Plugin Functions
cmd_my_function() {
    print_header "My Function"
    echo "This is my custom function"
    print_success "Function completed"
}

# Register plugin commands
register_plugin_commands() {
    add_menu_item "My Function" "cmd_my_function" "Description of my function" 1
}

# Auto-register when plugin is loaded
register_plugin_commands
```

### Plugin API

- `add_menu_item(name, command, description, level)`: Add menu item
- `print_header(title)`: Display formatted header
- `print_success(message)`: Display success message
- `print_error(message)`: Display error message
- `print_warning(message)`: Display warning message
- `print_info(message)`: Display info message
- `log_info(message)`: Log info message
- `log_error(message)`: Log error message

## 🧪 Testing

### Running Tests

```bash
# Run all tests
./tests/test_bashmenu.sh

# Run specific test categories
./tests/test_bashmenu.sh --file-tests
./tests/test_bashmenu.sh --function-tests
./tests/test_bashmenu.sh --integration-tests
./tests/test_bashmenu.sh --performance-tests
```

### Test Coverage

- **File Tests**: Existence and permissions
- **Function Tests**: Utility and command functions
- **Integration Tests**: Module interaction
- **Performance Tests**: Loading and execution speed
- **Plugin Tests**: Plugin loading and execution

## 🔧 Advanced Usage

### Command Line Options

```bash
bashmenu [OPTIONS]

Options:
    -h, --help          Show help message
    -v, --version       Show version information
    -c, --config FILE   Use custom configuration file
    -t, --theme THEME   Use custom theme
    -d, --debug         Enable debug logging
    -q, --quiet         Disable notifications
    -n, --no-colors     Disable colors
```

### Environment Variables

```bash
# Override configuration
export BASHMENU_CONFIG="/path/to/config.conf"
export BASHMENU_THEME="dark"
export BASHMENU_LOG_LEVEL="DEBUG"

# Run bashmenu
bashmenu
```

### Keyboard Shortcuts

- `Ctrl+C`: Exit immediately
- `q`: Quick exit
- `h`: Show help
- `r`: Refresh menu
- Arrow keys: Navigate menu
- Numbers: Select menu item

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Make script executable
   chmod +x src/main.sh
   ```

2. **Configuration Not Found**
   ```bash
   # Check config file path
   ls -la config/config.conf
   ```

3. **Plugin Not Loading**
   ```bash
   # Check plugin permissions
   chmod 644 plugins/*.sh
   ```

4. **Logging Issues**
   ```bash
   # Check log directory permissions
   sudo mkdir -p /var/log/bashmenu
   sudo chown $USER:$USER /var/log/bashmenu
   ```

### Debug Mode

```bash
# Run with debug logging
bashmenu --debug

# Check log file
tail -f /tmp/bashmenu.log
```

## 📈 Performance

### Benchmarking

The system includes built-in performance monitoring:

```bash
# Run system benchmark
# Available in System Tools plugin
```

### Optimization Tips

1. **Disable unnecessary features** in configuration
2. **Use minimal theme** for faster rendering
3. **Reduce log level** for better performance
4. **Limit plugin loading** to essential plugins

## 🤝 Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Run the test suite
6. Submit a pull request

### Code Style

- Use consistent indentation (4 spaces)
- Add comments for complex logic
- Follow Bash best practices
- Include error handling
- Add logging for important operations

### Testing Guidelines

- Write tests for new functions
- Ensure backward compatibility
- Test on multiple systems
- Validate configuration changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original concept by Jesus Villalobos
- Enhanced with AI assistance
- Community contributions welcome
- Inspired by various system administration tools

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/jveyes/bashmenu/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jveyes/bashmenu/discussions)
- **Documentation**: [Wiki](https://github.com/jveyes/bashmenu/wiki)

---

**Made with ❤️ for the Linux community** 
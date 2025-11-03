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
│   ├── menu.sh                # Menu system
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
│   └── examples/              # Example scripts
│       ├── git_operations.sh  # Git management
│       └── docker_manager.sh  # Docker management
└── README.md                   # Main documentation
```

## 🔧 Configuration

### Main Configuration File (`config/config.conf`)

```bash
# Menu Settings
MENU_TITLE="System Administration Menu"
ENABLE_COLORS=true
DEFAULT_THEME="modern"

# Logging Settings
LOG_LEVEL=1
LOG_FILE="/tmp/bashmenu.log"
DEBUG_MODE=false

# Security Settings
ENABLE_PERMISSIONS=false
ALLOWED_SCRIPT_DIRS="/opt/bashmenu/plugins:/opt/scripts:/usr/local/bin"
```

## 📝 External Scripts System

### Quick Start

After installation, Bashmenu includes example scripts enabled by default:

```bash
bashmenu
```

You'll see Git and Docker scripts in the menu, ready to use.

### Add Your Own Scripts

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
My Script|/opt/bashmenu/plugins/my_script.sh|My custom script|1|
```

4. **Run Bashmenu** - your script will appear in the menu!

### Configuration Format

The `scripts.conf` file uses a pipe-separated format:

```
Display Name|Absolute Path|Description|Level|Parameters
```

**Example:**
```bash
# Git operations
Git Pull|/opt/bashmenu/plugins/examples/git_operations.sh|Pull latest changes|1|pull
Git Status|/opt/bashmenu/plugins/examples/git_operations.sh|Show repo status|1|status

# Docker operations
Docker PS|/opt/bashmenu/plugins/examples/docker_manager.sh|Show containers|1|ps
Docker Logs|/opt/bashmenu/plugins/examples/docker_manager.sh|Show container logs|1|logs

# Custom scripts
Backup DB|/opt/bashmenu/plugins/backup_db.sh|Backup database|2|
Deploy App|/opt/bashmenu/plugins/deploy.sh|Deploy to production|3|production
```

### Example Scripts Included

#### 1. Git Operations (`git_operations.sh`)
Manage Git repositories with common operations:
- `status` - Show repository status ✅ *Enabled by default*
- `pull` - Pull latest changes ✅ *Enabled by default*
- `log` - Show recent commits
- `branch` - Show branch information

#### 2. Docker Manager (`docker_manager.sh`)
Manage Docker containers and images:
- `ps` - Show running containers ✅ *Enabled by default*
- `logs` - Show container logs ✅ *Enabled by default*
- `build` - Build containers
- `restart` - Restart containers
- `images` - List Docker images

## 🎨 Themes

### Available Themes

1. **Default**: Classic interface with cyan accents
2. **Dark**: Dark mode with purple accents
3. **Colorful**: Bright colors with double-line frames
4. **Minimal**: Clean, minimal interface
5. **Modern**: Modern look with 256-color support

### Change Theme

```bash
# From command line
bashmenu --theme dark

# Or edit config.conf
DEFAULT_THEME="dark"
```

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

## 🙏 Acknowledgments

- Bash scripting community
- Open source contributors
- System administration tools inspiration

---

**Bashmenu v2.1** - Making system administration easier, one menu at a time! 🚀

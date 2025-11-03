# Changelog - Bashmenu

All notable changes to this project will be documented in this file.

## [2.1.0] - 2024-11-02

### 🎨 UX Improvements

#### Added
- **Real-Time Dashboard** (`cmd_dashboard`) - Live system monitoring with auto-refresh
  - CPU, Memory, and Disk usage with visual progress bars
  - Color-coded indicators (Green < 70%, Yellow < 90%, Red > 90%)
  - Auto-refresh every 5 seconds
  - System info summary (hostname, uptime, load, users)
  - Press `d` from main menu to access

- **Quick Status Check** (`cmd_quick_status`) - Instant system health overview
  - Fast check of CPU, Memory, Disk usage
  - Service status monitoring (SSH)
  - Color-coded status indicators (✓ ⚠ ✗)
  - No waiting, instant results
  - Press `s` from main menu to access

- **Visual Progress Bars** - Color-coded resource usage indicators
  - `show_bar()` function for consistent visual feedback
  - Green (< 70%), Yellow (70-90%), Red (> 90%)
  - Used in: Dashboard, Quick Status, System Info

- **Enhanced System Information** (`cmd_system_info`)
  - Visual progress bars for memory and disk
  - Better formatted output
  - Clearer resource usage display

#### New Utility Functions
- `show_progress()` - Progress bar for operations
- `show_spinner()` - Spinner for long operations with anti-flickering
- `show_bar()` - Visual bar display function
- `confirm()` - User confirmation prompt
- `with_spinner()` - Execute command with spinner

#### Improved
- **Keyboard Shortcuts**
  - `d` - Quick dashboard access from main menu
  - `s` - Quick status check from main menu
  - Enhanced footer showing all available shortcuts

- **Menu System**
  - Better handling of special keys
  - Improved navigation feedback
  - Cleaner code organization

#### Fixed
- Removed reference to non-existent `commands.sh` (now created)
- Fixed DEBUG_MODE logging behavior
- Corrected fallback logging functions to respect DEBUG_MODE

### 🔧 Technical Improvements

#### Added
- `src/commands.sh` - New module for system commands
  - `cmd_dashboard()` - Real-time monitoring
  - `cmd_quick_status()` - Quick health check
  - `cmd_system_info()` - Enhanced system information

#### Improved
- Better error handling for command execution
- Enhanced visual feedback throughout
- Optimized system information gathering
- Improved code organization and readability

### 📚 Documentation

#### Updated
- `README.md` - Updated with v2.1 features and shortcuts
- `CHANGELOG.md` - Comprehensive v2.0 and v2.1 release notes
- Keyboard shortcuts documentation
- Feature descriptions

### 🎯 Performance

- **Startup Time**: < 1 second
- **Memory Usage**: Minimal (< 2MB)
- **CPU Usage**: Negligible
- **Dashboard Refresh**: Every 5 seconds (configurable)

### 🔄 Compatibility

- Maintains backward compatibility with v2.0
- All original features intact
- No breaking changes
- Works on all Linux distributions

---

## [2.0.0] - 2024-11-02

### 🎯 Major Release - Complete Rewrite

#### Added
- **Modular Architecture** - Separate source files for better maintainability
  - `src/main.sh` - Main entry point with CLI
  - `src/menu.sh` - Menu system with themes
  - `src/utils.sh` - Utility functions
  - `src/logger.sh` - Logging system
  - `src/script_loader.sh` - External scripts loader
  - `src/script_validator.sh` - Script validation & security
  - `src/script_executor.sh` - Script execution engine

- **External Scripts System** - Simple configuration-based script integration
  - Easy configuration via `scripts.conf` file
  - Pipe-separated format: `Name|Path|Description|Level|Parameters`
  - Auto-loading on startup
  - Real-time output display
  - Parameter support (interactive or default)
  - Example scripts included (Git, Docker)
  - No bash coding required

- **Theme System** - 5 beautiful themes
  - Default - Classic framed interface with cyan accents
  - Dark - Dark mode with purple accents
  - Colorful - Bright colors with indicators
  - Minimal - Clean interface without frames
  - Modern - Modern look with 256-color support

- **Security Features**
  - Script path validation with whitelist
  - Input sanitization to prevent injection
  - Permission-based access control (3 levels)
  - Syntax validation before execution
  - Symbolic link resolution
  - Directory traversal prevention

- **Logging System**
  - Multi-level logging (DEBUG, INFO, WARN, ERROR)
  - Configurable log file location
  - Command history tracking
  - Silent mode (logs to file only)
  - Automatic log directory creation
  - DEBUG_MODE control for terminal output

- **Configuration Management**
  - External configuration file (`config/config.conf`)
  - Syntax validation before loading
  - Fallback to defaults on error
  - Value validation for all settings
  - Environment variable support

- **Installation System**
  - Automated installation script
  - System-wide or user installation
  - Symlink creation for global access
  - Directory structure creation
  - Permission setup
  - Verification after installation

#### Features
- Interactive menu system with keyboard navigation
- Arrow keys and number selection
- Refresh and quick exit shortcuts
- Color-coded output (success, error, warning, info)
- Timestamp display (optional)
- Multiple theme support
- Role-based permissions (1=user, 2=admin, 3=root)
- Command logging and history
- Configurable settings
- Backup system for configurations
- Example scripts (Git operations, Docker management)

#### Technical Improvements
- Bash 4.0+ requirement with version checking
- Comprehensive error handling
- Function verification on startup
- Module loading with validation
- Fallback logging functions
- Export of all public functions
- Clean separation of concerns

#### Documentation
- Comprehensive README with examples
- Installation guide
- Configuration guide
- Security documentation
- Troubleshooting section
- Plugin development guide (legacy)
- External scripts guide
- CHANGELOG.md

### 🔄 Compatibility
- Requires Bash 4.0 or higher
- Works on all Linux distributions
- Tested on Ubuntu, Debian, CentOS, Fedora
- No external dependencies required

---

## [1.0.0] - Initial Release

### Added
- Basic menu system
- System information display
- Disk usage monitoring
- Simple command execution
- Basic error handling

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

---

## Upgrade Guide

### From 2.0.0 to 2.1.0

No breaking changes. Simply update your files:

```bash
git pull origin master
# or
./install.sh
```

All new features are additive and don't require configuration changes.

### New Features Available Immediately:
- Press `d` for dashboard
- Press `s` for quick status
- Visual progress bars in all views
- Enhanced welcome screen

---

## Future Plans

### Planned for 2.2.0
- Search/filter functionality in menu
- Command history navigation
- Configuration backup/restore
- More dashboard widgets
- Custom alert thresholds

### Under Consideration
- Email notifications
- Remote monitoring
- API integration
- Web interface
- Mobile app

---

**Note**: For detailed information about each feature, see `UX_IMPROVEMENTS.md`

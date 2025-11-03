# Design Document

## Overview

Este documento describe el diseño técnico para endurecer y simplificar Bashmenu. El enfoque es mantener la arquitectura modular existente mientras se fortalece el manejo de errores, se valida la seguridad, y se elimina complejidad innecesaria. El diseño prioriza la robustez sobre nuevas características.

### Design Principles

1. **Fail-Safe**: El sistema debe continuar operando incluso cuando componentes individuales fallen
2. **Validation First**: Validar todas las entradas antes de procesarlas
3. **Simplicity**: Eliminar código no utilizado y consolidar funcionalidad duplicada
4. **Clear Feedback**: Proporcionar mensajes claros sobre el estado del sistema
5. **Backward Compatible**: Mantener compatibilidad con configuraciones existentes

## Architecture

### Current Architecture (Preserved)

```
bashmenu (entry point)
    ↓
src/main.sh (initialization & CLI)
    ↓
    ├── src/logger.sh (logging system)
    ├── src/utils.sh (utility functions)
    ├── src/commands.sh (command implementations)
    └── src/menu.sh (menu system & themes)
        ↓
        └── plugins/*.sh (optional extensions)
```

### Enhanced Error Handling Flow

```
Component Load Attempt
    ↓
Syntax Validation (bash -n)
    ↓
    ├── Valid → Source Component
    │            ↓
    │         Function Verification
    │            ↓
    │         Success → Continue
    │
    └── Invalid → Log Error
                   ↓
                Load Fallback/Skip
                   ↓
                Display Warning
                   ↓
                Continue Operation
```

## Components and Interfaces

### 1. Enhanced Configuration Loader

**Location**: `src/main.sh:initialize_system()`

**Purpose**: Load configuration with validation and fallback

**Interface**:
```bash
initialize_system()
  ├── validate_config_syntax()
  ├── source_config_safe()
  ├── set_default_config()
  └── verify_config_values()
```

**Implementation Details**:
- Use `bash -n` to validate syntax before sourcing
- Catch sourcing errors with `2>/dev/null` and check exit code
- Fall back to `set_default_config()` on any error
- Log all configuration loading events
- Display user-friendly warnings for configuration issues

**Error Handling**:
- Syntax errors → Use defaults + warning
- Missing file → Use defaults + info message
- Invalid values → Use defaults for invalid fields only

### 2. Safe Plugin Loader

**Location**: `src/commands.sh:load_plugins()`

**Purpose**: Load plugins with validation and isolation

**Interface**:
```bash
load_plugins()
  ├── discover_plugins()
  ├── validate_plugin_syntax()
  ├── source_plugin_safe()
  └── register_plugin_commands()
```

**Implementation Details**:
- Scan plugin directory for *.sh files
- Validate each plugin with `bash -n` before sourcing
- Source in subshell first to test for runtime errors
- Skip plugins that fail validation
- Log each plugin load attempt with result
- Prevent duplicate menu items from plugins

**Error Handling**:
- Syntax error → Skip plugin + log + warning
- Runtime error → Skip plugin + log + warning
- Missing functions → Skip plugin + log
- Duplicate commands → Use first loaded, skip duplicates

### 3. External Script Validator

**Location**: `src/menu.sh:validate_script_path()`

**Purpose**: Validate external scripts before execution

**Interface**:
```bash
validate_script_path(script_path)
  ├── check_absolute_path()
  ├── check_file_exists()
  ├── check_executable()
  ├── check_allowed_directory()
  └── sanitize_path()
```

**Implementation Details**:
- Verify path starts with `/` (absolute)
- Check file exists with `-f`
- Check executable with `-x`
- Compare against ALLOWED_SCRIPT_DIRS if configured
- Sanitize path to prevent traversal (remove `..`, `./`, etc.)
- Return 0 for valid, 1 for invalid

**Security Considerations**:
- No symbolic link following without validation
- Path canonicalization before directory check
- Whitelist approach for allowed directories
- Log all validation failures for audit

### 4. Enhanced Execution Wrapper

**Location**: `src/menu.sh:execute_menu_item()`

**Purpose**: Execute commands with error handling and logging

**Interface**:
```bash
execute_menu_item(index)
  ├── check_permissions()
  ├── validate_command()
  ├── execute_with_capture()
  └── handle_execution_result()
```

**Implementation Details**:
- Check user level against required level
- Validate external scripts before execution
- Capture exit code of all executions
- Log command start and completion with status
- Display success/error messages based on exit code
- Provide clear error messages with exit codes

**Execution Flow**:
```
1. Verify index is valid
2. Check user permissions
3. If external script:
   a. Validate script path
   b. Execute and capture exit code
   c. Display result based on exit code
4. If internal function:
   a. Verify function exists
   b. Execute function
   c. Log completion
5. Log all execution attempts
```

### 5. Simplified Menu Structure

**Purpose**: Consolidate menu items and remove duplicates

**Core Menu Items** (Maximum 10):
1. System Information (consolidated view)
2. Disk Usage
3. Dashboard (real-time monitoring)
4. Quick Status
5. System Health (combines health check + benchmark)
6. Process Analysis
7. Network Analysis
8. Security Check
9. Help
10. Exit

**Removed/Consolidated**:
- Memory Usage → Integrated into System Information
- Separate benchmark → Integrated into System Health
- Duplicate plugin commands → Prevented by registration logic

**Implementation**:
```bash
initialize_menu()
  ├── clear_menu_arrays()
  ├── add_core_commands()
  ├── load_external_scripts()
  └── load_plugins_if_no_external()
```

### 6. Progress Indicator System

**Location**: `src/utils.sh`

**Purpose**: Provide visual feedback for long operations

**Interface**:
```bash
show_spinner(pid, message)
show_progress(current, total)
with_spinner(command, message)
```

**Implementation Details**:

**Spinner**:
- Unicode spinner characters: ⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏
- Rotate every 0.1 seconds
- Monitor process with `ps -p $pid`
- Clear spinner on completion

**Progress Bar**:
- Width: 40 characters
- Characters: █ for filled, ░ for empty
- Show percentage
- Update in place with `\r`

**Usage Example**:
```bash
# For background process
apt update > /dev/null 2>&1 &
show_spinner $! "Updating package list"

# For iterative operations
for i in {1..100}; do
    # do work
    show_progress $i 100
done
```

### 7. Enhanced Logging System

**Location**: `src/logger.sh`

**Purpose**: Consistent, reliable logging across all components

**Interface**:
```bash
log_debug(message)
log_info(message)
log_warn(message)
log_error(message)
log_command(command, status)
write_log(level, message)
```

**Implementation Details**:
- Check log level before writing
- Create log directory if missing (with error handling)
- Format: `[YYYY-MM-DD HH:MM:SS] [LEVEL] message`
- Write to file with `>> "$log_file" 2>/dev/null`
- Continue operation if logging fails (don't crash)
- Separate command history file for audit trail

**Log Levels**:
- DEBUG (0): Detailed debugging information
- INFO (1): General information messages
- WARN (2): Warning messages
- ERROR (3): Error messages

**File Handling**:
- Default log file: `/tmp/bashmenu.log`
- Default history file: `$HOME/.bashmenu_history.log`
- Create parent directories with `mkdir -p`
- Fail silently if cannot write (don't block operation)

### 8. Configurable Timeout System

**Location**: `src/menu.sh:read_input()`

**Purpose**: Flexible session timeout management

**Configuration**:
```bash
# In config.conf
INPUT_TIMEOUT=30              # seconds
SESSION_TIMEOUT_ENABLED=true  # true/false
```

**Implementation**:
```bash
read_input()
  ├── get_timeout_value()
  ├── check_timeout_enabled()
  ├── read_with_timeout()
  └── handle_timeout()
```

**Behavior**:
- If `SESSION_TIMEOUT_ENABLED=false`: Wait indefinitely
- If `SESSION_TIMEOUT_ENABLED=true`: Use `INPUT_TIMEOUT` value
- On timeout: Display message and refresh menu
- Default timeout: 30 seconds if not configured

### 9. Code Cleanup Strategy

**Purpose**: Remove unused code and consolidate duplicates

**Files to Clean**:

**src/menu.sh**:
- Remove `search_menu()` and `display_filtered_menu()` (not integrated)
- Remove `navigate_history()` functions (not used)
- Consolidate theme initialization (remove unused theme variables)

**src/commands.sh**:
- Remove standalone `cmd_memory_usage()` (integrate into system info)
- Consolidate health check and benchmark into single command
- Remove duplicate system information gathering

**src/utils.sh**:
- Remove `backup_config()` and `restore_config()` (not implemented)
- Keep only used progress indicator functions

**config/config.conf**:
- Remove unused configuration options
- Add comments for all options
- Provide sensible defaults

## Data Models

### Configuration Structure

```bash
# Menu Settings
MENU_TITLE="string"           # Menu title
ENABLE_COLORS=boolean         # Enable color output
AUTO_REFRESH=boolean          # Auto-refresh after commands
SHOW_TIMESTAMP=boolean        # Show timestamp in header

# Theme Settings
DEFAULT_THEME="string"        # default|dark|colorful|minimal|modern

# Logging Settings
LOG_LEVEL=integer            # 0=DEBUG, 1=INFO, 2=WARN, 3=ERROR
LOG_FILE="path"              # Log file path
ENABLE_HISTORY=boolean       # Enable command history
HISTORY_FILE="path"          # History file path

# Security Settings
ENABLE_PERMISSIONS=boolean   # Enable permission system
ADMIN_USERS=("array")       # List of admin users
ALLOWED_SCRIPT_DIRS=("array") # Allowed script directories

# Session Settings
INPUT_TIMEOUT=integer        # Timeout in seconds
SESSION_TIMEOUT_ENABLED=boolean # Enable/disable timeout

# Plugin Settings
ENABLE_PLUGINS=boolean       # Enable plugin system
PLUGIN_DIR="path"           # Plugin directory path

# External Scripts
EXTERNAL_SCRIPTS="multiline" # Format: Name|Path|Description|Level
```

### Menu Item Structure

```bash
# Arrays (parallel)
menu_options=()      # Display names
menu_commands=()     # Command names or paths
menu_descriptions=() # Descriptions
menu_levels=()       # Required permission levels
```

### Log Entry Structure

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] message
[2024-01-15 14:30:45] [INFO] Configuration loaded from /opt/bashmenu/config/config.conf
[2024-01-15 14:30:45] [WARN] Plugin has syntax errors: broken_plugin.sh
[2024-01-15 14:30:50] [INFO] User john executed: cmd_system_info (Status: success)
```

## Error Handling

### Error Categories and Responses

| Category | Example | Response | User Impact |
|----------|---------|----------|-------------|
| Configuration Error | Syntax error in config.conf | Use defaults + warning | Minimal - continues with defaults |
| Plugin Error | Plugin fails to load | Skip plugin + warning | Minimal - other plugins work |
| Script Validation Error | Script not in allowed dir | Refuse execution + error | Expected - security feature |
| Script Execution Error | Script exits with code 1 | Display error + log | Expected - script issue |
| Missing File | Required source file missing | Error message + exit | Critical - cannot continue |
| Theme Load Error | Theme not found | Fall back to default | Minimal - uses default theme |
| Logging Error | Cannot write to log file | Continue + warning | Minimal - operation continues |

### Error Message Format

**Success**:
```
✅ Operation completed successfully
```

**Warning**:
```
⚠️  Warning: Configuration file has syntax errors
    Using default configuration
```

**Error**:
```
❌ Error: Script validation failed: /tmp/malicious.sh
    Reason: Script path not in allowed directories
```

**Critical Error**:
```
❌ Critical Error: Required file not found: src/menu.sh
    Installation may be corrupted. Please reinstall.
```

### Error Recovery Strategies

1. **Configuration Errors**: Fall back to hardcoded defaults
2. **Plugin Errors**: Skip problematic plugin, continue with others
3. **Script Errors**: Display error, return to menu
4. **Theme Errors**: Use default theme
5. **Logging Errors**: Continue without logging
6. **Critical Errors**: Display message and exit gracefully

## Testing Strategy

### Unit Testing Approach

**Test Files Structure**:
```
tests/
├── test_validation.sh      # Test validation functions
├── test_error_handling.sh  # Test error scenarios
├── test_logging.sh         # Test logging system
└── test_integration.sh     # Test full workflows
```

### Test Categories

**1. Validation Tests**:
- Valid configuration file → Loads successfully
- Invalid configuration file → Uses defaults
- Valid plugin → Loads successfully
- Invalid plugin → Skips with warning
- Valid script path → Passes validation
- Invalid script path → Fails validation

**2. Error Handling Tests**:
- Missing configuration → Uses defaults
- Corrupted plugin → Skips plugin
- Script execution failure → Captures exit code
- Missing required file → Exits gracefully

**3. Integration Tests**:
- Full startup sequence → Completes successfully
- Menu navigation → Works correctly
- Command execution → Executes and logs
- Error recovery → System continues after errors

### Manual Testing Checklist

- [ ] Install on fresh system
- [ ] Run with valid configuration
- [ ] Run with invalid configuration
- [ ] Load valid plugins
- [ ] Load invalid plugins
- [ ] Execute valid external scripts
- [ ] Execute invalid external scripts
- [ ] Test permission system
- [ ] Test timeout functionality
- [ ] Test all menu commands
- [ ] Test error messages
- [ ] Verify logging output
- [ ] Test theme switching
- [ ] Test dashboard refresh
- [ ] Test graceful exit

## Implementation Notes

### Priority Order

**Phase 1: Critical Robustness** (Requirements 1, 5)
- Configuration validation
- Plugin validation
- Error handling for script execution
- Syntax validation for all sourced files

**Phase 2: Security Validation** (Requirement 3)
- External script path validation
- Allowed directory checking
- Path sanitization

**Phase 3: Simplification** (Requirements 4, 8, 10)
- Remove unused functions
- Consolidate menu items
- Clean up configuration

**Phase 4: User Experience** (Requirements 2, 6, 7)
- Progress indicators
- Enhanced logging
- Configurable timeout

### Backward Compatibility

- Existing configuration files will continue to work
- New validation is additive (doesn't break existing setups)
- Default values provided for all new options
- Plugins that work now will continue to work
- External scripts require no changes (only validation added)

### Performance Considerations

- Validation adds minimal overhead (< 100ms on startup)
- Syntax checking is fast (`bash -n` is quick)
- Logging is asynchronous (doesn't block operations)
- Progress indicators use minimal CPU
- No performance degradation for normal operations

### Security Considerations

- Script path validation prevents execution of unauthorized scripts
- Path sanitization prevents directory traversal attacks
- Logging provides audit trail for security review
- Permission system enforces access control
- No execution of scripts from user-writable directories by default

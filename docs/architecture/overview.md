# Bashmenu v3.0 - Architecture Documentation

## 📐 System Architecture

### Overview

Bashmenu v3.0 uses a **modular, layered architecture** that separates concerns and promotes maintainability, testability, and extensibility.

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                     │
│                    (menu_display.sh)                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────────────┐
│                   Orchestration Layer                        │
│         (menu_refactored.sh, menu_loop.sh)                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────────────┐
│                    Business Logic Layer                      │
│  (menu_core.sh, menu_navigation.sh, menu_execution.sh)     │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────────────┐
│                   Infrastructure Layer                       │
│  (menu_input.sh, menu_validation.sh, menu_themes.sh)       │
└─────────────────────────────────────────────────────────────┘
```

## 🏗️ Module Hierarchy

### Layer 1: Infrastructure (Foundation)

These modules provide core functionality used by all other layers.

#### menu_themes.sh
- **Purpose**: Theme system and color management
- **Dependencies**: None
- **Exports**: Theme variables, load_theme()
- **Used by**: menu_display.sh

#### menu_input.sh
- **Purpose**: User input handling and keyboard navigation
- **Dependencies**: None
- **Exports**: read_input(), handle_keyboard_input()
- **Used by**: menu_loop.sh

#### menu_validation.sh
- **Purpose**: Security validation and path sanitization
- **Dependencies**: None
- **Exports**: validate_script_path(), sanitize_script_path()
- **Used by**: menu_execution.sh

### Layer 2: Business Logic

These modules implement core business functionality.

#### menu_core.sh
- **Purpose**: Menu data structures and initialization
- **Dependencies**: None
- **Exports**: initialize_menu(), add_menu_item()
- **Used by**: menu_loop.sh, menu_execution.sh

#### menu_navigation.sh
- **Purpose**: Hierarchical navigation system
- **Dependencies**: menu_core.sh
- **Exports**: build_hierarchical_menu(), handle_navigation()
- **Used by**: menu_loop.sh

#### menu_execution.sh
- **Purpose**: Script execution and menu item handling
- **Dependencies**: menu_core.sh, menu_validation.sh
- **Exports**: execute_menu_item(), execute_auto_script()
- **Used by**: menu_loop.sh

#### menu_help.sh
- **Purpose**: Help system and documentation
- **Dependencies**: menu_display.sh
- **Exports**: show_help_screen(), show_quick_help()
- **Used by**: menu_loop.sh

### Layer 3: Orchestration

These modules coordinate between layers.

#### menu_display.sh
- **Purpose**: Display and rendering functions
- **Dependencies**: menu_themes.sh, menu_core.sh
- **Exports**: display_header(), display_menu(), display_footer()
- **Used by**: menu_loop.sh

#### menu_loop.sh
- **Purpose**: Main menu loop orchestration
- **Dependencies**: All other modules
- **Exports**: menu_loop(), menu_loop_classic(), menu_loop_hierarchical()
- **Used by**: menu_refactored.sh

### Layer 4: Entry Point

#### menu_refactored.sh
- **Purpose**: Main orchestrator - loads all modules
- **Dependencies**: All modules
- **Exports**: All functions (re-exports)
- **Used by**: main.sh

## 🔄 Data Flow

### Menu Initialization Flow

```
main.sh
  └─> menu_refactored.sh
       ├─> Load all modules
       ├─> initialize_themes()
       └─> initialize_menu()
            ├─> load_manual_scripts()
            ├─> load_script_mappings()
            ├─> register_external_scripts()
            └─> auto_scan_plugins()
                 └─> build_hierarchical_menu()
```

### User Interaction Flow

```
User Input
  └─> read_input() [menu_input.sh]
       └─> menu_loop() [menu_loop.sh]
            ├─> display_header() [menu_display.sh]
            ├─> display_menu() [menu_display.sh]
            ├─> display_footer() [menu_display.sh]
            └─> handle_*_menu_input()
                 ├─> handle_keyboard_input() [menu_input.sh]
                 ├─> handle_navigation() [menu_navigation.sh]
                 └─> execute_menu_item() [menu_execution.sh]
                      ├─> check_execution_permission()
                      ├─> validate_script_path() [menu_validation.sh]
                      └─> execute_command()
```

### Script Execution Flow

```
execute_menu_item()
  └─> check_execution_permission()
       └─> execute_command()
            ├─> exit_menu() [if exit command]
            ├─> execute_external_script()
            │    ├─> validate_script_path()
            │    │    ├─> sanitize_script_path()
            │    │    ├─> validate_absolute_path()
            │    │    ├─> validate_path_exists()
            │    │    ├─> validate_file_executable()
            │    │    └─> validate_allowed_directory()
            │    └─> Run script
            └─> execute_function_command()
```

## 📦 Module Dependencies Graph

```
menu_refactored.sh
├── menu_core.sh
├── menu_themes.sh
├── menu_display.sh
│   ├── menu_themes.sh
│   └── menu_core.sh
├── menu_input.sh
├── menu_navigation.sh
│   └── menu_core.sh
├── menu_execution.sh
│   ├── menu_core.sh
│   └── menu_validation.sh
├── menu_loop.sh
│   ├── menu_display.sh
│   ├── menu_input.sh
│   ├── menu_navigation.sh
│   └── menu_execution.sh
├── menu_validation.sh
└── menu_help.sh
    └── menu_display.sh
```

## 🔐 Security Architecture

### Defense in Depth

```
User Input
  └─> Layer 1: Input Sanitization [menu_input.sh]
       └─> Layer 2: Path Validation [menu_validation.sh]
            ├─> sanitize_script_path()
            ├─> validate_absolute_path()
            ├─> validate_path_exists()
            ├─> validate_regular_file()
            ├─> validate_file_executable()
            └─> validate_allowed_directory()
                 └─> Layer 3: Permission Check [menu_execution.sh]
                      └─> Layer 4: Execution [menu_execution.sh]
```

### Security Layers

1. **Input Layer**: Reject malformed input
2. **Validation Layer**: Comprehensive path checks
3. **Permission Layer**: RBAC enforcement
4. **Execution Layer**: Controlled script execution
5. **Audit Layer**: Complete logging

## 🎨 Theme System Architecture

### Theme Structure

```
Theme Definition (menu_themes.sh)
├── Frame Elements
│   ├── frame_top
│   ├── frame_bottom
│   ├── frame_left
│   └── frame_right
└── Color Palette
    ├── title_color
    ├── option_color
    ├── selected_color
    ├── error_color
    ├── success_color
    ├── warning_color
    └── info_color
```

### Theme Loading Process

```
initialize_themes()
  ├─> Define default theme
  ├─> Define dark theme
  ├─> Define colorful theme
  ├─> Define minimal theme
  └─> Define modern theme

load_theme(name)
  ├─> Validate theme exists
  ├─> Load theme variables
  ├─> Apply to display system
  └─> Fallback to default if error
```

## 📊 State Management

### Global State

```bash
# Menu State (menu_core.sh)
declare -ga menu_options=()
declare -ga menu_commands=()
declare -ga menu_descriptions=()
declare -ga menu_levels=()

# Script Registry (menu_core.sh)
declare -gA SCRIPT_ENTRIES=()
declare -gA SCRIPT_NAME_MAPPING=()
declare -gA SCRIPT_LEVEL_MAPPING=()
declare -gA AUTO_SCRIPTS=()

# Navigation State (menu_navigation.sh)
declare -gA menu_hierarchy=()
declare -ga current_path=()

# Theme State (menu_themes.sh)
declare -g frame_top frame_bottom frame_left frame_right
declare -g title_color option_color selected_color
declare -g error_color success_color warning_color info_color
```

### State Transitions

```
INIT → LOADING → READY → RUNNING → EXIT
  │       │         │        │        │
  │       │         │        │        └─> Cleanup
  │       │         │        └─> User Interaction Loop
  │       │         └─> Menu Display
  │       └─> Load Scripts & Themes
  └─> Initialize Data Structures
```

## 🧪 Testing Architecture

### Test Pyramid

```
                    ┌─────────────┐
                    │   E2E Tests │  (Few)
                    └──────┬──────┘
                ┌──────────┴──────────┐
                │ Integration Tests   │  (Some)
                └──────────┬──────────┘
        ┌───────────────────┴───────────────────┐
        │         Unit Tests                    │  (Many)
        └───────────────────────────────────────┘
```

### Test Coverage by Module

| Module | Unit Tests | Integration Tests | Coverage Target |
|--------|-----------|-------------------|-----------------|
| menu_core.sh | ✅ | ✅ | >80% |
| menu_themes.sh | ✅ | ✅ | >80% |
| menu_display.sh | ✅ | ✅ | >70% |
| menu_input.sh | ✅ | ✅ | >90% |
| menu_navigation.sh | ✅ | ✅ | >70% |
| menu_execution.sh | ✅ | ✅ | >80% |
| menu_loop.sh | ✅ | ✅ | >70% |
| menu_validation.sh | ✅ | ✅ | >95% |
| menu_help.sh | ✅ | ⚠️ | >60% |

## 🚀 Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Modules loaded on-demand
2. **Caching**: Menu structure cached between refreshes
3. **Efficient Loops**: Minimal iterations in display
4. **Function Inlining**: Critical paths optimized
5. **Array Operations**: Batch operations where possible

### Performance Metrics

| Operation | Target | Current |
|-----------|--------|---------|
| Cold Start | <3s | TBD |
| Hot Start | <1s | TBD |
| Menu Refresh | <100ms | TBD |
| Script Execution | <500ms | TBD |
| Search (100 items) | <200ms | TBD |

## 🔌 Extension Points

### Adding New Modules

```bash
# 1. Create new module
src/menu_custom.sh

# 2. Define functions
my_custom_function() {
    # Implementation
}

# 3. Export functions
export -f my_custom_function

# 4. Load in menu_refactored.sh
source "$MENU_SCRIPT_DIR/menu_custom.sh"
```

### Adding New Themes

```bash
# In menu_themes.sh
export mytheme_frame_top="=========="
export mytheme_title_color="\033[1;35m"
# ... other theme variables

# Load theme
load_theme "mytheme"
```

### Adding New Commands

```bash
# In menu_loop.sh
case $choice in
    "x"|"X")
        my_custom_command
        ;;
esac
```

## 📝 Coding Standards

### Function Naming

- **Verbs first**: `load_theme()`, `validate_path()`
- **Descriptive**: `build_hierarchical_menu()`
- **Consistent**: `show_*`, `display_*`, `handle_*`

### Module Naming

- **Prefix**: All menu modules start with `menu_`
- **Descriptive**: `menu_validation.sh`, `menu_execution.sh`
- **Singular**: `menu_theme.sh` not `menu_themes.sh` (exception for clarity)

### Code Organization

```bash
# 1. Shebang and strict mode
#!/bin/bash
set -euo pipefail

# 2. Header comment
# =============================================================================
# Module Name
# =============================================================================

# 3. Constants and globals
declare -g CONSTANT_NAME

# 4. Functions (grouped by purpose)
function_name() {
    # Implementation
}

# 5. Exports
export -f function_name
```

## 🔄 Backward Compatibility

### Compatibility Layer

```
Old Code (v2.1)
  └─> menu.sh (symlink)
       └─> menu_refactored.sh
            ├─> Load new modules
            └─> Provide compatibility functions
```

### Migration Path

1. **Phase 1**: Both systems coexist
2. **Phase 2**: Gradual migration
3. **Phase 3**: Deprecate old system
4. **Phase 4**: Remove legacy code

## 📚 Further Reading

- [Refactoring Summary](REFACTORING_SUMMARY.md)
- [Migration Guide](MIGRATION_NOTES.md)
- [Testing Guide](tests/README.md)
- [Contributing Guide](CONTRIBUTING.md)

---

**Version**: 3.0.0-alpha  
**Last Updated**: 2026-01-26  
**Maintainer**: JESUS MARIA VILLALOBOS

#!/bin/bash

# Strict mode for better error handling
set -euo pipefail

# =============================================================================
# Bashmenu - Sistema de Menú Interactivo para Administración
# =============================================================================
# Descripción: Punto de entrada principal del sistema Bashmenu
# Versión:     2.2
# Autor:       JESUS MARIA VILLALOBOS
# =============================================================================

# =============================================================================
# Shell Compatibility Check
# =============================================================================

# Ensure we're running with bash
if [[ -z "$BASH_VERSION" ]]; then
    echo "Error: This script must be run with bash, not $0" >&2
    echo "Please run: bash $0" >&2
    exit 1
fi

# Check for associative array support (bash >= 4.0)
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo "Error: This script requires bash version 4.0 or higher" >&2
    echo "Current version: $BASH_VERSION" >&2
    exit 1
fi

# =============================================================================
# Script Information
# =============================================================================

readonly SCRIPT_NAME="Bashmenu"
readonly SCRIPT_VERSION="2.2"
readonly SCRIPT_AUTHOR="JESUS MARIA VILLALOBOS"

# =============================================================================
# Global Variables
# =============================================================================

# Script directory and project root
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Export for use in other modules
export SCRIPT_DIR
export PROJECT_ROOT

# Detect installation type
if [[ "$PROJECT_ROOT" == "/opt/bashmenu" ]]; then
    readonly INSTALL_TYPE="system"
elif [[ "$PROJECT_ROOT" == "$HOME/.local/bashmenu" ]] || [[ "$PROJECT_ROOT" == "$HOME/bashmenu" ]]; then
    readonly INSTALL_TYPE="user"
else
    readonly INSTALL_TYPE="development"
fi

export INSTALL_TYPE

# Configuration file
readonly CONFIG_FILE="$PROJECT_ROOT/config/config.conf"

# =============================================================================
# Color Definitions (fallback)
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# =============================================================================
# Utility Functions (fallback)
# =============================================================================

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    local title="$1"
    local width=50
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${CYAN}"
    printf "%${width}s\n" | tr ' ' '='
    printf "%${padding}s%s%${padding}s\n" "" "$title" ""
    printf "%${width}s\n" | tr ' ' '='
    echo -e "${NC}"
}

# =============================================================================
# Validation Functions
# =============================================================================

# validate_installation() -> int
# Validates that the installation is properly configured
# Returns: 0 on success, 1 on failure
validate_installation() {
    local errors=0
    
    # Check critical directories exist
    if [[ ! -d "$SCRIPT_DIR" ]]; then
        print_error "Script directory not found: $SCRIPT_DIR"
        errors=$((errors + 1))
    fi
    
    if [[ ! -d "$PROJECT_ROOT" ]]; then
        print_error "Project root not found: $PROJECT_ROOT"
        errors=$((errors + 1))
    fi
    
    # Check if running from expected location
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        print_info "Running from system installation: /opt/bashmenu"
    elif [[ "$INSTALL_TYPE" == "user" ]]; then
        print_info "Running from user installation: $PROJECT_ROOT"
    else
        print_info "Running from development location: $PROJECT_ROOT"
    fi
    
    # Validate configuration is loaded
    if [[ "${BASHMENU_CONFIG_LOADED:-false}" != "true" ]]; then
        print_warning "Configuration not loaded yet"
    fi
    
    if [[ $errors -gt 0 ]]; then
        print_error "Installation validation failed ($errors errors)"
        return 1
    fi
    
    return 0
}

# check_requirements() -> int
# Checks if all required system components are available
# Returns: 0 on success, 1 on failure
check_requirements() {
    print_info "Checking system requirements..."
    
    local errors=0
    
    # Check required commands
    local required_commands=("bash" "clear" "date" "hostname" "uname")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_error "Required command not found: $cmd"
            errors=$((errors + 1))
        fi
    done
    
    # Check if source files exist
    local required_files=("core/utils.sh" "menu_refactored.sh")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            print_error "Required file not found: $file"
            errors=$((errors + 1))
        fi
    done
    
    if [[ $errors -gt 0 ]]; then
        print_error "Requirements check failed ($errors errors)"
        return 1
    fi
    
    print_success "Requirements check passed"
    return 0
}

# =============================================================================
# Function Verification
# =============================================================================

verify_required_functions() {
    print_info "Verifying required functions..."
    
    local missing_functions=()
    
    # Critical functions from utils.sh
    local required_functions=(
        "print_success"
        "print_error"
        "print_warning"
        "print_info"
        "print_header"
        "show_bar"
    )
    

    
    # Critical functions from menu.sh
    required_functions+=(
        "initialize_menu"
        "add_menu_item"
        "load_theme"
        "menu_loop"
        "execute_menu_item"
    )
    
    # Check each required function
    for func in "${required_functions[@]}"; do
        if ! declare -f "$func" >/dev/null 2>&1; then
            missing_functions+=("$func")
        fi
    done
    
    # Report results
    if [[ ${#missing_functions[@]} -gt 0 ]]; then
        print_error "Missing ${#missing_functions[@]} required function(s):"
        for func in "${missing_functions[@]}"; do
            echo "  - $func"
        done
        
        if declare -f log_error >/dev/null; then
            log_error "Function verification failed: ${missing_functions[*]}"
        fi
        
        return 1
    fi
    
    print_success "All required functions verified"
    if declare -f log_info >/dev/null; then
        log_info "Function verification passed: ${#required_functions[@]} functions checked"
    fi
    
    return 0
}

# =============================================================================
# Initialization Functions
# =============================================================================

initialize_system() {
    print_info "Initializing Bashmenu v$SCRIPT_VERSION..."
    
    # Validate installation first
    if ! validate_installation; then
        print_error "Installation validation failed"
        return 1
    fi
    
    # Load configuration with validation and logging
    load_configuration
    
    # Load modules
    load_modules
    
    # Verify required functions are loaded
    if ! verify_required_functions; then
        print_error "Required functions verification failed"
        return 1
    fi
    
    # Initialize menu
    if declare -f initialize_menu >/dev/null; then
        initialize_menu
        print_success "Menu initialized"
        # Log after logger is loaded
        if declare -f log_info >/dev/null; then
            log_info "Menu system initialized successfully"
        fi
    else
        print_error "Menu initialization failed"
        if declare -f log_error >/dev/null; then
            log_error "Menu initialization failed - initialize_menu function not found"
        fi
        return 1
    fi
    
    # Load theme
    if declare -f load_theme >/dev/null; then
        local theme="${BASHMENU_THEME:-${DEFAULT_THEME:-modern}}"
        load_theme "$theme"
        print_success "Theme loaded: $theme"
        if declare -f log_info >/dev/null; then
            log_info "Theme loaded: $theme"
        fi
    else
        print_error "Theme loading failed"
        if declare -f log_error >/dev/null; then
            log_error "Theme loading failed - load_theme function not found"
        fi
        return 1
    fi
    
    print_success "System initialization completed"
    if declare -f log_info >/dev/null; then
        log_info "Bashmenu v$SCRIPT_VERSION initialization completed successfully"
        log_info "Installation type: $INSTALL_TYPE"
        log_info "Project root: $PROJECT_ROOT"
    fi
    return 0
}

# =============================================================================
# Configuration Loading with Enhanced Validation
# =============================================================================

load_configuration() {
    local config_loaded=false
    
    if [[ -f "$CONFIG_FILE" ]]; then
        print_info "Found configuration file: $CONFIG_FILE"
        
        # Validate config file syntax before sourcing
        if bash -n "$CONFIG_FILE" 2>/dev/null; then
            # Attempt to source the configuration
            if source "$CONFIG_FILE" 2>/dev/null; then
                print_success "Configuration loaded from $CONFIG_FILE"
                config_loaded=true
                
                # Validate critical configuration values
                validate_config_values
            else
                print_error "Configuration file failed to load (runtime error)"
                print_warning "Using default configuration"
            fi
        else
            print_error "Configuration file has syntax errors"
            print_warning "Using default configuration"
        fi
    else
        print_warning "Configuration file not found: $CONFIG_FILE"
        print_info "Using default configuration"
    fi
    
    # Load defaults if configuration wasn't loaded successfully
    if [[ "$config_loaded" == "false" ]]; then
        set_default_config
    fi
    
    return 0
}

# =============================================================================
# Configuration Value Validation
# =============================================================================

validate_config_values() {
    local warnings=0
    
    # Validate boolean values
    if [[ -n "$ENABLE_COLORS" ]] && [[ "$ENABLE_COLORS" != "true" ]] && [[ "$ENABLE_COLORS" != "false" ]]; then
        print_warning "Invalid ENABLE_COLORS value: $ENABLE_COLORS (using default: true)"
        ENABLE_COLORS=true
        warnings=$((warnings + 1))
    fi
    
    if [[ -n "$AUTO_REFRESH" ]] && [[ "$AUTO_REFRESH" != "true" ]] && [[ "$AUTO_REFRESH" != "false" ]]; then
        print_warning "Invalid AUTO_REFRESH value: $AUTO_REFRESH (using default: false)"
        AUTO_REFRESH=false
        warnings=$((warnings + 1))
    fi
    
    if [[ -n "$SHOW_TIMESTAMP" ]] && [[ "$SHOW_TIMESTAMP" != "true" ]] && [[ "$SHOW_TIMESTAMP" != "false" ]]; then
        print_warning "Invalid SHOW_TIMESTAMP value: $SHOW_TIMESTAMP (using default: true)"
        SHOW_TIMESTAMP=true
        warnings=$((warnings + 1))
    fi
    
    if [[ -n "$ENABLE_PERMISSIONS" ]] && [[ "$ENABLE_PERMISSIONS" != "true" ]] && [[ "$ENABLE_PERMISSIONS" != "false" ]]; then
        print_warning "Invalid ENABLE_PERMISSIONS value: $ENABLE_PERMISSIONS (using default: false)"
        ENABLE_PERMISSIONS=false
        warnings=$((warnings + 1))
    fi
    
    if [[ -n "$ENABLE_PLUGINS" ]] && [[ "$ENABLE_PLUGINS" != "true" ]] && [[ "$ENABLE_PLUGINS" != "false" ]]; then
        print_warning "Invalid ENABLE_PLUGINS value: $ENABLE_PLUGINS (using default: true)"
        ENABLE_PLUGINS=true
        warnings=$((warnings + 1))
    fi
    
    if [[ -n "$ENABLE_HISTORY" ]] && [[ "$ENABLE_HISTORY" != "true" ]] && [[ "$ENABLE_HISTORY" != "false" ]]; then
        print_warning "Invalid ENABLE_HISTORY value: $ENABLE_HISTORY (using default: true)"
        ENABLE_HISTORY=true
        warnings=$((warnings + 1))
    fi
    
    # Validate numeric values
    if [[ -n "$LOG_LEVEL" ]] && ! [[ "$LOG_LEVEL" =~ ^[0-3]$ ]]; then
        print_warning "Invalid LOG_LEVEL value: $LOG_LEVEL (using default: 1)"
        LOG_LEVEL=1
        warnings=$((warnings + 1))
    fi
    
    # Validate paths exist if specified
    if [[ -n "$PLUGIN_DIR" ]] && [[ ! -d "$PLUGIN_DIR" ]]; then
        print_warning "Plugin directory not found: $PLUGIN_DIR"
        warnings=$((warnings + 1))
    fi
    
    # Validate theme
    local valid_themes=("default" "dark" "colorful" "minimal" "modern")
    if [[ -n "$DEFAULT_THEME" ]]; then
        local theme_valid=false
        for theme in "${valid_themes[@]}"; do
            if [[ "$DEFAULT_THEME" == "$theme" ]]; then
                theme_valid=true
                break
            fi
        done
        if [[ "$theme_valid" == "false" ]]; then
            print_warning "Invalid DEFAULT_THEME value: $DEFAULT_THEME (using default: default)"
            DEFAULT_THEME="default"
            warnings=$((warnings + 1))
        fi
    fi
    
    if [[ $warnings -gt 0 ]]; then
        print_warning "Configuration validation found $warnings issue(s)"
    fi
    
    # Force DEBUG_MODE based on LOG_LEVEL
    # If LOG_LEVEL is 3 (ERROR only), disable debug mode
    if [[ "${LOG_LEVEL:-1}" -eq 3 ]]; then
        DEBUG_MODE=false
        export DEBUG_MODE
    fi
    
    # Ensure DEBUG_MODE has a default value
    if [[ -z "${DEBUG_MODE}" ]]; then
        DEBUG_MODE=false
        export DEBUG_MODE
    fi
    
    return 0
}

load_modules() {
    print_info "Loading system modules..."
    
    # Load config module first (critical)
    if [[ -f "$SCRIPT_DIR/core/config.sh" ]]; then
        if bash -n "$SCRIPT_DIR/core/config.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/core/config.sh" 2>/dev/null; then
                print_success "Config module loaded"
                
                # Load configuration from .env files
                load_configuration
                
                if declare -f log_info >/dev/null; then
                    log_info "Config module loaded successfully"
                fi
            else
                print_warning "Config module failed to load (runtime error)"
                print_warning "Using fallback configuration"
            fi
        else
            print_warning "Config module has syntax errors"
            print_warning "Using fallback configuration"
        fi
    else
        print_warning "Config module not found: $SCRIPT_DIR/core/config.sh"
        print_warning "Using fallback configuration"
    fi
    
    # Load logger second (with validation)
    if [[ -f "$SCRIPT_DIR/core/logger.sh" ]]; then
        if bash -n "$SCRIPT_DIR/core/logger.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/core/logger.sh" 2>/dev/null; then
                print_success "Logger module loaded"
                log_info "Logger module loaded successfully"
            else
                print_warning "Logger module failed to load (runtime error)"
                print_warning "Using fallback logging"
            fi
        else
            print_warning "Logger module has syntax errors"
            print_warning "Using fallback logging"
        fi
    else
        print_warning "Logger module not found: $SCRIPT_DIR/core/logger.sh"
        print_warning "Using fallback logging"
    fi
    
    # Load script loader module
    if [[ -f "$SCRIPT_DIR/scripts/loader.sh" ]]; then
        if bash -n "$SCRIPT_DIR/scripts/loader.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/scripts/loader.sh" 2>/dev/null; then
                print_success "Script loader module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Script loader module loaded successfully"
                fi
            else
                print_warning "Script loader module failed to load (runtime error)"
            fi
        else
            print_warning "Script loader module has syntax errors"
        fi
    fi
    
    # Load script validator module
    if [[ -f "$SCRIPT_DIR/scripts/validator.sh" ]]; then
        if bash -n "$SCRIPT_DIR/scripts/validator.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/scripts/validator.sh" 2>/dev/null; then
                print_success "Script validator module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Script validator module loaded successfully"
                fi
            else
                print_warning "Script validator module failed to load (runtime error)"
            fi
        else
            print_warning "Script validator module has syntax errors"
        fi
    fi
    
    # Load script executor module
    if [[ -f "$SCRIPT_DIR/scripts/executor.sh" ]]; then
        if bash -n "$SCRIPT_DIR/scripts/executor.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/scripts/executor.sh" 2>/dev/null; then
                print_success "Script executor module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Script executor module loaded successfully"
                fi
            else
                print_warning "Script executor module failed to load (runtime error)"
            fi
        else
            print_warning "Script executor module has syntax errors"
        fi
    fi
    
    # Load utilities (critical module)
    if [[ -f "$SCRIPT_DIR/core/utils.sh" ]]; then
        if bash -n "$SCRIPT_DIR/core/utils.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/core/utils.sh" 2>/dev/null; then
                print_success "Utils module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Utils module loaded successfully"
                fi
            else
                print_error "Utils module failed to load (runtime error)"
                if declare -f log_error >/dev/null; then
                    log_error "Utils module failed to load - runtime error"
                fi
                return 1
            fi
        else
            print_error "Utils module has syntax errors"
            if declare -f log_error >/dev/null; then
                log_error "Utils module has syntax errors: $SCRIPT_DIR/core/utils.sh"
            fi
            return 1
        fi
    else
        print_error "Utils module not found: $SCRIPT_DIR/core/utils.sh"
        if declare -f log_error >/dev/null; then
            log_error "Utils module not found: $SCRIPT_DIR/core/utils.sh"
        fi
        return 1
    fi
    

    # Load menu system (critical module)
    if [[ -f "$SCRIPT_DIR/menu_refactored.sh" ]]; then
        if bash -n "$SCRIPT_DIR/menu_refactored.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/menu_refactored.sh" 2>/dev/null; then
                print_success "Menu module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Menu module loaded successfully"
                fi
                
                # Verify that themes were loaded correctly
                if [[ -z "$default_frame_top" ]]; then
                    print_error "Themes not loaded correctly"
                    if declare -f log_error >/dev/null; then
                        log_error "Themes not loaded correctly - default_frame_top is empty"
                    fi
                    return 1
                fi
            else
                print_error "Menu module failed to load (runtime error)"
                if declare -f log_error >/dev/null; then
                    log_error "Menu module failed to load - runtime error"
                fi
                return 1
            fi
        else
            print_error "Menu module has syntax errors"
            if declare -f log_error >/dev/null; then
                log_error "Menu module has syntax errors: $SCRIPT_DIR/menu_refactored.sh"
            fi
            return 1
        fi
    else
        print_error "Menu module not found: $SCRIPT_DIR/menu_refactored.sh"
        if declare -f log_error >/dev/null; then
            log_error "Menu module not found: $SCRIPT_DIR/menu_refactored.sh"
        fi
        return 1
    fi
    
    # Load enhanced UI modules (optional, non-critical)
    
    # Load professional themes system
    if [[ -f "$SCRIPT_DIR/ui/professional_themes.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/professional_themes.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/professional_themes.sh" 2>/dev/null; then
                print_success "Professional themes module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Professional themes loaded successfully"
                fi
            else
                print_warning "Professional themes module failed to load (runtime error)"
            fi
        else
            print_warning "Professional themes module has syntax errors"
        fi
    fi
    
    # Load enhanced menu display system
    if [[ -f "$SCRIPT_DIR/ui/enhanced_display.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/enhanced_display.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/enhanced_display.sh" 2>/dev/null; then
                print_success "Enhanced menu display module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Enhanced menu display loaded successfully"
                fi
            else
                print_warning "Enhanced menu display module failed to load (runtime error)"
            fi
        else
            print_warning "Enhanced menu display module has syntax errors"
        fi
    fi
    
    # Load legacy enhanced UI utilities
    if [[ -f "$SCRIPT_DIR/ui/enhanced.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/enhanced.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/enhanced.sh" 2>/dev/null; then
                print_success "Legacy enhanced UI module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Legacy enhanced UI utilities loaded successfully"
                fi
            else
                print_warning "Legacy enhanced UI module failed to load (runtime error)"
            fi
        else
            print_warning "Legacy enhanced UI module has syntax errors"
        fi
    fi
    
    # Load dialog wrapper
    if [[ -f "$SCRIPT_DIR/ui/dialog_wrapper.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/dialog_wrapper.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/dialog_wrapper.sh" 2>/dev/null; then
                print_success "Dialog wrapper module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Dialog/Whiptail integration loaded successfully"
                fi
            else
                print_warning "Dialog wrapper module failed to load (runtime error)"
            fi
        else
            print_warning "Dialog wrapper module has syntax errors"
        fi
    fi
    
    # Load fzf integration
    if [[ -f "$SCRIPT_DIR/ui/fzf_integration.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/fzf_integration.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/fzf_integration.sh" 2>/dev/null; then
                print_success "fzf integration module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "fzf search integration loaded successfully"
                fi
            else
                print_warning "fzf integration module failed to load (runtime error)"
            fi
        else
            print_warning "fzf integration module has syntax errors"
        fi
    fi
    
    # Load notifications system
    if [[ -f "$SCRIPT_DIR/ui/notifications.sh" ]]; then
        if bash -n "$SCRIPT_DIR/ui/notifications.sh" 2>/dev/null; then
            if source "$SCRIPT_DIR/ui/notifications.sh" 2>/dev/null; then
                print_success "Notifications module loaded"
                if declare -f log_info >/dev/null; then
                    log_info "Notification system loaded successfully"
                fi
            else
                print_warning "Notifications module failed to load (runtime error)"
            fi
        else
            print_warning "Notifications module has syntax errors"
        fi
    fi
    
    if declare -f log_info >/dev/null; then
        log_info "All system modules loaded successfully"
    fi
    
    return 0
}

set_default_config() {
    # Set default configuration values
    MENU_TITLE="SAM - System Administration Menu"
    ENABLE_COLORS=true
    AUTO_REFRESH=false
    SHOW_TIMESTAMP=true
    DEFAULT_THEME="modern_corporate"
    LOG_LEVEL=1
    LOG_FILE="/tmp/bashmenu.log"
    ENABLE_HISTORY=true
    HISTORY_FILE="$HOME/.bashmenu_history.log"
    ENABLE_PERMISSIONS=false
    ENABLE_PLUGINS=true
    PLUGIN_DIR="$PROJECT_ROOT/plugins"
    ENABLE_NOTIFICATIONS=true
    NOTIFICATION_DURATION=3000
    AUTO_BACKUP=true
    BACKUP_RETENTION_DAYS=7
    BACKUP_DIR="$HOME/.bashmenu/backups"
    
    # Enhanced UI configuration
    ENABLE_ENHANCED_UI=true
    MENU_PAGE_SIZE=10
    ENABLE_ANIMATIONS=true
    ENABLE_SEARCH=true
    PROFESSIONAL_THEME_ENABLED=true
}

# =============================================================================
# Welcome and Information Functions
# =============================================================================

show_welcome() {
    clear

    # Enhanced welcome screen with clean design
    print_header "Welcome to Bashmenu v$SCRIPT_VERSION"
    echo ""

    if [[ "${ENABLE_COLORS:-true}" == "true" ]]; then
        echo -e "${GREEN}🚀 System Information:${NC}"
        echo -e "   🖥️  Hostname: $(hostname)"
        echo -e "   🐧 OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
        echo -e "   ⚙️  Kernel: $(uname -r)"
        echo -e "   ⏱️  Uptime: $(uptime -p | sed 's/up //')"
        echo -e "   👤 User: $(whoami)"
        echo ""

        # Quick system health
        local cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
        local mem=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        local disk=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')
        
        echo -e "${CYAN}📊 Quick Status:${NC}"
        printf "   CPU: "
        [[ ${cpu:-0} -lt 70 ]] && echo -e "${GREEN}${cpu}%${NC} ✓" || echo -e "${YELLOW}${cpu}%${NC} ⚠"
        printf "   Memory: "
        [[ ${mem:-0} -lt 70 ]] && echo -e "${GREEN}${mem}%${NC} ✓" || echo -e "${YELLOW}${mem}%${NC} ⚠"
        printf "   Disk: "
        [[ ${disk:-0} -lt 70 ]] && echo -e "${GREEN}${disk}%${NC} ✓" || echo -e "${YELLOW}${disk}%${NC} ⚠"
        echo ""

        # System status indicators
        if [[ "${ENABLE_PLUGINS:-true}" == "true" ]]; then
            echo -e "${CYAN}🔌 Plugin System:${NC} ${GREEN}Enabled${NC}"
        else
            echo -e "${CYAN}🔌 Plugin System:${NC} ${YELLOW}Disabled${NC}"
        fi

        if [[ "${ENABLE_PERMISSIONS:-false}" == "true" ]]; then
            echo -e "${CYAN}🔒 Permission System:${NC} ${GREEN}Enabled${NC}"
        else
            echo -e "${CYAN}🔒 Permission System:${NC} ${YELLOW}Disabled${NC}"
        fi

        echo ""
        echo -e "${CYAN}💡 Pro Tip:${NC} Press ${PURPLE}'d'${NC} anytime for instant dashboard"
        echo ""
        echo -e "${GREEN}Press any key to continue...${NC}"
    else
        echo "System Information:"
        echo "   Hostname: $(hostname)"
        echo "   OS: $(uname -s) $(uname -r)"
        echo "   Kernel: $(uname -r)"
        echo "   Uptime: $(uptime -p | sed 's/up //')"
        echo "   User: $(whoami)"
        echo ""

        echo "Plugin System: Enabled"
        echo "Permission System: Disabled"
        echo "Available Themes: default, dark, colorful, minimal, modern"

        echo ""
        echo "Ready to start! Press any key to continue..."
    fi

    read -s -n 1
}

show_system_info() {
    print_header "System Information"
    echo ""
    echo -e "${CYAN}=== Basic Info ===${NC}"
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Uptime: $(uptime -p | sed 's/up //')"
    echo ""
    
    echo -e "${CYAN}=== Hardware Info ===${NC}"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
    echo ""
    
    echo -e "${CYAN}=== Bashmenu Info ===${NC}"
    echo "Version: $SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR"
    echo "Configuration: $CONFIG_FILE"
    echo "Log File: ${LOG_FILE:-/tmp/bashmenu.log}"
    echo ""
}

# =============================================================================
# Main Functions
# =============================================================================

main() {

    # Check requirements
    if ! check_requirements; then
        print_error "System requirements not met"
        print_error "Please ensure all required commands are installed"
        print_error "Run 'make setup' to install dependencies"
        exit 1
    fi
    
    # Initialize system
    if ! initialize_system; then
        print_error "System initialization failed"
        print_error "Check logs for details: ${BASHMENU_LOG_FILE:-/tmp/bashmenu.log}"
        exit 1
    fi
    
    # Show welcome
    show_welcome
    
    # Start menu loop
    if declare -f menu_loop >/dev/null; then
        menu_loop
    else
        print_error "Menu loop function not found"
        exit 1
    fi
}

# =============================================================================
# Help Functions
# =============================================================================

show_help() {
    print_header "Bashmenu Help"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  bash main.sh [options]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --help, -h     Show this help message"
    echo "  --version, -v  Show version information"
    echo "  --info, -i     Show system information"
    echo "  --config, -c   Show configuration information"
    echo ""
    echo -e "${CYAN}Features:${NC}"
    echo "  • Interactive menu system"
    echo "  • Multiple themes support"
    echo "  • Plugin system"
    echo "  • Permission-based access control"
    echo "  • Comprehensive logging"
    echo "  • System monitoring tools"
    echo "  • Configuration management"
    echo ""
    echo -e "${CYAN}Keyboard Shortcuts:${NC}"
    echo "  • Arrow keys: Navigate menu"
    echo "  • Enter: Select option"
    echo "  • q: Quick exit"
    echo "  • h: Show help"
    echo "  • r: Refresh menu"
    echo ""
}

show_version() {
    print_header "Version Information"
    echo ""
    echo "Bashmenu v$SCRIPT_VERSION"
    echo "Author: $SCRIPT_AUTHOR"
    echo "License: MIT"
    echo ""
    echo "Enhanced system administration menu with:"
    echo "• Modular architecture"
    echo "• Plugin support"
    echo "• Theme system"
    echo "• Permission controls"
    echo "• Comprehensive logging"
    echo ""
}

show_config_info() {
    print_header "Configuration Information"
    echo ""

    # Use new config system if available
    if declare -f print_config >/dev/null; then
        print_config
        return 0
    fi

    # Fallback to old method
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${GREEN}Configuration file:${NC} $CONFIG_FILE"
        echo ""
        echo -e "${CYAN}Current Settings:${NC}"
        echo "Menu Title: ${MENU_TITLE:-Not set}"
        echo "Default Theme: ${DEFAULT_THEME:-default}"
        echo "Enable Colors: ${ENABLE_COLORS:-true}"
        echo "Show Timestamp: ${SHOW_TIMESTAMP:-true}"
        echo "Enable Permissions: ${ENABLE_PERMISSIONS:-false}"
        echo "Enable Plugins: ${ENABLE_PLUGINS:-true}"
        echo "Enable Notifications: ${ENABLE_NOTIFICATIONS:-true}"
        echo "Log Level: ${LOG_LEVEL:-1}"
        echo "Log File: ${LOG_FILE:-/tmp/bashmenu.log}"
        echo ""
        echo -e "${CYAN}Auto-Scan Settings:${NC}"
        echo "Enable Auto-Scan: ${ENABLE_AUTO_SCAN:-true}"
        echo "Enable Manual Scripts: ${ENABLE_MANUAL_SCRIPTS:-true}"
        echo "Plugin Scan Depth: ${PLUGIN_SCAN_DEPTH:-3}"
        echo "Plugin Extensions: ${PLUGIN_EXTENSIONS:-.sh}"
        echo ""
    else
        echo -e "${YELLOW}No configuration file found${NC}"
        echo "Using default settings"
        echo ""
    fi
}

# =============================================================================
# Command Line Interface
# =============================================================================

parse_arguments() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
        --info|-i)
            show_system_info
            exit 0
            ;;
        --config|-c)
            show_config_info
            exit 0
            ;;
        "")
            # No arguments, run main program
            main "$@"
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# =============================================================================
# Signal Handling
# =============================================================================

cleanup() {
    echo ""
    print_info "Cleaning up..."
    
    # Cleanup old backups if function exists
    if declare -f cleanup_old_backups >/dev/null; then
        cleanup_old_backups
    fi
    
    print_success "Cleanup completed"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# =============================================================================
# Main Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_arguments "$@"
fi 
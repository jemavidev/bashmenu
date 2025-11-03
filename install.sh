#!/bin/bash

################################################################################
# Bashmenu Installation Script
# ==============================================================================
# Description: Installs and configures the enhanced Bashmenu system
# Date:        January 15, 2024
# Creator:     JESUS VILLALOBOS (Enhanced with AI assistance)
# Version:     2.0
# License:     MIT License
################################################################################

# =============================================================================
# Script Information
# =============================================================================

readonly SCRIPT_NAME="Bashmenu Installer"
readonly SCRIPT_VERSION="2.0"
readonly SCRIPT_AUTHOR="JESUS MARIA VILLALOBOS"

# =============================================================================
# Color Definitions
# =============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Global Variables
# =============================================================================

# Installation paths - Optimized for cloud servers
readonly INSTALL_DIR="/opt/bashmenu"
readonly CONFIG_DIR="/opt/bashmenu/config"
readonly LOG_DIR="/var/log/bashmenu"
readonly PLUGIN_DIR="/opt/bashmenu/plugins"
readonly SCRIPTS_DIR="/opt/scripts"

# Current directory
readonly CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation options - Optimized for cloud servers
INSTALL_TYPE="system"
CREATE_SYMLINK=true
BACKUP_EXISTING=false  # No backups needed for fresh server installs
INSTALL_PLUGINS=true

# =============================================================================
# Utility Functions
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

check_requirements() {
    print_info "Checking system requirements..."
    
    local errors=0
    
    # Check if running as root for system installation
    if [[ "$EUID" -ne 0 ]]; then
        print_error "System installation requires root privileges"
        print_info "Run with sudo: sudo ./install.sh"
        errors=$((errors + 1))
    fi
    
    # Check required commands
    local required_commands=("bash" "cp" "mkdir" "chmod")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_error "Required command not found: $cmd"
            errors=$((errors + 1))
        fi
    done
    
    # Check if source files exist
    local required_files=("src/main.sh" "src/utils.sh" "src/menu.sh" "src/logger.sh" "src/script_loader.sh" "src/script_validator.sh" "src/script_executor.sh" "config/config.conf" "bashmenu")
    for file in "${required_files[@]}"; do
        if [[ ! -f "$CURRENT_DIR/$file" ]]; then
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
# Installation Functions
# =============================================================================

create_directories() {
    print_info "Creating installation directories..."

    local dirs=("$INSTALL_DIR" "$CONFIG_DIR" "$LOG_DIR" "$PLUGIN_DIR" "$SCRIPTS_DIR")

    for dir in "${dirs[@]}"; do
        if mkdir -p "$dir" 2>/dev/null; then
            print_success "Created directory: $dir"
        else
            print_error "Failed to create directory: $dir"
            return 1
        fi
    done

    return 0
}

install_main_script() {
    print_info "Installing main script and source files..."

    local source_file="$CURRENT_DIR/bashmenu"
    local target_file="$INSTALL_DIR/bashmenu"

    # Copy main script
    if cp "$source_file" "$target_file"; then
        chmod +x "$target_file"
        print_success "Installed main script: $target_file"
    else
        print_error "Failed to install main script"
        return 1
    fi

    # Copy source files to installation directory
    local src_target_dir="$INSTALL_DIR/src"
    if mkdir -p "$src_target_dir" && cp -r "$CURRENT_DIR/src/"* "$src_target_dir/"; then
        print_success "Installed source files to: $src_target_dir"
    else
        print_error "Failed to install source files"
        return 1
    fi

    # Create symlink in /usr/local/bin for global access
    local symlink_target="/usr/local/bin/bashmenu"
    if [[ ! -L "$symlink_target" ]]; then
        if ln -sf "$target_file" "$symlink_target"; then
            print_success "Created global symlink: $symlink_target"
        else
            print_warning "Failed to create global symlink"
        fi
    fi

    return 0
}

install_configuration() {
    print_info "Installing configuration files..."

    local source_config="$CURRENT_DIR/config/config.conf"
    local target_config="$CONFIG_DIR/config.conf"

    # Copy configuration
    if cp "$source_config" "$target_config"; then
        print_success "Installed configuration: $target_config"
    else
        print_error "Failed to install configuration"
        return 1
    fi

    return 0
}

install_plugins() {
    if [[ "$INSTALL_PLUGINS" != "true" ]]; then
        print_info "Skipping plugin installation"
        return 0
    fi

    print_info "Installing plugins and example scripts..."

    local source_plugin_dir="$CURRENT_DIR/plugins"
    local target_plugin_dir="$PLUGIN_DIR"

    if [[ -d "$source_plugin_dir" ]]; then
        # Create examples subdirectory
        mkdir -p "$target_plugin_dir/examples" 2>/dev/null
        
        # Copy all plugins
        if cp -r "$source_plugin_dir"/* "$target_plugin_dir/" 2>/dev/null; then
            print_success "Installed plugins to: $target_plugin_dir"
            
            # Set execute permissions on example scripts
            if [[ -d "$target_plugin_dir/examples" ]]; then
                chmod +x "$target_plugin_dir/examples"/*.sh 2>/dev/null
                print_success "Set execute permissions on example scripts"
            fi
        else
            print_warning "Failed to install plugins"
        fi
    else
        print_warning "No plugins directory found"
    fi
    
    # Copy scripts.conf.example to config directory
    local source_scripts_conf_example="$CURRENT_DIR/config/scripts.conf.example"
    local target_scripts_conf_example="$CONFIG_DIR/scripts.conf.example"
    
    if [[ -f "$source_scripts_conf_example" ]]; then
        if cp "$source_scripts_conf_example" "$target_scripts_conf_example" 2>/dev/null; then
            print_success "Installed scripts.conf.example to: $CONFIG_DIR"
        else
            print_warning "Failed to install scripts.conf.example"
        fi
    fi
    
    # Copy scripts.conf.example as scripts.conf (active configuration with examples enabled)
    local source_scripts_conf="$CURRENT_DIR/config/scripts.conf.example"
    local target_scripts_conf="$CONFIG_DIR/scripts.conf"
    
    if [[ -f "$source_scripts_conf" ]]; then
        if cp "$source_scripts_conf" "$target_scripts_conf" 2>/dev/null; then
            print_success "Installed scripts.conf to: $CONFIG_DIR (with examples enabled)"
        else
            print_warning "Failed to install scripts.conf"
        fi
    fi

    return 0
}

set_permissions() {
    print_info "Setting file permissions..."

    # Set permissions for main script
    if [[ -f "$INSTALL_DIR/bashmenu" ]]; then
        chmod +x "$INSTALL_DIR/bashmenu"
        print_success "Set executable permissions on: $INSTALL_DIR/bashmenu"
    fi

    # Set permissions for scripts directory
    if [[ -d "$SCRIPTS_DIR" ]]; then
        chmod 755 "$SCRIPTS_DIR"
        print_success "Set permissions on scripts directory: $SCRIPTS_DIR"
    fi

    return 0
}

# =============================================================================
# Post-Installation Functions
# =============================================================================

create_desktop_entry() {
    print_info "Skipping desktop entry creation (server environment)"
    # Desktop entries are not needed in server environments
}

update_path() {
    print_info "Ensuring bashmenu is in PATH..."

    # Since we created a symlink in /usr/local/bin, it should be in PATH
    # But let's verify and add to system-wide profile if needed
    local path_line='export PATH="/usr/local/bin:$PATH"'

    if [[ -f "/etc/bash.bashrc" ]]; then
        if ! grep -q "/usr/local/bin" "/etc/bash.bashrc"; then
            echo "" >> "/etc/bash.bashrc"
            echo "# Bashmenu PATH" >> "/etc/bash.bashrc"
            echo "$path_line" >> "/etc/bash.bashrc"
            print_success "Updated system PATH in /etc/bash.bashrc"
        else
            print_info "PATH already configured in system profile"
        fi
    fi
}

# =============================================================================
# Verification Functions
# =============================================================================

verify_installation() {
    print_info "Verifying installation..."

    local target_file="$INSTALL_DIR/bashmenu"
    local errors=0

    # Check if main script exists and is executable
    if [[ ! -f "$target_file" ]]; then
        print_error "Main script not found: $target_file"
        errors=$((errors + 1))
    elif [[ ! -x "$target_file" ]]; then
        print_error "Main script not executable: $target_file"
        errors=$((errors + 1))
    else
        print_success "Main script verified: $target_file"
    fi

    # Check if symlink exists
    if [[ ! -L "/usr/local/bin/bashmenu" ]]; then
        print_error "Global symlink not found: /usr/local/bin/bashmenu"
        errors=$((errors + 1))
    else
        print_success "Global symlink verified: /usr/local/bin/bashmenu"
    fi

    # Check if directories exist
    for dir in "$CONFIG_DIR" "$PLUGIN_DIR" "$SCRIPTS_DIR"; do
        if [[ ! -d "$dir" ]]; then
            print_error "Directory not found: $dir"
            errors=$((errors + 1))
        fi
    done

    # Test script execution
    if [[ $errors -eq 0 ]]; then
        # Set the PROJECT_ROOT environment variable for the test
        if PROJECT_ROOT="$INSTALL_DIR" "$target_file" --version >/dev/null 2>&1; then
            print_success "Script execution test passed"
        else
            print_error "Script execution test failed"
            errors=$((errors + 1))
        fi
    fi

    if [[ $errors -eq 0 ]]; then
        print_success "Installation verification completed"
        return 0
    else
        print_error "Installation verification failed ($errors errors)"
        return 1
    fi
}

# =============================================================================
# Uninstall Functions
# =============================================================================

uninstall() {
    print_header "Uninstalling Bashmenu"
    
    local target_file
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_file="$INSTALL_DIR/bashmenu"
    else
        target_file="$HOME/.local/bin/bashmenu"
    fi
    
    # Remove main script
    if [[ -f "$target_file" ]]; then
        if rm "$target_file"; then
            print_success "Removed: $target_file"
        else
            print_error "Failed to remove: $target_file"
        fi
    fi
    
    # Remove symlink
    if [[ -L "/usr/local/bin/bashmenu" ]]; then
        if rm "/usr/local/bin/bashmenu"; then
            print_success "Removed symlink: /usr/local/bin/bashmenu"
        fi
    fi
    
    # Remove configuration
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        if [[ -d "$CONFIG_DIR" ]]; then
            if rm -rf "$CONFIG_DIR"; then
                print_success "Removed configuration directory: $CONFIG_DIR"
            fi
        fi
    else
        if [[ -d "$HOME/.bashmenu" ]]; then
            if rm -rf "$HOME/.bashmenu"; then
                print_success "Removed user configuration: $HOME/.bashmenu"
            fi
        fi
    fi
    
    # Remove desktop entry
    local desktop_file="/usr/share/applications/bashmenu.desktop"
    if [[ -f "$desktop_file" ]]; then
        if rm "$desktop_file"; then
            print_success "Removed desktop entry: $desktop_file"
        fi
    fi
    
    print_success "Uninstallation completed"
}

# =============================================================================
# Main Installation Function
# =============================================================================

install() {
    print_header "Installing Bashmenu v$SCRIPT_VERSION for Cloud Servers"

    # Check requirements
    if ! check_requirements; then
        print_error "Installation aborted due to requirements check failure"
        exit 1
    fi

    # Create directories
    if ! create_directories; then
        print_error "Installation aborted due to directory creation failure"
        exit 1
    fi

    # Install main script
    if ! install_main_script; then
        print_error "Installation aborted due to script installation failure"
        exit 1
    fi

    # Install configuration
    if ! install_configuration; then
        print_error "Installation aborted due to configuration installation failure"
        exit 1
    fi

    # Install plugins
    install_plugins

    # Set permissions
    set_permissions

    # Create desktop entry (skipped for servers)
    create_desktop_entry

    # Update PATH
    update_path

    # Verify installation
    if ! verify_installation; then
        print_error "Installation verification failed"
        exit 1
    fi

    print_header "Installation Completed Successfully"
    echo ""
    print_success "Bashmenu v$SCRIPT_VERSION has been installed successfully!"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  bashmenu                    # Start the menu"
    echo "  bashmenu --help            # Show help"
    echo "  bashmenu --version         # Show version"
    echo "  bashmenu --info            # Show system info"
    echo ""
    echo -e "${CYAN}Installation Details:${NC}"
    echo "  Main Script: $INSTALL_DIR/bashmenu"
    echo "  Global Symlink: /usr/local/bin/bashmenu"
    echo "  Configuration: $CONFIG_DIR/config.conf"
    echo "  Scripts Config: $CONFIG_DIR/scripts.conf.example"
    echo "  Plugins Directory: $PLUGIN_DIR/"
    echo "  Example Scripts: $PLUGIN_DIR/examples/"
    echo ""
    echo -e "${YELLOW}Next Steps - Adding Your Scripts:${NC}"
    echo "  1. Review example scripts:"
    echo "     ls -la $PLUGIN_DIR/examples/"
    echo ""
    echo "  2. Edit scripts.conf to enable example scripts or add your own:"
    echo "     nano $CONFIG_DIR/scripts.conf"
    echo ""
    echo "  3. Place your custom scripts in:"
    echo "     $PLUGIN_DIR/"
    echo ""
    echo "  4. Make scripts executable:"
    echo "     chmod +x $PLUGIN_DIR/your_script.sh"
    echo ""
    echo "  5. Run bashmenu to see your scripts in the menu:"
    echo "     bashmenu"
    echo ""
    echo -e "${CYAN}Example Scripts (Enabled by Default):${NC}"
    echo "  • Git Status         - Show repository status"
    echo "  • Git Pull           - Pull latest changes"
    echo "  • Docker PS          - Show running containers"
    echo "  • Docker Logs        - Show container logs"
    echo ""
    echo -e "${GREEN}Ready to use!${NC} Run 'bashmenu' to see the menu with examples."
    echo -e "${YELLOW}Note:${NC} Edit scripts.conf to add your own scripts or disable examples."
    echo ""
}

# =============================================================================
# Command Line Interface
# =============================================================================

show_help() {
    print_header "Bashmenu Installer Help"
    echo ""
    echo -e "${CYAN}Usage:${NC}"
    echo "  ./install.sh [options]"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  --system, -s         Install system-wide (default for servers)"
    echo "  --no-plugins         Don't install plugins"
    echo "  --uninstall          Uninstall Bashmenu"
    echo "  --help, -h           Show this help message"
    echo ""
    echo -e "${CYAN}Server Installation:${NC}"
    echo "  This installer is optimized for cloud servers and installs to:"
    echo "  - /opt/bashmenu/     (main application)"
    echo "  - /opt/scripts/      (your custom scripts)"
    echo "  - /usr/local/bin/    (global symlink)"
    echo ""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --system|-s)
                INSTALL_TYPE="system"
                shift
                ;;
            --no-plugins)
                INSTALL_PLUGINS=false
                shift
                ;;
            --uninstall)
                uninstall
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    parse_arguments "$@"
    install
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 
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
readonly SCRIPT_AUTHOR="JESUS VILLALOBOS"

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

# Installation paths
readonly INSTALL_DIR="/usr/local/bin"
readonly CONFIG_DIR="/etc/bashmenu"
readonly LOG_DIR="/var/log/bashmenu"
readonly PLUGIN_DIR="/usr/local/share/bashmenu/plugins"

# Current directory
readonly CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation options
INSTALL_TYPE="system"
CREATE_SYMLINK=true
BACKUP_EXISTING=true
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
    if [[ "$INSTALL_TYPE" == "system" && "$EUID" -ne 0 ]]; then
        print_error "System installation requires root privileges"
        print_info "Run with sudo or use --user installation"
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
    local required_files=("src/main.sh" "src/utils.sh" "src/commands.sh" "src/menu.sh" "config/config.conf")
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
    
    local dirs=()
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        dirs=("$CONFIG_DIR" "$LOG_DIR" "$PLUGIN_DIR")
    else
        dirs=("$HOME/.bashmenu" "$HOME/.bashmenu/plugins" "$HOME/.bashmenu/logs")
    fi
    
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
    print_info "Installing main script..."
    
    local source_file="$CURRENT_DIR/bashmenu"
    local target_file
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_file="$INSTALL_DIR/bashmenu"
    else
        target_file="$HOME/.local/bin/bashmenu"
        mkdir -p "$(dirname "$target_file")"
    fi
    
    # Backup existing file if requested
    if [[ "$BACKUP_EXISTING" == "true" && -f "$target_file" ]]; then
        local backup_file="${target_file}.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$target_file" "$backup_file"; then
            print_info "Backed up existing file: $backup_file"
        fi
    fi
    
    # Copy main script
    if cp "$source_file" "$target_file"; then
        chmod +x "$target_file"
        print_success "Installed main script: $target_file"
    else
        print_error "Failed to install main script"
        return 1
    fi
    
    # Create symlink if requested
    if [[ "$CREATE_SYMLINK" == "true" ]]; then
        local symlink_target="/usr/local/bin/bashmenu"
        if [[ "$INSTALL_TYPE" == "user" ]]; then
            symlink_target="$HOME/.local/bin/bashmenu"
        fi
        
        if [[ ! -L "$symlink_target" ]]; then
            if ln -sf "$target_file" "$symlink_target"; then
                print_success "Created symlink: $symlink_target"
            else
                print_warning "Failed to create symlink"
            fi
        fi
    fi
    
    return 0
}

install_configuration() {
    print_info "Installing configuration files..."
    
    local source_config="$CURRENT_DIR/config/config.conf"
    local target_config
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_config="$CONFIG_DIR/config.conf"
    else
        target_config="$HOME/.bashmenu/config.conf"
    fi
    
    # Backup existing config if requested
    if [[ "$BACKUP_EXISTING" == "true" && -f "$target_config" ]]; then
        local backup_file="${target_config}.backup.$(date +%Y%m%d_%H%M%S)"
        if cp "$target_config" "$backup_file"; then
            print_info "Backed up existing config: $backup_file"
        fi
    fi
    
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
    
    print_info "Installing plugins..."
    
    local source_plugin_dir="$CURRENT_DIR/plugins"
    local target_plugin_dir
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_plugin_dir="$PLUGIN_DIR"
    else
        target_plugin_dir="$HOME/.bashmenu/plugins"
    fi
    
    if [[ -d "$source_plugin_dir" ]]; then
        if cp -r "$source_plugin_dir"/* "$target_plugin_dir/" 2>/dev/null; then
            print_success "Installed plugins to: $target_plugin_dir"
        else
            print_warning "Failed to install plugins"
        fi
    else
        print_warning "No plugins directory found"
    fi
    
    return 0
}

set_permissions() {
    print_info "Setting file permissions..."
    
    local target_file
    
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_file="$INSTALL_DIR/bashmenu"
    else
        target_file="$HOME/.local/bin/bashmenu"
    fi
    
    if [[ -f "$target_file" ]]; then
        chmod +x "$target_file"
        print_success "Set executable permissions on: $target_file"
    fi
    
    return 0
}

# =============================================================================
# Post-Installation Functions
# =============================================================================

create_desktop_entry() {
    print_info "Creating desktop entry..."
    
    local desktop_dir
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        desktop_dir="/usr/share/applications"
    else
        desktop_dir="$HOME/.local/share/applications"
        mkdir -p "$desktop_dir"
    fi
    
    local desktop_file="$desktop_dir/bashmenu.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Name=Bashmenu
Comment=System Administration Menu
Exec=bashmenu
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=System;Utility;
Version=1.0
EOF
    
    if [[ -f "$desktop_file" ]]; then
        print_success "Created desktop entry: $desktop_file"
    else
        print_warning "Failed to create desktop entry"
    fi
}

update_path() {
    if [[ "$INSTALL_TYPE" == "user" ]]; then
        print_info "Updating PATH..."
        
        local path_line='export PATH="$HOME/.local/bin:$PATH"'
        local shell_rc
        
        if [[ -f "$HOME/.bashrc" ]]; then
            shell_rc="$HOME/.bashrc"
        elif [[ -f "$HOME/.zshrc" ]]; then
            shell_rc="$HOME/.zshrc"
        else
            print_warning "No shell configuration file found"
            return 0
        fi
        
        if ! grep -q "$path_line" "$shell_rc"; then
            echo "" >> "$shell_rc"
            echo "# Bashmenu PATH" >> "$shell_rc"
            echo "$path_line" >> "$shell_rc"
            print_success "Updated PATH in $shell_rc"
        else
            print_info "PATH already configured in $shell_rc"
        fi
    fi
}

# =============================================================================
# Verification Functions
# =============================================================================

verify_installation() {
    print_info "Verifying installation..."
    
    local target_file
    if [[ "$INSTALL_TYPE" == "system" ]]; then
        target_file="$INSTALL_DIR/bashmenu"
    else
        target_file="$HOME/.local/bin/bashmenu"
    fi
    
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
    
    # Test script execution
    if [[ $errors -eq 0 ]]; then
        if "$target_file" --version >/dev/null 2>&1; then
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
    print_header "Installing Bashmenu v$SCRIPT_VERSION"
    
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
    
    # Create desktop entry
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
    echo -e "${CYAN}Installation Type:${NC} $INSTALL_TYPE"
    if [[ "$INSTALL_TYPE" == "user" ]]; then
        echo -e "${CYAN}Location:${NC} $HOME/.local/bin/bashmenu"
        echo ""
        echo -e "${YELLOW}Note:${NC} You may need to restart your terminal or run:"
        echo "  source ~/.bashrc"
    else
        echo -e "${CYAN}Location:${NC} $INSTALL_DIR/bashmenu"
    fi
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
    echo "  --user, -u           Install for current user only"
    echo "  --system, -s         Install system-wide (requires sudo)"
    echo "  --no-symlink         Don't create symlinks"
    echo "  --no-backup          Don't backup existing files"
    echo "  --no-plugins         Don't install plugins"
    echo "  --uninstall          Uninstall Bashmenu"
    echo "  --help, -h           Show this help message"
    echo ""
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --user|-u)
                INSTALL_TYPE="user"
                shift
                ;;
            --system|-s)
                INSTALL_TYPE="system"
                shift
                ;;
            --no-symlink)
                CREATE_SYMLINK=false
                shift
                ;;
            --no-backup)
                BACKUP_EXISTING=false
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
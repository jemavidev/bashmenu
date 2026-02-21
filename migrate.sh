#!/bin/bash

# =============================================================================
# Bashmenu Migration Script - v2.1 to v2.2
# =============================================================================
# Description: Migrates Bashmenu v2.1 installation to v2.2
# Version:     1.0.0
# Author:      JESUS MARIA VILLALOBOS
# =============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Script info
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"

# Migration settings
DRY_RUN=false
BACKUP_DIR=""
MIGRATION_LOG=""
ROLLBACK_AVAILABLE=false

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "=============================================="
    echo "  $1"
    echo "=============================================="
    echo -e "${NC}"
}

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

log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$MIGRATION_LOG"
}

# =============================================================================
# Detection Functions
# =============================================================================

detect_version() {
    local version=""
    
    # Check main.sh for version
    if [[ -f "$PROJECT_ROOT/src/main.sh" ]]; then
        version=$(grep "readonly SCRIPT_VERSION=" "$PROJECT_ROOT/src/main.sh" | cut -d'"' -f2)
    fi
    
    echo "$version"
}

detect_installation_type() {
    if [[ "$PROJECT_ROOT" == "/opt/bashmenu" ]]; then
        echo "system"
    elif [[ "$PROJECT_ROOT" == "$HOME/.local/bashmenu" ]] || [[ "$PROJECT_ROOT" == "$HOME/bashmenu" ]]; then
        echo "user"
    else
        echo "development"
    fi
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local errors=0
    
    # Check bash version
    if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
        print_error "Bash 4.0+ required (current: $BASH_VERSION)"
        errors=$((errors + 1))
    fi
    
    # Check required commands
    local required_commands=("cp" "mv" "mkdir" "grep" "sed")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_error "Required command not found: $cmd"
            errors=$((errors + 1))
        fi
    done
    
    # Check write permissions
    if [[ ! -w "$PROJECT_ROOT" ]]; then
        print_error "No write permission in $PROJECT_ROOT"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        return 1
    fi
    
    print_success "Prerequisites check passed"
    return 0
}

# =============================================================================
# Backup Functions
# =============================================================================

create_backup() {
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    BACKUP_DIR="$PROJECT_ROOT/backup_v2.1_${timestamp}"
    
    print_info "Creating backup in $BACKUP_DIR..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "[DRY RUN] Would create backup: $BACKUP_DIR"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup critical files
    local files_to_backup=(
        "config/config.conf"
        "config/scripts.conf"
        "src/main.sh"
        ".bashmenu.env"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$PROJECT_ROOT/$file" ]]; then
            local dir=$(dirname "$file")
            mkdir -p "$BACKUP_DIR/$dir"
            cp -p "$PROJECT_ROOT/$file" "$BACKUP_DIR/$file"
            log_message "Backed up: $file"
        fi
    done
    
    # Create backup manifest
    cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
Bashmenu Backup
Created: $(date)
Version: $(detect_version)
Installation: $(detect_installation_type)
Files backed up: ${#files_to_backup[@]}
EOF
    
    ROLLBACK_AVAILABLE=true
    print_success "Backup created successfully"
    log_message "Backup created: $BACKUP_DIR"
}

# =============================================================================
# Migration Functions
# =============================================================================

migrate_config_to_env() {
    print_info "Migrating config.conf to .bashmenu.env..."
    
    local old_config="$PROJECT_ROOT/config/config.conf"
    local new_env="$PROJECT_ROOT/.bashmenu.env"
    
    if [[ ! -f "$old_config" ]]; then
        print_warning "config.conf not found, skipping"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "[DRY RUN] Would migrate config.conf to .bashmenu.env"
        return 0
    fi
    
    # Create .bashmenu.env from template
    if [[ -f "$PROJECT_ROOT/.bashmenu.env.example" ]]; then
        cp "$PROJECT_ROOT/.bashmenu.env.example" "$new_env"
    else
        touch "$new_env"
    fi
    
    # Extract values from old config
    local log_level=$(grep "^LOG_LEVEL=" "$old_config" 2>/dev/null | cut -d'=' -f2 || echo "")
    local theme=$(grep "^DEFAULT_THEME=" "$old_config" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "")
    local enable_colors=$(grep "^ENABLE_COLORS=" "$old_config" 2>/dev/null | cut -d'=' -f2 || echo "")
    
    # Map old values to new format
    if [[ -n "$log_level" ]]; then
        case "$log_level" in
            0) echo "BASHMENU_LOG_LEVEL=DEBUG" >> "$new_env" ;;
            1) echo "BASHMENU_LOG_LEVEL=INFO" >> "$new_env" ;;
            2) echo "BASHMENU_LOG_LEVEL=WARN" >> "$new_env" ;;
            3) echo "BASHMENU_LOG_LEVEL=ERROR" >> "$new_env" ;;
        esac
    fi
    
    if [[ -n "$theme" ]]; then
        echo "BASHMENU_THEME=$theme" >> "$new_env"
    fi
    
    if [[ -n "$enable_colors" ]]; then
        echo "BASHMENU_ENABLE_COLORS=$enable_colors" >> "$new_env"
    fi
    
    print_success "Configuration migrated"
    log_message "Migrated config.conf to .bashmenu.env"
}

convert_paths_in_scripts_conf() {
    print_info "Converting paths in scripts.conf..."
    
    local scripts_conf="$PROJECT_ROOT/config/scripts.conf"
    
    if [[ ! -f "$scripts_conf" ]]; then
        print_warning "scripts.conf not found, skipping"
        return 0
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "[DRY RUN] Would convert paths in scripts.conf"
        return 0
    fi
    
    # Backup original
    cp "$scripts_conf" "$scripts_conf.bak"
    
    # Convert absolute paths to variables
    # Replace /home/*/... with ${PROJECT_ROOT}/...
    sed -i 's|/home/[^/]*/[^/]*/Bashmenu/|${PROJECT_ROOT}/|g' "$scripts_conf"
    
    # Replace /opt/bashmenu with ${BASHMENU_SYSTEM_PLUGINS}
    sed -i 's|/opt/bashmenu/plugins|${BASHMENU_SYSTEM_PLUGINS}|g' "$scripts_conf"
    
    print_success "Paths converted"
    log_message "Converted paths in scripts.conf"
}

validate_migration() {
    print_info "Validating migration..."
    
    local errors=0
    
    # Check .bashmenu.env exists
    if [[ ! -f "$PROJECT_ROOT/.bashmenu.env" ]]; then
        print_error ".bashmenu.env not created"
        errors=$((errors + 1))
    fi
    
    # Check main.sh version
    local version=$(detect_version)
    if [[ "$version" != "2.2" ]]; then
        print_error "Version not updated (current: $version)"
        errors=$((errors + 1))
    fi
    
    # Check config module exists
    if [[ ! -f "$PROJECT_ROOT/src/core/config.sh" ]]; then
        print_error "Config module not found"
        errors=$((errors + 1))
    fi
    
    # Validate syntax
    if ! bash -n "$PROJECT_ROOT/src/main.sh" 2>/dev/null; then
        print_error "main.sh has syntax errors"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -gt 0 ]]; then
        print_error "Validation failed ($errors errors)"
        return 1
    fi
    
    print_success "Validation passed"
    log_message "Migration validated successfully"
    return 0
}

# =============================================================================
# Rollback Functions
# =============================================================================

rollback_migration() {
    if [[ "$ROLLBACK_AVAILABLE" != "true" ]] || [[ -z "$BACKUP_DIR" ]]; then
        print_error "No backup available for rollback"
        return 1
    fi
    
    print_warning "Rolling back migration..."
    
    # Restore backed up files
    if [[ -d "$BACKUP_DIR" ]]; then
        cp -r "$BACKUP_DIR"/* "$PROJECT_ROOT/"
        print_success "Rollback completed"
        log_message "Rolled back to backup: $BACKUP_DIR"
        return 0
    fi
    
    print_error "Rollback failed: backup directory not found"
    return 1
}

# =============================================================================
# Main Migration Flow
# =============================================================================

run_migration() {
    local start_time=$(date +%s)
    
    print_header "Bashmenu Migration v2.1 → v2.2"
    echo ""
    
    # Detect current state
    local current_version=$(detect_version)
    local install_type=$(detect_installation_type)
    
    print_info "Current version: ${current_version:-unknown}"
    print_info "Installation type: $install_type"
    print_info "Project root: $PROJECT_ROOT"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
    fi
    
    echo ""
    
    # Check prerequisites
    if ! check_prerequisites; then
        print_error "Prerequisites check failed"
        exit 1
    fi
    
    echo ""
    
    # Create backup
    create_backup
    
    echo ""
    
    # Run migration steps
    print_header "Migration Steps"
    echo ""
    
    migrate_config_to_env
    convert_paths_in_scripts_conf
    
    echo ""
    
    # Validate
    if ! validate_migration; then
        print_error "Migration validation failed"
        
        if [[ "$DRY_RUN" != "true" ]]; then
            read -p "Rollback migration? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rollback_migration
            fi
        fi
        
        exit 1
    fi
    
    echo ""
    
    # Summary
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_header "Migration Complete"
    echo ""
    print_success "Migration completed successfully in ${duration}s"
    print_info "Backup location: $BACKUP_DIR"
    print_info "Migration log: $MIGRATION_LOG"
    echo ""
    print_info "Next steps:"
    echo "  1. Review .bashmenu.env and customize if needed"
    echo "  2. Test the system: bash src/main.sh --version"
    echo "  3. If issues occur, rollback with: bash migrate.sh --rollback"
    echo ""
}

# =============================================================================
# CLI Interface
# =============================================================================

show_help() {
    cat << EOF
Bashmenu Migration Script v$SCRIPT_VERSION

Usage: bash migrate.sh [OPTIONS]

Options:
  --dry-run         Show what would be done without making changes
  --rollback        Rollback to previous backup
  --help, -h        Show this help message

Examples:
  bash migrate.sh                    # Run migration
  bash migrate.sh --dry-run          # Preview migration
  bash migrate.sh --rollback         # Rollback migration

EOF
}

main() {
    # Setup logging
    MIGRATION_LOG="$PROJECT_ROOT/migration_$(date '+%Y%m%d_%H%M%S').log"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --rollback)
                # Find latest backup
                BACKUP_DIR=$(ls -td "$PROJECT_ROOT"/backup_v2.1_* 2>/dev/null | head -1)
                if [[ -n "$BACKUP_DIR" ]]; then
                    ROLLBACK_AVAILABLE=true
                    rollback_migration
                    exit $?
                else
                    print_error "No backup found"
                    exit 1
                fi
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
    
    # Run migration
    run_migration
}

# =============================================================================
# Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# Fallback logging functions (if not already defined)
if ! declare -f log_warn >/dev/null; then
  log_warn() { echo -e "[WARN] $*" >&2; }
fi
if ! declare -f log_info >/dev/null; then
  log_info() { echo -e "[INFO] $*" >&2; }
fi
if ! declare -f log_error >/dev/null; then
  log_error() { echo -e "[ERROR] $*" >&2; }
fi
if ! declare -f log_debug >/dev/null; then
  log_debug() { echo -e "[DEBUG] $*" >&2; }
fi

# Get system information
get_system_info() {
    echo -e "${CYAN}Hostname:${NC} $(hostname)"
    echo -e "${CYAN}OS:${NC} $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo -e "${CYAN}Kernel:${NC} $(uname -r)"
    echo -e "${CYAN}Uptime:${NC} $(uptime -p | sed 's/up //')"
    echo -e "${CYAN}CPU:${NC} $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo -e "${CYAN}Memory:${NC} $(free -h | grep Mem | awk '{print $3 "/" $2}')"
}

# =============================================================================
# Command Functions
# =============================================================================

# System Information Command
cmd_system_info() {
    clear
    print_header "🖥️ System Information"
    echo ""

    # System overview with icons
    echo -e "${CYAN}📊 System Overview:${NC}"
    echo -e "   🖥️  Hostname: $(hostname)"
    echo -e "   🐧 OS: $(lsb_release -d | cut -f2 2>/dev/null || echo "Unknown")"
    echo -e "   ⚙️  Kernel: $(uname -r)"
    echo -e "   ⏱️  Uptime: $(uptime -p | sed 's/up //')"
    echo -e "   👤 User: $(whoami)"
    echo ""

    print_separator
    echo -e "${CYAN}🔧 Detailed System Information:${NC}"
    echo -e "   🏗️  Architecture: $(uname -m)"
    echo -e "   📦 Distribution: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 2>/dev/null || echo "Unknown")"
    echo -e "   🐚 Shell: $SHELL"
    echo -e "   🏠 Home Directory: $HOME"
    echo ""

    print_separator
    echo -e "${CYAN}💻 Hardware Details:${NC}"
    echo -e "   🧠 CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo -e "   🔢 CPU Cores: $(nproc)"
    echo -e "   🧠 Total Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo -e "   🧠 Available Memory: $(free -h | grep Mem | awk '{print $7}')"
    echo -e "   💾 Swap: $(free -h | grep Swap | awk '{print $3 "/" $2}')"
    echo ""

    print_separator
    echo -e "${CYAN}💽 Storage Information:${NC}"
    echo -e "   💾 Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
    echo -e "   📁 Largest Directories:"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -5 | while read size dir; do
        echo -e "      📂 $dir: $size"
    done
    echo ""
}

# Disk Usage Command
cmd_disk_usage() {
    clear
    print_header "💽 Disk Usage Information"
    echo ""

    print_separator
    echo -e "${CYAN}📊 Disk Space Usage:${NC}"
    df -h | while read line; do
        if [[ $line == Filesystem* ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "   $line"
        fi
    done
    echo ""

    print_separator
    echo -e "${CYAN}📁 Inode Usage:${NC}"
    df -i | while read line; do
        if [[ $line == Filesystem* ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "   $line"
        fi
    done
    echo ""

    print_separator
    echo -e "${CYAN}📂 Largest Directories (Top 10):${NC}"
    echo -e "${YELLOW}   Size    Directory${NC}"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10 | nl -w2 -s'. ' | sed 's/^/   /'
    echo ""
}

# Memory Usage Command
cmd_memory_usage() {
    clear
    print_header "🧠 Memory Usage Information"
    echo ""

    print_separator
    echo -e "${CYAN}📊 Memory Overview:${NC}"
    free -h | while read line; do
        if [[ $line == total* ]]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo "   $line"
        fi
    done
    echo ""

    print_separator
    echo -e "${CYAN}⚡ Top Memory Processes (Top 8):${NC}"
    echo -e "${YELLOW}   %MEM    RSS    PID COMMAND${NC}"
    ps aux --sort=-%mem | head -8 | tail -7 | while read user pid cpu mem vsz rss tty stat start time command; do
        printf "   %5.1f %6s %5s %s\n" "$mem" "${rss}K" "$pid" "$(basename "$command")"
    done
    echo ""
}








# Show Help Command
cmd_show_help() {
    clear
    print_header "❓ Bashmenu Help & Documentation"
    echo ""

    print_separator
    echo -e "${CYAN}📋 Available Commands:${NC}"
    echo -e "   1.  🖥️  System Information - Show detailed system information"
    echo -e "   2.  💽 Disk Usage - Show disk space usage"
    echo -e "   3.  🚪 Exit - Exit the menu"
    echo ""

    #print_separator
    #echo -e "${CYAN}🔌 Plugin Commands:${NC}"
    #echo -e "   4.  🩺 System Health Check - Check overall system health"
    #echo -e "   5.  ⚡ System Benchmark - Run system performance tests"
    #echo -e "   6.  🔍 Process Analysis - Analyze running processes"
    #echo -e "   7.  🌐 Network Analysis - Analyze network configuration"
    #echo -e "   8.  🔒 Security Check - Basic security audit"
    #echo ""

    print_separator
    echo -e "${CYAN}⌨️  Keyboard Shortcuts:${NC}"
    echo -e "   • ${YELLOW}↑↓${NC} Arrow keys: Navigate menu options"
    echo -e "   • ${GREEN}Enter${NC}: Select highlighted option"
    echo -e "   • ${RED}q${NC}: Quick exit"
    echo -e "   • ${BLUE}h${NC}: Show help"
    echo -e "   • ${CYAN}r${NC}: Refresh menu"
    echo ""

    print_separator
    echo -e "${CYAN}💡 Navigation Tips:${NC}"
    echo -e "   • Use ${YELLOW}numbers (1-8)${NC} to quickly select options"
    echo -e "   • Use ${YELLOW}arrow keys${NC} for visual navigation"
    echo -e "   • Press ${RED}'q'${NC} to exit at any time"
    echo ""

    print_separator
    echo -e "${CYAN}🎨 Themes:${NC} default, dark, colorful, minimal, modern"
    echo -e "${CYAN}🔌 Plugins:${NC} System Tools plugin loaded"
    echo ""
}

# =============================================================================
# Utility Functions
# =============================================================================

# Get user level for permissions
get_user_level() {
    if [[ "$(whoami)" == "root" ]]; then
        echo "3"
    elif [[ "$(whoami)" == "admin" ]]; then
        echo "2"
    else
        echo "1"
    fi
}

# Load plugins
load_plugins() {
    if [[ "${ENABLE_PLUGINS:-true}" == "true" && -d "${PLUGIN_DIR:-plugins}" ]]; then
        for plugin in "${PLUGIN_DIR:-plugins}"/*.sh; do
            if [[ -f "$plugin" ]]; then
                source "$plugin"
                log_info "Plugin loaded: $(basename "$plugin")"
            fi
        done
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    if [[ "${AUTO_BACKUP:-true}" == "true" && -d "${BACKUP_DIR:-$HOME/.bashmenu/backups}" ]]; then
        local retention_days="${BACKUP_RETENTION_DAYS:-7}"
        find "${BACKUP_DIR:-$HOME/.bashmenu/backups}" -type f -mtime +$retention_days -delete 2>/dev/null
        log_info "Cleaned up backups older than $retention_days days"
    fi
}

# =============================================================================
# Export Functions
# =============================================================================

export -f cmd_system_info
export -f cmd_disk_usage
export -f cmd_memory_usage
export -f cmd_show_help
export -f get_user_level
export -f load_plugins
export -f cleanup_old_backups
# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Bold colors
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'

# Export colors for global use
export RED GREEN YELLOW BLUE PURPLE CYAN WHITE NC
export BOLD_RED BOLD_GREEN BOLD_YELLOW BOLD_BLUE 

# Logging functions (fallback - will be overridden by logger.sh if loaded)
log_warn() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[WARN] $*" >&2
    return 0
}
log_info() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[INFO] $*" >&2
    return 0
}
log_error() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[ERROR] $*" >&2
    return 0
}
log_debug() { 
    [[ "${DEBUG_MODE:-false}" == "true" ]] && echo -e "[DEBUG] $*" >&2
    return 0
}

# =============================================================================
# Utility Functions
# =============================================================================

# Print functions with enhanced colors and icons
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    local title="$1"
    local width=50
    local title_length=${#title}
    local padding=$(( (width - title_length) / 2 ))
    local padding_right=$(( width - title_length - padding ))

    # Check if colors are enabled
    if [[ "${ENABLE_COLORS:-true}" == "true" ]]; then
        echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
        printf "${CYAN}%${padding}s%s%${padding_right}s${NC}\n" "" "$title" ""
        echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
    else
        # Minimal version without colors
        echo "--------------------------------------------------"
        printf "%${padding}s%s%${padding_right}s\n" "" "$title" ""
        echo "--------------------------------------------------"
    fi
}

print_separator() {
    if [[ "${ENABLE_COLORS:-true}" == "true" ]]; then
        echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
    else
        echo "--------------------------------------------------"
    fi
}

print_separator_end() {
    if [[ "${ENABLE_COLORS:-true}" == "true" ]]; then
        echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
    else
        echo "--------------------------------------------------"
    fi
}

# Progress bar for visual feedback
show_progress() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] %d%%" $percentage
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Simple spinner for operations with anti-flickering
show_spinner() {
    local pid=$1
    local message="${2:-Processing}"
    local delay="${SPINNER_DELAY:-0.1}"
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    # Hide cursor to prevent flickering
    tput civis 2>/dev/null
    
    # Save cursor position
    tput sc 2>/dev/null
    
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        # Use \r to return to start of line without clearing
        printf "\r%s %c " "$message" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    
    # Check exit status of the process
    wait $pid 2>/dev/null
    local exit_code=$?
    
    # Clear the line and print final status
    printf "\r\033[K"  # Clear to end of line
    if [[ $exit_code -eq 0 ]]; then
        printf "%s ${GREEN}✓${NC}\n" "$message"
    else
        printf "%s ${RED}✗${NC}\n" "$message"
    fi
    
    # Show cursor
    tput cnorm 2>/dev/null
    
    return $exit_code
}

# Execute command with spinner
with_spinner() {
    local message="$1"
    shift
    local command="$@"
    
    # Execute command in background
    eval "$command" > /dev/null 2>&1 &
    local pid=$!
    
    # Show spinner while command runs
    show_spinner $pid "$message"
    
    return $?
}

# Show a simple bar (for dashboard)
show_bar() {
    local value=$1
    local max=$2
    local width=30
    local filled=$((value * width / max))
    
    # Color based on value
    local color="${GREEN}"
    if [[ $value -gt 80 ]]; then
        color="${RED}"
    elif [[ $value -gt 60 ]]; then
        color="${YELLOW}"
    fi
    
    printf "${color}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%$((width - filled))s" | tr ' ' '░'
    printf "]${NC} %d%%\n" "$value"
}

# Confirmation prompt
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        read -p "$message [Y/n]: " response
        response=${response:-y}
    else
        read -p "$message [y/N]: " response
        response=${response:-n}
    fi
    
    [[ "$response" =~ ^[Yy]$ ]]
}

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

# =============================================================================
# Export Functions
# =============================================================================

export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_header
export -f print_separator
export -f print_separator_end
export -f show_progress
export -f show_spinner
export -f with_spinner
export -f show_bar
export -f confirm
export -f get_user_level 
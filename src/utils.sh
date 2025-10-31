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

# Logging functions
log_warn() { echo -e "[WARN] $*" >&2; }
log_info() { echo -e "[INFO] $*" >&2; }
log_error() { echo -e "[ERROR] $*" >&2; }
log_debug() { echo -e "[DEBUG] $*" >&2; }

# =============================================================================
# Utility Functions
# =============================================================================

# Print functions with colors
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
# Export Functions
# =============================================================================

export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_header 
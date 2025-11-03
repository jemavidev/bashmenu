#!/bin/bash
# Git Operations Script - Manage Git repositories
# Usage: ./git_operations.sh [pull|status|log|branch]

# =============================================================================
# Configuration
# =============================================================================

# Default repository path (can be overridden by parameter)
DEFAULT_REPO_PATH="/opt/myapp"

# Function to get repository path
get_repo_path() {
    local provided_path="$1"
    
    # If path provided as parameter, use it
    if [[ -n "$provided_path" ]]; then
        echo "$provided_path"
        return 0
    fi
    
    # If default path exists, use it
    if [[ -d "$DEFAULT_REPO_PATH" ]]; then
        echo "$DEFAULT_REPO_PATH"
        return 0
    fi
    
    # Ask user for repository path
    echo "Repository path not found: $DEFAULT_REPO_PATH" >&2
    echo "" >&2
    echo "Please enter the full path to your git repository:" >&2
    echo -n "> " >&2
    read repo_path
    
    if [[ -z "$repo_path" ]]; then
        echo "Error: No repository path provided" >&2
        exit 1
    fi
    
    echo "$repo_path"
    return 0
}

# =============================================================================
# Functions
# =============================================================================

show_usage() {
    echo "Git Operations Script"
    echo ""
    echo "Usage: $0 [operation] [repo_path]"
    echo ""
    echo "Operations:"
    echo "  pull      - Pull latest changes from remote"
    echo "  status    - Show repository status"
    echo "  log       - Show recent commits"
    echo "  branch    - Show current branch and available branches"
    echo ""
    echo "Examples:"
    echo "  $0 pull"
    echo "  $0 status /path/to/repo"
    echo "  $0 log"
    echo ""
}

check_git_installed() {
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is not installed"
        echo "Install with: sudo apt-get install git"
        exit 1
    fi
}

check_repo_exists() {
    local repo_path="$1"
    
    if [[ ! -d "$repo_path" ]]; then
        echo "Error: Directory does not exist: $repo_path"
        exit 1
    fi
    
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: Not a git repository: $repo_path"
        exit 1
    fi
}

git_pull() {
    local repo_path="$1"
    
    echo "═══════════════════════════════════════════════"
    echo "Git Pull - Fetching latest changes"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Repository: $repo_path"
    echo ""
    
    cd "$repo_path" || exit 1
    
    # Show current branch
    local current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    echo ""
    
    # Fetch and pull
    echo "Fetching from remote..."
    git fetch origin
    echo ""
    
    echo "Pulling changes..."
    if git pull origin "$current_branch"; then
        echo ""
        echo "✓ Pull completed successfully"
    else
        echo ""
        echo "✗ Pull failed"
        exit 1
    fi
}

git_status() {
    local repo_path="$1"
    
    echo "═══════════════════════════════════════════════"
    echo "Git Status - Repository information"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Repository: $repo_path"
    echo ""
    
    cd "$repo_path" || exit 1
    
    # Show current branch
    local current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    echo ""
    
    # Show status
    git status
    echo ""
    
    # Show remote info
    echo "Remote repository:"
    git remote -v
}

git_log() {
    local repo_path="$1"
    
    echo "═══════════════════════════════════════════════"
    echo "Git Log - Recent commits"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Repository: $repo_path"
    echo ""
    
    cd "$repo_path" || exit 1
    
    # Show current branch
    local current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    echo ""
    
    # Show last 10 commits
    echo "Last 10 commits:"
    echo ""
    git log --oneline --decorate --graph -10
}

git_branch() {
    local repo_path="$1"
    
    echo "═══════════════════════════════════════════════"
    echo "Git Branch - Branch information"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Repository: $repo_path"
    echo ""
    
    cd "$repo_path" || exit 1
    
    # Show current branch
    local current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    echo ""
    
    # Show all branches
    echo "Local branches:"
    git branch -v
    echo ""
    
    echo "Remote branches:"
    git branch -r
}

# =============================================================================
# Main
# =============================================================================

main() {
    local operation="${1:-status}"
    local repo_path_param="${2:-}"
    
    # Check if git is installed
    check_git_installed
    
    # Get repository path (will ask user if needed)
    local repo_path=$(get_repo_path "$repo_path_param")
    
    # Check if repository exists
    check_repo_exists "$repo_path"
    
    # Execute operation
    case "$operation" in
        pull)
            git_pull "$repo_path"
            ;;
        status)
            git_status "$repo_path"
            ;;
        log)
            git_log "$repo_path"
            ;;
        branch)
            git_branch "$repo_path"
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown operation: $operation"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

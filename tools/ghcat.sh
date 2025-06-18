#!/bin/bash

# ghcat - A robust tool to fetch GitHub file contents directly
# Usage: ghcat [OPTIONS] REPO_PATH FILE_PATH [BRANCH]
# Dependencies: gh (GitHub CLI), curl, jq, base64

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v gh >/dev/null 2>&1 || missing_deps+=("gh")
    command -v curl >/dev/null 2>&1 || missing_deps+=("curl")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v base64 >/dev/null 2>&1 || missing_deps+=("base64")
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_error "Please install them before running this script."
        exit 1
    fi
}

display_help() {
    cat << EOF
ghcat - A robust tool to fetch GitHub file contents directly

USAGE:
    ghcat [OPTIONS] REPO_PATH FILE_PATH [BRANCH]

ARGUMENTS:
    REPO_PATH     Repository in format 'owner/repo' (e.g., 'microsoft/vscode')
    FILE_PATH     Path to file within the repository (e.g., 'README.md', 'src/main.py')
    BRANCH        Optional branch name (defaults to repository's default branch)

OPTIONS:
    -h, --help      Display this help message and exit
    -r, --raw       Use raw GitHub URL (faster but doesn't work for private repos)
    -v, --verbose   Enable verbose output for debugging
    -o, --output    Save output to file instead of stdout
    --validate      Validate repository exists before fetching

EXAMPLES:
    ghcat microsoft/vscode README.md
    ghcat tensorflow/tensorflow CHANGELOG.md main
    ghcat -r kubernetes/kubernetes README.md
    ghcat --verbose --output temp.txt owner/repo src/file.js
    ghcat --validate owner/repo package.json

DEPENDENCIES:
    - gh (GitHub CLI) - for authentication and API access
    - curl - for HTTP requests
    - jq - for JSON parsing
    - base64 - for content decoding

NOTES:
    - Raw mode (-r) is faster but only works with public repositories
    - Private repositories require GitHub CLI authentication (gh auth login)
    - Large files are automatically handled via download URLs
EOF
}

# Validate repository format
validate_repo_format() {
    local repo="$1"
    if [[ ! "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]; then
        log_error "Invalid repository format: '$repo'"
        log_error "Expected format: 'owner/repo'"
        exit 1
    fi
}

# Validate repository exists
validate_repo_exists() {
    local repo="$1"
    log_info "Validating repository: $repo"
    
    if ! gh api "repos/$repo" >/dev/null 2>&1; then
        log_error "Repository '$repo' not found or not accessible"
        log_error "Make sure the repository exists and you have access to it"
        exit 1
    fi
    
    log_info "Repository validated successfully"
}

# Get default branch
get_default_branch() {
    local repo="$1"
    local branch
    
    if ! branch=$(gh api "repos/$repo" --jq '.default_branch' 2>/dev/null); then
        log_error "Failed to get default branch for repository: $repo"
        exit 1
    fi
    
    echo "$branch"
}

# Fetch via raw GitHub URL
fetch_raw() {
    local repo="$1"
    local file_path="$2"
    local branch="$3"
    
    if [ -z "$branch" ]; then
        branch=$(get_default_branch "$repo")
        log_info "Using default branch: $branch"
    fi
    
    local raw_url="https://raw.githubusercontent.com/$repo/$branch/$file_path"
    log_info "Fetching via raw URL: $raw_url"
    
    local http_code
    if ! http_code=$(curl -s -o /dev/null -w "%{http_code}" "$raw_url"); then
        log_error "Failed to check raw URL accessibility"
        return 1
    fi
    
    if [ "$http_code" = "200" ]; then
        curl -s "$raw_url" || {
            log_error "Failed to fetch content from raw URL"
            return 1
        }
        return 0
    else
        log_warn "Raw URL not accessible (HTTP $http_code), falling back to API method"
        return 1
    fi
}

# Fetch via GitHub API
fetch_api() {
    local repo="$1"
    local file_path="$2"
    local branch="$3"
    
    log_info "Fetching via GitHub API"
    
    local api_url="repos/$repo/contents/$file_path"
    if [ -n "$branch" ]; then
        api_url="$api_url?ref=$branch"
    fi
    
    local api_response
    if ! api_response=$(gh api "$api_url" 2>/dev/null); then
        log_error "Failed to fetch file from GitHub API"
        log_error "File: $file_path"
        [ -n "$branch" ] && log_error "Branch: $branch"
        exit 1
    fi
    
    # Check if file is too large (API returns download_url instead of content)
    local download_url
    download_url=$(echo "$api_response" | jq -r '.download_url // empty')
    
    if [ -n "$download_url" ]; then
        log_info "File is large, using download URL"
        if ! curl -s "$download_url"; then
            log_error "Failed to download large file"
            exit 1
        fi
    else
        # Extract and decode base64 content
        if ! echo "$api_response" | jq -r '.content' | base64 --decode; then
            log_error "Failed to decode file content"
            exit 1
        fi
    fi
}

# Main function
main() {
    # Check dependencies first
    check_dependencies
    
    # Default options
    local use_raw=0
    local verbose=0
    local output_file=""
    local validate_repo=0
    
    # Process options
    while [[ $# -gt 0 && "$1" =~ ^- ]]; do
        case "$1" in
            -h|--help)
                display_help
                exit 0
                ;;
            -r|--raw)
                use_raw=1
                shift
                ;;
            -v|--verbose)
                verbose=1
                shift
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            --validate)
                validate_repo=1
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                display_help
                exit 1
                ;;
        esac
    done
    
    # Check required arguments
    if [ $# -lt 2 ]; then
        log_error "Missing required arguments"
        display_help
        exit 1
    fi
    
    local repo="$1"
    local file_path="$2"
    local branch="${3:-}"
    
    # Enable verbose logging if requested
    if [ $verbose -eq 0 ]; then
        # Redirect info/warn logs to /dev/null in non-verbose mode
        exec 3>&2
        exec 2>/dev/null
        log_info() { :; }
        log_warn() { :; }
        log_error() { echo -e "${RED}[ERROR]${NC} $1" >&3; }
    fi
    
    # Validate inputs
    validate_repo_format "$repo"
    
    if [ $validate_repo -eq 1 ]; then
        validate_repo_exists "$repo"
    fi
    
    # Fetch content
    local content=""
    if [ $use_raw -eq 1 ]; then
        if content=$(fetch_raw "$repo" "$file_path" "$branch"); then
            log_info "Successfully fetched via raw URL"
        else
            content=$(fetch_api "$repo" "$file_path" "$branch")
            log_info "Successfully fetched via API"
        fi
    else
        content=$(fetch_api "$repo" "$file_path" "$branch")
        log_info "Successfully fetched via API"
    fi
    
    # Output content
    if [ -n "$output_file" ]; then
        echo "$content" > "$output_file"
        log_info "Content saved to: $output_file"
    else
        echo "$content"
    fi
}

# Run main function with all arguments
main "$@"

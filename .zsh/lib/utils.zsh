# =====
# Shell Utilities
# =====
# Generic, dependency-free helpers used by other shell libraries and functions.

# ===== Output =====

function print_success() {
  gum style --foreground 2 "✓ $*"
}

function print_error() {
  gum style --foreground 1 "✗ $*"
}

function print_info() {
  gum style --foreground 4 "• $*"
}

function print_warning() {
  gum style --foreground 3 "⚠ $*"
}

# ===== Validation =====

function in_git_repo() {
  git rev-parse --git-dir > /dev/null 2>&1
}

function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

function directory_exists() {
  [[ -d "$1" ]]
}

function file_readable() {
  [[ -f "$1" && -r "$1" ]]
}

# ===== Git =====

function git_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

# Returns the path of the main (first) worktree for this repo.
# Works correctly whether called from the main worktree or any linked worktree.
function git_main_worktree() {
  git worktree list --porcelain | head -1 | sed 's/^worktree //'
}

# Derives a stable project name from the main worktree, not the current directory.
function git_project_name() {
  basename "$(git_main_worktree)"
}

function git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Get files changed relative to a branch or tag, optionally matching a pattern.
# Usage: git_changed_files <base_ref> [pattern]
# Example: git_changed_files main '*.py'
function git_changed_files() {
  if [[ -z "$1" ]]; then
    print_error "Usage: git_changed_files <base_ref> [pattern]"
    return 1
  fi

  local base_ref="$1"
  local pattern="${2:-}"

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local merge_base
  merge_base=$(git merge-base HEAD "$base_ref" 2>/dev/null)

  if [[ -z "$merge_base" ]]; then
    print_error "Could not find merge base with $base_ref"
    return 1
  fi

  if [[ -n "$pattern" ]]; then
    git diff --name-only "$merge_base" HEAD -- "$pattern"
  else
    git diff --name-only "$merge_base" HEAD
  fi
}

# ===== Array Utilities =====

function is_empty_array() {
  [[ ${#@} -eq 0 ]]
}

function array_contains() {
  local search="$1"
  shift
  local item
  for item in "$@"; do
    [[ "$item" == "$search" ]] && return 0
  done
  return 1
}

function array_join() {
  local IFS="$1"
  shift
  echo "$*"
}

function array_unique() {
  local arr=("$@")
  print -l ${(u)arr}
}

# =====
# ZSH Options
# =====
setopt SHARE_HISTORY
setopt rcexpandparam       # Array expension with parameters
setopt nocheckjobs         # Don't warn about running processes when exiting
setopt numericglobsort     # Sort filenames numerically when it makes sense
setopt nobeep              # No beep
setopt incappendhistory    # Immediately append history instead of overwriting

# =====
# Completion Options
# =====

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"                           # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                                                # automatically find new executables in path

# =====
# Key Bindings
# =====

bindkey '^[[3~'   delete-char                          # Delete key
bindkey '^[[C'    forward-char                         # Right key
bindkey '^[[D'    backward-char                        # Left key
bindkey '^[[5~'   history-beginning-search-backward    # Page up key
bindkey '^[Oc'    forward-word                         # ctrl right
bindkey '^[Od'    backward-word                        # ctrl left
bindkey '^[[1;5D' backward-word                        # ctrl left
bindkey '^[[1;5C' forward-word                         # ctrl right
bindkey '^H'      backward-kill-word                   # delete previous word with ctrl+backspace
bindkey '^[[Z'    undo                                 # Shift+tab undo last action

# =====
# Colors
# =====

autoload -U compinit colors zcalc
compinit -d
colors

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

# =====
# Plugins
# =====

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# =====
# Env Vars
# =====

export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/src/zide/bin:$HOME/libs/flutter_sdk/bin:$PATH"
export SSLKEYLOGFILE="$HOME/.ssl-key.log"
export TERM=xterm-256color
export GIT_EDITOR=hx
export VISUAL=hx
export EDITOR=$VISUAL
export SUDO_EDITOR=$VISUAL
export AZ_AUTO_LOGIN_TYPE="DEVICE"

export XPAUTH_PATH="$HOME/src/smartbidder/xpauth_dev.xpr"
export XPRESS="$HOME/src/smartbidder/xpauth_dev.xpr"

# =====
# Tool Configuration
# =====

eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"


# =====
# Aliases
# =====

alias ls="eza"
alias cat="bat"
alias tree="ls --tree --color always | cat"
alias rm="rm -I"
alias cp="cp -i"
alias mv="mv -i"
alias sbid="cdp smartbidder"
alias wt="worktree"

# =====
# Functions
# =====

# --- Output ---

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

# --- Validation ---

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

# --- Git ---

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

# --- Array Utilities ---

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
  # Use zsh's built-in unique flag
  echo "${(@u)@}"
}

# Get files changed relative to a branch or tag, optionally matching a pattern
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

  # Get the merge base to compare against
  local merge_base
  merge_base=$(git merge-base HEAD "$base_ref" 2>/dev/null)

  if [[ -z "$merge_base" ]]; then
    print_error "Could not find merge base with $base_ref"
    return 1
  fi

  # Get changed files, optionally filtering by pattern
  if [[ -n "$pattern" ]]; then
    git diff --name-only "$merge_base" HEAD -- "$pattern"
  else
    git diff --name-only "$merge_base" HEAD
  fi
}

function most-recent-tag {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  print_info "Fetching tags..."
  if ! git fetch --tags 2>/dev/null; then
    print_error "Failed to fetch tags"
    return 1
  fi

  local tags=$(git describe --tags $(git rev-list --tags --max-count=5) 2>/dev/null)

  if [[ -z "$tags" ]]; then
    print_warning "No tags found in repository"
    return 0
  fi

  echo "$tags"
}

function search {
  # Check required commands
  local required_cmds=(rg fzf bat hx)
  for cmd in $required_cmds; do
    if ! command_exists $cmd; then
      print_error "Required command not found: $cmd"
      return 1
    fi
  done

  rm -f /tmp/rg-fzf-{r,f}
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  INITIAL_QUERY="${*:-}"
  FZF_DEFAULT_COMMAND="$RG_PREFIX $(printf %q "$INITIAL_QUERY")" \
  fzf --ansi \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --disabled --query "$INITIAL_QUERY" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(2. fzf> )+enable-search+rebind(ctrl-r)+transform-query(echo {q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f)" \
    --bind "ctrl-r:unbind(ctrl-r)+change-prompt(1. ripgrep> )+disable-search+reload($RG_PREFIX {q} || true)+rebind(change,ctrl-f)+transform-query(echo {q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r)" \
    --bind "start:unbind(ctrl-r)" \
    --prompt '1. ripgrep> ' \
    --delimiter : \
    --header '╱ CTRL-R (ripgrep mode) ╱ CTRL-F (fzf mode) ╱' \
      --bind='tab:toggle-preview' \
      --preview 'bat --color=always {1}' \
      --preview-window 'right,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(hx {1}:{2})'
}

function review() {
  if [[ -z "$1" ]]; then
    print_error "Usage: review <branch> [base_branch]"
    return 1
  fi

  local branch="$1"
  local base_branch="${2:-main}"

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  # Validate branch exists
  if ! git rev-parse --verify "$branch" &>/dev/null; then
    print_error "Branch '$branch' does not exist"
    return 1
  fi

  print_info "Fetching latest changes..."
  if ! git fetch --all --quiet; then
    print_error "Failed to fetch changes"
    return 1
  fi

  print_info "Checking out branch: $branch"
  if ! git checkout "$branch"; then
    print_error "Failed to checkout branch: $branch"
    return 1
  fi

  # Get changed files using utility
  local changed_files=("${(@f)$(git_changed_files "$base_branch")}")

  if is_empty_array "${changed_files[@]}"; then
    print_warning "No files changed compared to $base_branch"
    git checkout -
    return 0
  fi

  print_success "Found ${#changed_files[@]} changed file(s)"

  # Run pre-commit if available
  if command_exists pre-commit; then
    print_info "Running pre-commit hooks..."
    if ! pre-commit run --from-ref "origin/${base_branch}" --to-ref HEAD; then
      print_warning "Pre-commit checks failed (non-fatal)"
    fi
  else
    print_warning "pre-commit not installed, skipping hooks"
  fi

  # Run tests if pants is available
  if command_exists pants; then
    print_info "Running tests with pants..."
    if ! pants test compatible-tests; then
      print_warning "Tests failed (non-fatal)"
    fi
  else
    print_info "pants not installed, skipping tests"
  fi

  # Check with pyrefly if available
  if command_exists pyrefly; then
    print_info "Running pyrefly checks..."
    local py_files=("${(@f)$(git_changed_files "$base_branch" "*.py")}")
    if ! is_empty_array "${py_files[@]}"; then
      if ! pyrefly check "${py_files[@]}"; then
        print_warning "Pyrefly checks failed (non-fatal)"
      fi
    fi
  else
    print_info "pyrefly not installed, skipping type checks"
  fi

  print_success "All automated checks complete"
  read -sk '?Press any key to view files...'
  echo  # New line after keypress

  "$EDITOR" "${changed_files[@]}"

  print_info "Returning to previous branch..."
  git checkout -
}

function ruff-fix() {
  if [[ -z "$1" ]]; then
    print_error "Usage: ruff-fix <fix_code1,fix_code2,...> [base_branch]"
    return 1
  fi

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  if ! command_exists ruff; then
    print_error "ruff is not installed"
    return 1
  fi

  local fix_codes="$1"
  local base_ref="${2:-main}"  # Allow override of base branch

  # Use the git_changed_files utility
  local files=("${(@f)$(git_changed_files "$base_ref" '*.py')}")

  if is_empty_array "${files[@]}"; then
    print_warning "No Python files changed compared to $base_ref"
    return 0
  fi

  print_info "Running ruff on ${#files[@]} file(s) with codes: $fix_codes"
  ruff check --fix --select "$fix_codes" "${files[@]}"
}

function dot-run() {
  if [[ -z "$1" ]]; then
    print_error "Usage: dot-run <env_file> <command> [args...]"
    return 1
  fi

  local env_file="$1"

  if [[ -z "${@[2,-1]}" ]]; then
    print_error "No command specified"
    print_info "Usage: dot-run <env_file> <command> [args...]"
    return 1
  fi

  if ! file_readable "$env_file"; then
    print_error "Cannot read file: $env_file"
    return 1
  fi

  env $(grep -v '^#' "$env_file" | xargs -d '\n') ${@[2,-1]}
}


function timed-file() {
  if [[ -z "$1" ]]; then
    print_error "Usage: timed-file <filename>"
    return 1
  fi

  if ! command_exists fuzzydate; then
    print_error "fuzzydate is not installed"
    return 1
  fi

  local ts
  ts="$(fuzzydate now "%y%m%dT%H%M%S")"

  if [[ -z "$ts" ]]; then
    print_error "Failed to generate timestamp"
    return 1
  fi

  echo "${ts}-${1}"
}

function git-fix() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local root_dir
  root_dir="$(git_root)"

  # Get files with conflicts (relative paths)
  local files=("${(@f)$(git diff --name-only --diff-filter=U)}")

  if is_empty_array "${files[@]}"; then
    print_warning "No files with conflicts found"
    return 0
  fi

  # Convert to absolute paths
  local abs_files=()
  local file
  for file in "${files[@]}"; do
    abs_files+=("${root_dir}/${file}")
  done

  print_info "Opening ${#abs_files[@]} file(s) with conflicts"
  "$EDITOR" "${abs_files[@]}"
}

function git-create-patch() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local base_ref="${1:-main}"
  local patch_file="${2:-$(timed-file "patch.diff")}"

  print_info "Creating patch against: $base_ref"

  if ! git diff "$base_ref" HEAD > "$patch_file"; then
    print_error "Failed to create patch"
    return 1
  fi

  if [[ ! -s "$patch_file" ]]; then
    print_warning "No changes to create patch (empty diff)"
    rm "$patch_file"
    return 0
  fi

  print_success "Patch created: $patch_file"
  print_info "Lines in patch: $(wc -l < "$patch_file")"
}

function git-apply-patch() {
  if [[ -z "$1" ]]; then
    print_error "Usage: git-apply-patch <patch_file> [--check]"
    return 1
  fi

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local patch_file="$1"
  local check_flag="$2"

  if ! file_readable "$patch_file"; then
    print_error "Cannot read patch file: $patch_file"
    return 1
  fi

  # Check mode - see if patch applies without changing files
  if [[ "$check_flag" == "--check" ]]; then
    print_info "Checking if patch applies cleanly..."
    if git apply --check "$patch_file" 2>&1; then
      print_success "Patch can be applied cleanly"
      return 0
    else
      print_error "Patch cannot be applied cleanly"
      return 1
    fi
  fi

  print_info "Applying patch: $patch_file"

  if git apply "$patch_file"; then
    print_success "Patch applied successfully"
  else
    print_error "Failed to apply patch"
    print_info "Try: git-apply-patch $patch_file --check"
    return 1
  fi
}

function cdr() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local root
  root="$(git_root)"

  cd "$root" || return 1
}

function zource {
  source ~/.zshrc
}

function zshrc() {
  "$EDITOR" "$HOME/.zshrc"
  zource
}

# --- Git Worktree Management ---
# Usage: worktree [list|create|switch|remove] [args...]
# If no subcommand is given, defaults to `switch`.
# Each subcommand prompts interactively (via gum) when args are omitted.

# List branch names from existing worktrees (one per line).
# Pass --exclude-main to omit the main worktree's branch.
function _worktree_branches() {
  local exclude_main=false
  [[ "$1" == "--exclude-main" ]] && exclude_main=true

  local main_path=""
  [[ "$exclude_main" == true ]] && main_path="$(git_main_worktree)"

  git worktree list --porcelain | awk \
    -v exclude_main="$exclude_main" \
    -v main_path="$main_path" '
    /^worktree / { path = substr($0, 10) }
    /^branch /   {
      if (exclude_main == "true" && path == main_path) next
      branch = substr($0, 8)
      sub(/^refs\/heads\//, "", branch)
      print branch
    }
  '
}

# Resolve a branch name to its worktree path (empty if none).
function _worktree_path_for_branch() {
  git worktree list --porcelain | awk -v branch="refs/heads/$1" '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { if (substr($0, 8) == branch) print path }
  '
}

function _worktree_switch() {
  local branch="$1"

  if [[ -z "$branch" ]]; then
    local branches
    branches="$(_worktree_branches)"
    if [[ -z "$branches" ]]; then
      print_warning "No worktrees found. Use 'worktree create' to make one."
      return 0
    fi
    branch=$(echo "$branches" | gum choose --select-if-one --header "Switch to worktree")
    [[ -z "$branch" ]] && return 1
  fi

  local target_path
  target_path="$(_worktree_path_for_branch "$branch")"

  if [[ -z "$target_path" ]]; then
    print_error "No worktree found for branch: $branch"
    print_info "Use 'worktree create $branch' to create one"
    return 1
  fi

  cd "$target_path" || return 1
  print_success "Switched to worktree: $branch ($target_path)"
}

function _worktree_list() {
  local project_name
  project_name="$(git_project_name)"

  print_info "Worktrees for project: $project_name"
  echo

  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10) }
    /^branch /   {
      branch = substr($0, 8)
      sub(/^refs\/heads\//, "", branch)
      print path " ▸ " branch
    }
  '

  echo
  local count=$(git worktree list | wc -l)
  print_info "Total worktrees: $count"
}

function _worktree_create() {
  local branch="$1"
  local base_branch="${2:-}"

  local project_name
  project_name="$(git_project_name)"

  if [[ -z "$branch" ]]; then
    branch=$(gum input --placeholder "feature/my-branch" --header "Branch name for new worktree")
    [[ -z "$branch" ]] && { print_error "Branch name is required"; return 1; }
  fi

  # Check if worktree already exists for this branch
  local existing
  existing="$(_worktree_path_for_branch "$branch")"
  if [[ -n "$existing" ]]; then
    print_warning "Worktree already exists for branch: $branch"
    print_info "Path: $existing"
    print_info "Use 'worktree switch $branch' to switch to it"
    return 1
  fi

  if [[ -z "$base_branch" ]]; then
    base_branch=$(gum input --value "main" --header "Base branch")
    [[ -z "$base_branch" ]] && { print_error "Base branch is required"; return 1; }
  fi

  local worktree_dir="${branch//\//-}"
  local worktree_path="$HOME/worktrees/${project_name}/${worktree_dir}"

  mkdir -p "$HOME/worktrees/${project_name}"

  local branch_exists=false
  git show-ref --verify --quiet "refs/heads/$branch" && branch_exists=true

  if $branch_exists; then
    print_info "Branch exists locally: $branch"
    gum spin --spinner dot --title "Creating worktree from existing branch..." -- \
      git worktree add "$worktree_path" "$branch"
  else
    print_info "Creating new branch from: $base_branch"
    gum spin --spinner dot --title "Creating worktree with new branch..." -- \
      git worktree add -b "$branch" "$worktree_path" "$base_branch"
  fi

  if [[ $? -ne 0 ]]; then
    print_error "Failed to create worktree"
    return 1
  fi

  print_success "Worktree created: $worktree_path"
  cd "$worktree_path" || return 1
}

function _worktree_remove() {
  local target="$1"
  local main_worktree
  main_worktree="$(git_main_worktree)"

  if [[ -z "$target" ]]; then
    local branches
    branches="$(_worktree_branches --exclude-main)"
    if [[ -z "$branches" ]]; then
      print_warning "No worktrees to remove"
      return 0
    fi
    target=$(echo "$branches" | gum choose --select-if-one --header "Remove worktree")
    [[ -z "$target" ]] && return 0
  fi

  # Resolve to path (accepts either a branch name or a path)
  local target_path
  target_path="$(_worktree_path_for_branch "$target")"
  [[ -z "$target_path" ]] && target_path="$target"

  if [[ "$target_path" == "$main_worktree" ]]; then
    print_error "Cannot remove the main worktree"
    return 1
  fi

  if ! git worktree list | grep -q "$target_path"; then
    print_error "Worktree not found: $target_path"
    return 1
  fi

  gum confirm "Remove worktree: $target_path?" || {
    print_info "Cancelled"
    return 0
  }

  print_info "Removing worktree: $(basename "$target_path")"
  gum spin --spinner dot --title "Removing worktree..." -- \
    git worktree remove "$target_path" --force

  if [[ $? -eq 0 ]]; then
    print_success "Worktree removed: $(basename "$target_path")"
  else
    print_error "Failed to remove worktree"
    return 1
  fi
}

# TODO: use flags rather than subcommands so I can do wt -s rather than worktree switch
function worktree() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local subcmd="${1:-}"

  case "$subcmd" in
    list|create|switch|remove)
      shift
      ;;
    *)
    echo "Supported subcommands are list, create, switch, and remove"
    exit 1
    ;;
  esac

  "_worktree_${subcmd}" "$@"
}

function sb-worktree-init() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  pants init

  local worktree_path="$(pwd)"
  local azure_feed_url="https://VssSessionToken@pkgs.dev.azure.com/ascendanalytics/_packaging/AscendFeed_Battery%40Local/pypi/simple/"

  print_info "Initializing development environment..."

  # Generate pyrefly.toml
  cat > pyrefly.toml << 'PYREFLY_EOF'
project-includes = [
    "**/*.py*",
    "**/*.ipynb",
]

search-path = [
    'src/projects/python/job_schedules',
    'src/projects/python/api',
    'src/projects/python/data_api',
    'src/projects/python/storage_emulator',
    'src/projects/python/dev_cli',
    'src/projects/python/devops',
    'src/projects/python/pagerduty-summary',
    'src/libs/python/smartbidder_schemas',
    'src/libs/python/core_data',
    'src/libs/python/iso_data',
    'src/libs/python/azure',
    'src/libs/python/io',
    'src/libs/python/serialization',
    'src/libs/python/transformations',
]
PYREFLY_EOF
  print_success "Generated pyrefly.toml"

  # Helper: generate .mise.toml for a directory
  _sb_write_mise_toml() {
    cat > .mise.toml << 'MISE_EOF'
[tools]
python = "3.10"

[env]
_.python.venv = { path = ".venv" }
MISE_EOF

mise trust
  }

  # Helper: pick a pants-exported virtualenv directory, using gum when multiple
  # Python versions are present.
  # Usage: _sb_pick_venv <virtualenvs/resolve-name dir>
  # Prints the selected path to stdout; returns non-zero on failure.
  _sb_pick_venv() {
    local venv_base="$1"
    if [[ ! -d "$venv_base" ]]; then
      print_error "Virtualenv base not found: $venv_base"
      return 1
    fi

    local versions=( "${venv_base}"/*(/N) )
    local chosen
    printf '%s\n' "${versions[@]}" | gum choose --select-if-one --header "Select Python environment:"
  }

  print_info "Setting up root environment..."
  (
    cd "${worktree_path}" || return 1

    _sb_write_mise_toml
    print_success "Generated root .mise.toml"

    # Export pants environment to dist/
    pants export --resolve=global

    # link exported venv to expected venv path
    local global_venv
    global_venv=$(_sb_pick_venv "${worktree_path}/dist/export/python/virtualenvs/global") || return 1
    ln -s "${global_venv}" "${worktree_path}/.venv"

    source ${worktree_path}/.venv/bin/activate

    print_success "Root environment setup complete"
  )

  local api_dir="src/projects/python/api"
  print_info "Setting up api environment..."
  (
    # Export pants api environment from the worktree root (where pants.toml lives)
    cd "${worktree_path}" || return 1
    pants export --resolve=projects_api

    # link exported venv to expected venv path
    local api_venv
    api_venv=$(_sb_pick_venv "${worktree_path}/dist/export/python/virtualenvs/projects_api") || return 1
    ln -s "${api_venv}" "${worktree_path}/${api_dir}/.venv"

    # Switch to api dir to set up its .venv
    cd "${worktree_path}/${api_dir}" || return 1
    source .venv/bin/activate

    _sb_write_mise_toml
    print_success "Generated api .mise.toml"

    print_success "API environment setup complete"
  )

  local data_api_dir="src/projects/python/data_api"
  print_info "Setting up data_api environment..."
  (
    # Export pants api environment from the worktree root (where pants.toml lives)
    cd "${worktree_path}" || return 1
    pants export --resolve=projects_data_api

    # link exported venv to expected venv path
    local data_api_venv
    data_api_venv=$(_sb_pick_venv "${worktree_path}/dist/export/python/virtualenvs/projects_data_api") || return 1
    ln -s "${data_api_venv}" "${worktree_path}/${data_api_dir}/.venv"

    # Switch to api dir to set up its .venv
    cd "${worktree_path}/${data_api_dir}" || return 1
    source .venv/bin/activate

    _sb_write_mise_toml
    print_success "Generated data api .mise.toml"

    print_success "API environment setup complete"
  )

  print_success "Development environment initialized!"
  print_info "Worktree location: $worktree_path"
  print_info "Branch: $(git_current_branch)"
}

function cdp() {
  if [[ -z "$1" ]]; then
    print_error "Usage: cdp <project-name>"
    return 1
  fi

  local project="$1"
  local directory="$HOME/src/$project"

  if ! directory_exists $directory; then
    print_error "No such project: $directory"
    return 1
  fi

  cd "$directory" || return 1
}


function yaz() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function nid() {
  nanoid generate --alphabet 0123456789abcdefghijklmnopqrstuvwxyz
}

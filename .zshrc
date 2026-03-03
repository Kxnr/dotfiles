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
alias zed="WAYLAND_DISPLAY= zed"

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

# --- User Functions ---

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

function worktree() {
  local worktree_name="$1"
  local base_branch="${2:-main}"
  
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local main_worktree
  main_worktree="$(git_main_worktree)"
  local project_name="$(git_project_name)"
  
  if [[ -z "$worktree_name" ]]; then
    # List only branch names from existing worktrees for the picker
    worktree_name=$(git worktree list --porcelain | awk '
      /^branch / {
        branch = substr($0, 8);
        sub(/^refs\/heads\//, "", branch);
        print branch;
      }
    ' | gum choose --header "Select worktree branch")
    if [[ -z "$worktree_name" ]]; then
      print_error "Worktree name is required"
      return 1
    fi
  fi

  # Check if a worktree for this branch already exists (using git's own tracking)
  local existing_path
  existing_path="$(git worktree list --porcelain | awk -v branch="refs/heads/$worktree_name" '
    /^worktree / { path = substr($0, 10) }
    /^branch /   { if (substr($0, 8) == branch) print path }
  ')"

  if [[ -n "$existing_path" ]]; then
    print_info "Worktree already exists: $existing_path"
    cd "$existing_path" || return 1
    print_success "Switched to existing worktree"
    return 0
  fi

  # Sanitize worktree name for directory (replace / with -)
  local worktree_dir="${worktree_name//\//-}"
  local worktree_path="$HOME/worktrees/${project_name}/${worktree_dir}"

  # Create new worktree
  print_info "Creating new worktree: $worktree_name"
  
  # Ensure worktrees directory exists
  mkdir -p "$HOME/worktrees/${project_name}"
  
  # Check if branch already exists locally or remotely
  local branch_exists=false
  if git show-ref --verify --quiet "refs/heads/$worktree_name"; then
    branch_exists=true
    print_info "Branch exists locally: $worktree_name"
  fi

  # Create worktree (either checkout existing branch or create new one)
  if $branch_exists; then
    gum spin --spinner dot --title "Creating worktree from existing branch..." -- \
      git worktree add "$worktree_path" "$worktree_name"
    if [[ $? -ne 0 ]]; then
      print_error "Failed to create worktree from existing branch"
      return 1
    fi
  else
    print_info "Creating new branch from: $base_branch"
    gum spin --spinner dot --title "Creating worktree with new branch..." -- \
      git worktree add -b "$worktree_name" "$worktree_path" "$base_branch"
    if [[ $? -ne 0 ]]; then
      print_error "Failed to create worktree with new branch"
      return 1
    fi
  fi

  print_success "Worktree created: $worktree_path"
  cd "$worktree_path" || return 1
  
  print_info "Run 'sb-worktree-init' to set up the development environment"
}

function sb-worktree-init() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

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

  # Helper: generate uv.toml with Azure Artifacts keyring auth
  _sb_write_uv_toml() {
    cat > uv.toml << UV_EOF
keyring-provider = "subprocess"
index-strategy = "unsafe-best-match"

[[index]]
name = "ascend"
url = "${azure_feed_url}"

UV_EOF
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
    printf '%s\n' "${versions[@]}" | gum choose --header "Select Python environment:"
  }

  # Helper: install editable libs referenced in a pyproject.toml
  # Must be called from the directory containing the pyproject.toml and .venv
  _sb_install_editable_libs() {
    local selected_lines
    selected_lines=$(grep -oP '.*@ ((\{root:uri\}/)|(file:))\K.*(?=")' pyproject.toml 2>/dev/null)
    if [[ -n "$selected_lines" ]]; then
      print_info "Installing editable libs..."
      while IFS= read -r line; do
        uv pip install --no-deps -e "$line"
      done <<< "$selected_lines"
    fi
  }

  # Setup root environment
  print_info "Setting up root environment..."
  (
    cd "${worktree_path}" || return 1

    _sb_write_mise_toml
    print_success "Generated root .mise.toml"

    _sb_write_uv_toml
    print_success "Generated root uv.toml"

    # Export pants environment to dist/
    pants export --resolve=global

    # link exported venv to expected venv path
    local global_venv
    global_venv=$(_sb_pick_venv "${worktree_path}/dist/export/python/virtualenvs/global") || return 1
    ln -s "${global_venv}" "${worktree_path}/.venv"

    source ${worktree_path}/.venv/bin/activate

    # Install any editable libs referenced in pyproject.toml
    cd "${worktree_path}/src/projects/python/job_schedules"
    _sb_install_editable_libs

    print_success "Root environment setup complete"
  )

  # Setup api environment
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

    _sb_write_uv_toml
    print_success "Generated api uv.toml"


    # Install editable libs
    _sb_install_editable_libs

    print_success "API environment setup complete"
  )

  print_success "Development environment initialized!"
  print_info "Worktree location: $worktree_path"
  print_info "Branch: $(git_current_branch)"
}

function worktree-list() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local project_name
  project_name="$(git_project_name)"

  print_info "Worktrees for project: $project_name"
  echo

  # Get git worktree list with formatted output
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10); }
    /^branch / { branch = substr($0, 8); }
    /^$/ { 
      if (path && branch) {
        # Extract just the branch name without refs/heads/
        sub(/^refs\/heads\//, "", branch);
        print path " ▸ " branch;
      }
      path = ""; branch = ""; 
    }
  '

  echo
  
  # Count worktrees using git command
  local count=$(git worktree list | wc -l)
  print_info "Total worktrees: $count"
}

function worktree-remove() {
  local worktree_path="$1"
  
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local main_worktree
  main_worktree="$(git_main_worktree)"

  # If no worktree specified, let user choose
  if [[ -z "$worktree_path" ]]; then
    # Get list of worktrees (excluding main worktree)
    local worktree_list=$(git worktree list --porcelain | awk '
      /^worktree / { 
        path = substr($0, 10); 
        if (path != "'"$main_worktree"'") {
          paths[++n] = path;
        }
      }
      /^branch / { 
        branch = substr($0, 8);
        sub(/^refs\/heads\//, "", branch);
        branches[n] = branch;
      }
      END {
        for (i = 1; i <= n; i++) {
          print paths[i] " (" branches[i] ")";
        }
      }
    ')

    if [[ -z "$worktree_list" ]]; then
      print_warning "No worktrees found to remove"
      return 0
    fi

    local selected=$(echo "$worktree_list" | gum choose --header "Select worktree to remove")
    if [[ -z "$selected" ]]; then
      print_info "No worktree selected"
      return 0
    fi
    
    # Extract path from selection (remove branch info)
    worktree_path="${selected% (*}"
  elif [[ -z "$worktree_path" ]]; then
    print_error "Usage: worktree-remove <worktree_path>"
    print_info "Example: worktree-remove ~/worktrees/smartbidder/feature-my-feature"
    return 1
  fi

  # Verify worktree exists in git's list
  if ! git worktree list | grep -q "$worktree_path"; then
    print_error "Worktree not found: $worktree_path"
    return 1
  fi

  # Confirm removal
  gum confirm "Remove worktree: $worktree_path?" || {
    print_info "Cancelled"
    return 0
  }

  # Remove the worktree
  print_info "Removing worktree: $(basename "$worktree_path")"
  gum spin --spinner dot --title "Removing worktree..." -- \
    git worktree remove "$worktree_path" --force

  if [[ $? -eq 0 ]]; then
    print_success "Worktree removed: $(basename "$worktree_path")"
  else
    print_error "Failed to remove worktree"
    return 1
  fi
}


function cdp() {
  if [[ -z "$1" ]]; then
    print_error "Usage: cdr <project-name>"
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

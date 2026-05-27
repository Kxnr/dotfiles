# =====
# Project Management
# =====
# Depends on: ~/.zsh/lib/utils.zsh

source "${0:A:h}/utils.zsh"
# Commands: project register|unregister|list|cd|worktree|bookmark
# Aliases:  pj (project), wt (project worktree), bm (project bookmark)
#
# Storage:
#   ~/.config/zsh/projects          — name:path registry
#   ~/.config/zsh/bookmarks/<name>  — tag:relpath per project

_PROJECTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/projects"
_BOOKMARKS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/bookmarks"

function _projects_ensure_storage() {
  mkdir -p "$(dirname "$_PROJECTS_FILE")" "$_BOOKMARKS_DIR"
  [[ -f "$_PROJECTS_FILE" ]] || touch "$_PROJECTS_FILE"
}

# ===== Project helpers =====

function _projects_all() {
  [[ -f "$_PROJECTS_FILE" ]] && grep -v '^[[:space:]]*$' "$_PROJECTS_FILE"
}

function _projects_names() {
  _projects_all | cut -d: -f1
}

function _projects_path_for() {
  _projects_all | awk -F: -v n="$1" '$1 == n { print $2 }'
}

# ===== Project commands =====

function _project_register() {
  local name="$1"
  local path="${2:-$PWD}"
  path="${path:A}"

  if [[ ! -d "$path" ]]; then
    print_error "Path does not exist: $path"
    return 1
  fi

  _projects_ensure_storage

  if [[ -z "$name" ]]; then
    local default_name
    if in_git_repo; then
      default_name="$(git_project_name)"
    else
      default_name="$(basename "$path")"
    fi
    name=$(gum input --value "$default_name" --header "Project name")
    [[ -z "$name" ]] && { print_error "Name is required"; return 1; }
  fi

  local existing
  existing="$(_projects_path_for "$name")"
  if [[ -n "$existing" ]]; then
    print_warning "Project '$name' already registered at: $existing"
    gum confirm "Update to $path?" || { print_info "Cancelled"; return 0; }
    local tmp; tmp=$(mktemp)
    grep -v "^${name}:" "$_PROJECTS_FILE" > "$tmp" && mv "$tmp" "$_PROJECTS_FILE"
  fi

  echo "${name}:${path}" >> "$_PROJECTS_FILE"
  print_success "Registered '$name' -> $path"
}

function _project_unregister() {
  local name="$1"
  _projects_ensure_storage

  if [[ -z "$name" ]]; then
    local names; names="$(_projects_names)"
    [[ -z "$names" ]] && { print_warning "No projects registered"; return 0; }
    name=$(echo "$names" | gum choose --select-if-one --header "Unregister project")
    [[ -z "$name" ]] && return 0
  fi

  local existing; existing="$(_projects_path_for "$name")"
  if [[ -z "$existing" ]]; then
    print_error "Project not found: $name"
    return 1
  fi

  gum confirm "Unregister '$name' ($existing)?" || { print_info "Cancelled"; return 0; }
  local tmp; tmp=$(mktemp)
  grep -v "^${name}:" "$_PROJECTS_FILE" > "$tmp" && mv "$tmp" "$_PROJECTS_FILE"
  print_success "Unregistered '$name'"
}

function _project_list() {
  _projects_ensure_storage

  local projects; projects="$(_projects_all)"
  if [[ -z "$projects" ]]; then
    print_warning "No projects registered. Use 'project register' to add one."
    return 0
  fi

  print_info "Registered projects:"
  echo
  echo "$projects" | awk -F: '{ printf "  %-20s %s\n", $1, $2 }'
}

function _project_cd() {
  local name="$1"
  _projects_ensure_storage

  if [[ -z "$name" ]]; then
    local names; names="$(_projects_names)"
    [[ -z "$names" ]] && { print_warning "No projects registered. Use 'project register' to add one."; return 0; }
    name=$(echo "$names" | gum choose --select-if-one --header "Go to project")
    [[ -z "$name" ]] && return 0
  fi

  local path; path="$(_projects_path_for "$name")"
  if [[ -z "$path" ]]; then
    print_error "Project not found: $name"
    return 1
  fi

  if [[ ! -d "$path" ]]; then
    print_error "Path no longer exists: $path"
    print_info "Re-register with: project register $name <new-path>"
    return 1
  fi

  cd "$path" || return 1
  print_success "Switched to project: $name"
}

# ===== Bookmark helpers =====

function _bookmarks_file() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi
  echo "${_BOOKMARKS_DIR}/$(git_project_name)"
}

function _bookmarks_all() {
  local bfile; bfile="$(_bookmarks_file)" || return 1
  [[ -f "$bfile" ]] && grep -v '^[[:space:]]*$' "$bfile"
}

function _bookmark_relpath_for() {
  _bookmarks_all | awk -F: -v t="$1" '$1 == t { print $2 }'
}

# ===== Bookmark commands =====

function _project_bookmark_add() {
  local tag="$1"
  local relpath="$2"

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  if [[ -z "$relpath" ]]; then
    local repo_root; repo_root="$(git_root)"
    relpath="${PWD#${repo_root}/}"
    [[ "$relpath" == "$PWD" ]] && relpath="."
  fi

  if [[ -z "$tag" ]]; then
    tag=$(gum input --placeholder "api" --header "Bookmark tag  (-> $relpath)")
    [[ -z "$tag" ]] && { print_error "Tag is required"; return 1; }
  fi

  _projects_ensure_storage
  local bfile; bfile="$(_bookmarks_file)" || return 1

  if [[ -f "$bfile" ]]; then
    local tmp; tmp=$(mktemp)
    grep -v "^${tag}:" "$bfile" > "$tmp" && mv "$tmp" "$bfile"
  fi

  echo "${tag}:${relpath}" >> "$bfile"
  print_success "Bookmarked '$tag' -> $relpath"
}

function _project_bookmark_go() {
  local tag="$1"

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  if [[ -z "$tag" ]]; then
    local tags; tags="$(_bookmarks_all | cut -d: -f1)"
    [[ -z "$tags" ]] && { print_warning "No bookmarks. Use 'project bookmark -a' to create one."; return 0; }
    tag=$(echo "$tags" | gum choose --select-if-one --header "Go to bookmark")
    [[ -z "$tag" ]] && return 0
  fi

  local relpath; relpath="$(_bookmark_relpath_for "$tag")"
  if [[ -z "$relpath" ]]; then
    print_error "Bookmark not found: $tag"
    return 1
  fi

  local target; target="$(git_root)/${relpath}"
  if [[ ! -d "$target" ]]; then
    print_error "Bookmark path no longer exists: $target"
    return 1
  fi

  cd "$target" || return 1
  print_success "Jumped to '$tag'"
}

function _project_bookmark_list() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local bookmarks; bookmarks="$(_bookmarks_all)"
  if [[ -z "$bookmarks" ]]; then
    print_warning "No bookmarks for '$(git_project_name)'. Use 'project bookmark -a'."
    return 0
  fi

  print_info "Bookmarks for project: $(git_project_name)"
  echo
  echo "$bookmarks" | awk -F: '{ printf "  %-20s %s\n", $1, $2 }'
}

function _project_bookmark_remove() {
  local tag="$1"

  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  if [[ -z "$tag" ]]; then
    local tags; tags="$(_bookmarks_all | cut -d: -f1)"
    [[ -z "$tags" ]] && { print_warning "No bookmarks to remove"; return 0; }
    tag=$(echo "$tags" | gum choose --select-if-one --header "Remove bookmark")
    [[ -z "$tag" ]] && return 0
  fi

  local existing; existing="$(_bookmark_relpath_for "$tag")"
  if [[ -z "$existing" ]]; then
    print_error "Bookmark not found: $tag"
    return 1
  fi

  local bfile; bfile="$(_bookmarks_file)" || return 1
  local tmp; tmp=$(mktemp)
  grep -v "^${tag}:" "$bfile" > "$tmp" && mv "$tmp" "$bfile"
  print_success "Removed bookmark '$tag'"
}

function _project_bookmark() {
  local -A opts
  if ! zparseopts -D -A opts -- a g l r h; then
    print_error "Usage: project bookmark [-a [tag] [relpath]] [-g [tag]] [-l] [-r [tag]] [-h]"
    return 1
  fi

  if (( ${+opts[-h]} )); then
    echo "Usage: project bookmark [flag] [args...]"
    echo "  -a [tag] [relpath]  bookmark current dir (or relpath) under tag"
    echo "  -g [tag]            go to bookmark (prompts if omitted) [default]"
    echo "  -l                  list bookmarks for current project"
    echo "  -r [tag]            remove a bookmark"
    echo "  -h                  show this help"
    return 0
  fi

  if (( ${+opts[-a]} )); then
    _project_bookmark_add "$@"
  elif (( ${+opts[-l]} )); then
    _project_bookmark_list
  elif (( ${+opts[-r]} )); then
    _project_bookmark_remove "$@"
  else
    # -g or no flag: go
    _project_bookmark_go "$@"
  fi
}

# ===== Worktree management =====

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
    local current_branch
    current_branch="$(git_current_branch)"
    local branches
    branches="$(_worktree_branches | grep -v "^${current_branch}$")"
    if [[ -z "$branches" ]]; then
      print_warning "No other worktrees found. Use 'wt -c' to create one."
      return 0
    fi
    branch=$(echo "$branches" | gum choose --select-if-one --header "Switch to worktree")
    [[ -z "$branch" ]] && return 1
  fi

  local target_path
  target_path="$(_worktree_path_for_branch "$branch")"

  if [[ -z "$target_path" ]]; then
    print_error "No worktree found for branch: $branch"
    print_info "Use 'wt -c $branch' to create one"
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

  local existing
  existing="$(_worktree_path_for_branch "$branch")"
  if [[ -n "$existing" ]]; then
    print_warning "Worktree already exists for branch: $branch"
    print_info "Path: $existing"
    print_info "Use 'wt -s $branch' to switch to it"
    return 1
  fi

  if [[ -z "$base_branch" ]]; then
    base_branch=$(gum input --value "main" --header "Base branch")
    [[ -z "$base_branch" ]] && { print_error "Base branch is required"; return 1; }
  fi

  local worktree_dir="${branch//\//-}"
  local worktree_path="$HOME/worktrees/${project_name}/${worktree_dir}"

  if [[ -d "$worktree_path" ]]; then
    print_error "Directory already exists: $worktree_path"
    print_info "Remove it manually or choose a different branch name"
    return 1
  fi

  mkdir -p "$HOME/worktrees/${project_name}"

  local branch_exists=false
  git show-ref --verify --quiet "refs/heads/$branch" && branch_exists=true

  local ret=0
  if $branch_exists; then
    print_info "Branch exists locally: $branch"
    gum spin --spinner dot --title "Creating worktree from existing branch..." -- \
      git worktree add "$worktree_path" "$branch"
    ret=$?
  else
    print_info "Creating new branch from: $base_branch"
    gum spin --spinner dot --title "Creating worktree with new branch..." -- \
      git worktree add -b "$branch" "$worktree_path" "$base_branch"
    ret=$?
  fi

  if [[ $ret -ne 0 ]]; then
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

  local target_path
  target_path="$(_worktree_path_for_branch "$target")"
  [[ -z "$target_path" ]] && target_path="$target"

  if [[ "$target_path" == "$main_worktree" ]]; then
    print_error "Cannot remove the main worktree"
    return 1
  fi

  local found
  found=$(git worktree list --porcelain | awk -v p="$target_path" '/^worktree / { if (substr($0,10) == p) print "yes" }')
  if [[ -z "$found" ]]; then
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

function _project_worktree() {
  if ! in_git_repo; then
    print_error "Not in a git repository"
    return 1
  fi

  local -A opts
  if ! zparseopts -D -A opts -- l s c r h; then
    print_error "Usage: wt [-l] [-c [branch] [base]] [-s [branch]] [-r [branch]] [-h]"
    return 1
  fi

  if (( ${+opts[-h]} )); then
    echo "Usage: wt [flag] [args...]"
    echo "  -l                  list all worktrees"
    echo "  -c [branch] [base]  create a new worktree (prompts if omitted)"
    echo "  -s [branch]         switch to a worktree (prompts if omitted) [default]"
    echo "  -r [branch]         remove a worktree (prompts if omitted)"
    echo "  -h                  show this help"
    return 0
  fi

  if (( ${+opts[-l]} )); then
    _worktree_list
  elif (( ${+opts[-c]} )); then
    _worktree_create "$@"
  elif (( ${+opts[-r]} )); then
    _worktree_remove "$@"
  else
    # -s or no flag: default to switch
    _worktree_switch "$@"
  fi
}

# ===== Top-level dispatcher =====

function project() {
  local subcmd="${1:-}"
  shift 2>/dev/null

  case "$subcmd" in
    register)   _project_register "$@" ;;
    unregister) _project_unregister "$@" ;;
    list)       _project_list ;;
    cd)         _project_cd "$@" ;;
    worktree)   _project_worktree "$@" ;;
    bookmark)   _project_bookmark "$@" ;;
    *)
      [[ -n "$subcmd" ]] && print_error "Unknown subcommand: $subcmd"
      echo "Usage: project <subcommand> [args...]"
      echo "  register [name] [path]       register a project (defaults to CWD)"
      echo "  unregister [name]            remove a registered project"
      echo "  list                         list all registered projects"
      echo "  cd [name]                    switch to a project root"
      echo "  worktree [-l|-c|-s|-r|-h]    manage git worktrees"
      echo "  bookmark [-a|-g|-l|-r|-h]    manage in-repo bookmarks"
      [[ -n "$subcmd" ]] && return 1 || return 0
      ;;
  esac
}

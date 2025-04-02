setopt SHARE_HISTORY
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt incappendhistory                                         # Immediately append history instead of overwriting

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 

bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

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

source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin"

eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(starship init zsh)"
eval "$(fzf --zsh)"

# export CARAPACE_BRIDGES='zsh,bash'
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
# source <(carapace _carapace)

export SSLKEYLOGFILE="$HOME/.ssl-key.log"

export TERM=xterm-256color

export GIT_EDITOR=hx
export VISUAL="$(which hx)"
export EDITOR="$VISUAL"
export SUDO_EDITOR="$VISUAL"
export AZ_AUTO_LOGIN_TYPE="DEVICE"

export XPAUTH_PATH="$HOME/src/smartbidder/xpauth_dev.xpr"
export XPRESS="$HOME/src/smartbidder/xpauth_dev.xpr"

# replacements for existing commands
alias ls="eza"
alias cat="batcat"
alias find="fdfind"
alias fix="git diff --name-only | uniq | xargs $EDITOR"
alias tree="ls --tree --color always | cat"
alias cp="cp -n"
alias mv="mv -n"

function wiki {
  hx -w ~/wiki ~/wiki/index.md
}

function most-recent-tag {
  git pull --tags && git describe --tags $(git rev-list --tags --max-count=5)
}

function search {
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
      --preview 'batcat --color=always {1}' \
      --preview-window 'right,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:become(hx {1}:{2})'
}

function review {
  git fetch --all
  git checkout $1
  CHANGED_FILES=("${(f)$(git diff --relative --name-only $1 $(git merge-base $1 main))}")
  pre-commit run --from-ref origin/main --to-ref HEAD
  # TODO: pants test
  # echo "running pyright check"
  # basedpyright "${CHANGED_FILES[@]}"
  read -sk '?Press any key to view files.'

  $EDITOR "${CHANGED_FILES[@]}"
  git checkout -
}

# Use powerline
USE_POWERLINE="true"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi

# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

export SSLKEYLOGFILE="$HOME/.ssl-key.log"

# NODE
export TERM=xterm-256color

export GIT_EDITOR=nvim
export VISUAL=nvim
export EDITOR="$VISUAL"
export PATH="$PATH:$HOME/.local/bin:/snap/bin"
export AZ_AUTO_LOGIN_TYPE="DEVICE"

export WINHOME="/mnt/c/Users/cak88/"
export XPAUTH_PATH="$HOME/src/smartbidder/xpauth_dev.xpr"

# NODE
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$PATH:$(npm config --global get prefix)/bin

# Use base virtual environment
if [[ -e $HOME/.venv/base/bin/activate ]]; then
  source $HOME/.venv/base/bin/activate
fi


# replacements for existing commands
alias ls="exa"
alias cat="batcat"
alias find="fdfind"

function venv {
  source "$HOME/.venv/$1/bin/activate"
}


function v  {
  ADD_PATHS=($VIRTUAL_ENV/lib/*/site-packages)
  ADD_PATHS+=($PYTHONPATH)
  BEFORE="$PYTHONPATH"
  PYTHONPATH=${(j{:})ADD_PATHS}
  nvim $@
  PYTHONPATH="$BEFORE"
}

function wiki {
  hx ~/wiki/index.md
}

function md5-compare-dirs {
  diff <(find $1 -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /') <(find $2 -type f -exec md5sum {} + | sort -k 2 | sed 's/ .*\// /')
}

function vim-compare-dirs {
  for files in $(diff -rq $1 $2 | grep 'differ$' | sed "s/^Files //g;s/ differ$//g;s/ and /:/g"); do 
    vimdiff ${files%:*} ${files#*:}; 
  done
}

function most-recent-tag {
  git pull --tags && git describe --tags $(git rev-list --tags --max-count=5)
}

function fix {
  stty sane
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

stty sane
setopt SHARE_HISTORY

# HELIX
# export HELIX_RUNTIME=~/src/helix/runtime



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

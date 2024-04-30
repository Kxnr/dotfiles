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

export GIT_EDITOR=vim
export VISUAL=vim
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

stty sane
setopt SHARE_HISTORY

# HELIX
# export HELIX_RUNTIME=~/src/helix/runtime



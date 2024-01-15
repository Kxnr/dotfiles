setopt inc_append_history

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
alias sbid="source $HOME/.venv/sbid/bin/activate"
alias clean_energy="source $HOME/.venv/clean_energy/bin/activate"
alias devapi="source $HOME/.venv/devapi/bin/activate"
alias betaapi="source $HOME/.venv/betaapi/bin/activate"
alias testapi="source $HOME/.venv/testapi/bin/activate"
alias prodapi="source $HOME/.venv/prodapi/bin/activate"

# NODE
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=$PATH:$(npm config --global get prefix)/bin

# Use base virtual environment
if [[ -e $HOME/.venv/base/bin/activate ]]; then
  source $HOME/.venv/base/bin/activate  # commented out by conda initialize
fi


# replacements for existing commands
alias ls="exa"
alias cat="batcat"
alias find="fdfind"

function venv {
  source "$HOME/.venv/$1/bin/activate"  # commented out by conda initialize
}

function v  {
  EXISTING_VENV=$VIRTUAL_ENV
  venv base
  nvim $@
  deactivate
  source "$EXISTING_VENV/bin/activate"
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


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/kxnr/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/kxnr/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/kxnr/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/kxnr/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

stty sane


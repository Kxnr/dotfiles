sudo add-apt-repository ppa:deadsnakes/ppa

# install default tools
sudo apt-get update

# TODO: zellij
# TODO: switch out eza for exa
sudo apt-get install fzf ripgrep exa bat fd-find neovim tmux zsh
mkdir "$HOME/src"

# make zsh the default shell
chsh -s $(which zsh)

# clone zsh profile items
git clone git@github.com:Chrysostomus/manjaro-zsh-config.git "$HOME/src/zsh-config"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/src/powerlevel10k"
git clone git@github.com:zsh-users/zsh-history-substring-search.git "$HOME/src/zsh-config/plugins/zsh-history-substring-search"
git clone git@github.com:zsh-users/zsh-autosuggestions.git "$HOME/src/zsh-config/plugins/zsh-autosuggestions"

sudo ln -s "$HOME/src/zsh-config" "/usr/share/zsh"
sudo ln -s "$HOME/src/powerlevel10k" "/usr/share/zsh-theme-powerlevel10k"

# link zsh config using the given plugins
ln -s zshrc "$HOME/.zshrc"
ln -s vim_bindings.vim "$HOME/.config/nvim/vim_bindings.vim"
ln -s init.lua "$HOME/.config/nvim/init.lua"
ln -s helix.toml "$HOME/.config/helix/config.toml"
ln -s languages.toml "$HOME/.config/helix/languages.toml"

# install vim plugins
nvim +'PlugInstall' +qa

# install programming languages and associated tools
curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo apt-get install python3.12-venv python3.12-dev
sudo apt-get install nvm

mkdir "$HOME/.venv"
python -m venv "$HOME/.venv/base"

# TODO:
# python-lsp-server
# ruff
# markdown-oxide
# rust-analyzer
# helix

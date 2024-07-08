# TODO: only do this if on apt-supported platform
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get python3.12 git  -y

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
ln -s helix.toml "$HOME/.config/helix/config.toml"
ln -s languages.toml "$HOME/.config/helix/languages.toml"

# install programming languages and associated tools
curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo apt-get install python3.12-venv python3.12-dev

mkdir "$HOME/.venv"
python -m venv "$HOME/.venv/base"

# TODO:
# python-lsp-server
# ruff
# markdown-oxide
# rust-analyzer

cargo install sd --locked
cargo install ast-grep --locked
cargo install eza --locked
cargo install bat --locked
cargo install fzf --locked
cargo install ripgrep --locked
cargo install zellij --locked
cargo install zoxied --locked

git clone https://github.com/helix-editor/helix ~/src/helix
cargo install --path ~/src/helix/helix-term --locked

# TODO: fonts

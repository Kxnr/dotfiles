# TODO: only do this if on apt-supported platform
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get python3.12 git  -y

mkdir "$HOME/src"

# make zsh the default shell
# TODO: ensure zsh is installed
chsh -s $(which zsh)

# clone zsh profile items
git clone git@github.com:Chrysostomus/manjaro-zsh-config.git "$HOME/src/zsh-config"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/src/powerlevel10k"
git clone git@github.com:zsh-users/zsh-history-substring-search.git "$HOME/src/zsh-config/plugins/zsh-history-substring-search"
git clone git@github.com:zsh-users/zsh-autosuggestions.git "$HOME/src/zsh-config/plugins/zsh-autosuggestions"
git clone git@github.com:wfxr/forgit.git "$HOME/src/forgit"

sudo ln -s "$HOME/src/zsh-config" "/usr/share/zsh"
sudo ln -s "$HOME/src/powerlevel10k" "/usr/share/zsh-theme-powerlevel10k"

# link zsh config using the given plugins
ln -s zshrc "$HOME/.zshrc"
ln -s helix.toml "$HOME/.config/helix/config.toml"
ln -s languages.toml "$HOME/.config/helix/languages.toml"
ln -s zellij.kdl $HOME/.config/zellij/config.kdl

# install programming languages and associated tools
curl https://sh.rustup.rs -sSf | sh -s -- -y
sudo apt-get install python3.12-venv python3.12-dev

mkdir "$HOME/.venv"
python -m venv "$HOME/.venv/base"

git clone git@github.com:jonas/tig.git "$HOME/src/tig"
make -C "$HOME/src/tig"
make install -C "$HOME/src/tig"

cargo install --locked --git https://github.com/Feel-ix-343/markdown-oxide.git markdown-oxide
cargo install sd --locked
cargo install ast-grep --locked
cargo install eza --locked
cargo install bat --locked
# cannot be installed from cargo
# cargo install fzf --locked
cargo install ripgrep --locked
# TODO zellij plugins
cargo install zellij --locked
cargo install zoxide --locked
cargo install forgit --locked
cargo install git-delta

git clone https://github.com/helix-editor/helix ~/src/helix
cargo install --path ~/src/helix/helix-term --locked

# TODO: fonts

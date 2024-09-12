#!/bin/sh
curl https://mise.run | sh
curl https://sh.rustup.rs -sSf | sh -s -- -y
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
curl termux.carapace.sh | sh

mkdir ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

mise use python latest
mise use racket latest -y
mise use node latest -y
mise use yadm -y
mise use eza -y
mise use fzf -y
mise use starship -y
mise use lazygit -y
mise use ripgrep -y
mise use bat -y
mise use zoxide -y
mise use uv -y
mise use pipx -y
mise use zellij -y
mise use opentofu -y

pipx install basedpyright

mkdir "$HOME/src"

cargo install --locked --git https://github.com/Kxnr/markdown-oxide.git markdown-oxide
cargo install sd --locked
cargo install ast-grep --locked
cargo install nu

git clone https://github.com/Kxnr/helix ~/src/helix
cargo install --path ~/src/helix/helix-term --locked

# TODO: fonts

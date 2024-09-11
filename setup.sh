#!/bin/sh
curl https://mise.run | sh
curl https://sh.rustup.rs -sSf | sh -s -- -y
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

mise use python latest
mise use yadm
mise use eza
mise use fzf
mise use starship
mise use lazygit
mise use racket latest
mise use node latest
mise use ripgrep
mise use bat
mise use zoxide
mise use uv
mise use pipx
mise use zellij
mise use opentofu

mkdir "$HOME/src"

cargo install --locked --git https://github.com/Kxnr/markdown-oxide.git markdown-oxide
cargo install sd --locked
cargo install ast-grep --locked
cargo install nu

git clone https://github.com/Kxnr/helix ~/src/helix
cargo install --path ~/src/helix/helix-term --locked

# TODO: fonts

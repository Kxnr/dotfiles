#!/bin/sh

install_debian()
{
  echo "installing for debian system"  
}

install_fedora()
{
  echo "installing for debian system"  
}

install_platform_independent()
{
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  curl https://mise.run | sh
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
}

setup_shell()
{
  chsh $(which zsh)
  mkdir ~/.zsh
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
  
}

install_nerd_font()
{
  # from https://github.com/ChrisTitusTech/dwm-titus
  FONT_DIR="$HOME/.local/share/fonts"
  FONT_ZIP="$FONT_DIR/FiraCode.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    FONT_INSTALLED=$(fc-list | grep -i "FiraCode")

  # Check if FiraCode Nerd-font is already installed
    if [ -n "$FONT_INSTALLED" ]; then
        echo "FiraCode Nerd-fonts are already installed."
        return 0
    fi

    echo "Installing FiraCode Nerd-fonts"

    # Create the fonts directory if it doesn't exist
    if [ ! -d "$FONT_DIR" ]; then
        mkdir -p "$FONT_DIR" || {
            echo "Failed to create directory: $FONT_DIR"
            return 1
        }
    else
        echo "$FONT_DIR exists, skipping creation."
    fi

    # Check if the font zip file already exists
    if [ ! -f "$FONT_ZIP" ]; then
        # Download the font zip file
        wget -P "$FONT_DIR" "$FONT_URL" || {
            echo "Failed to download FiraCode Nerd-fonts from $FONT_URL"
            return 1
        }
    else
        echo "FiraCode.zip already exists in $FONT_DIR, skipping download."
    fi

    # Unzip the font file if it hasn't been unzipped yet
    if [ ! -d "$FONT_DIR/FiraCode" ]; then
        unzip "$FONT_ZIP" -d "$FONT_DIR" || {
            echo "Failed to unzip $FONT_ZIP"
            return 1
        }
    else
        echo "FiraCode font files already unzipped in $FONT_DIR, skipping unzip."
    fi

    # Remove the zip file
    rm "$FONT_ZIP" || {
        echo "Failed to remove $FONT_ZIP"
        return 1
    }

    # Rebuild the font cache
    fc-cache -fv || {
        echo "Failed to rebuild font cache"
        return 1
    }

    echo "FiraCode Nerd-fonts installed successfully"

}

# curl https://mise.run | sh
# curl https://sh.rustup.rs -sSf | sh -s -- -y
# curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
# mkdir ~/.zsh
# git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

# mise use python latest
# mise use racket latest -y
# mise use node latest -y
# mise use eza -y
# mise use fzf -y
# mise use starship -y
# mise use lazygit -y
# mise use ripgrep -y
# mise use bat -y
# mise use zoxide -y
# mise use uv -y
# mise use pipx -y
# mise use zellij -y
# mise use opentofu -y

# pipx install basedpyright

# mkdir "$HOME/src"

# cargo install --locked --git https://github.com/Kxnr/markdown-oxide.git markdown-oxide
# cargo install sd --locked
# cargo install ast-grep --locked
# cargo install nu

# git clone https://github.com/Kxnr/helix ~/src/helix
# cargo install --path ~/src/helix/helix-term --locked

install_nerd_font


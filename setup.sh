#!/bin/bash
set -e

info() { echo "ℹ  $*"; }
success() { echo "✓  $*"; }
error() { echo "✗  $*" >&2; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_build_essentials() {
    info "Installing build essentials..."

    sudo apt update
    sudo apt install -y build-essential curl wget unzip git gpg

    success "Build essentials installed"
}

install_chicken() {
     sudo apt install chicken-bin libchicken-dev
     chicken-install apropos chicken-dev breadline
     cd `csi -R chicken.platform -p '(chicken-home)'`
     curl http://3e8.org/pub/chicken-doc/chicken-doc-repo.tgz | sudo tar zx
}

install_mise() {
    if command_exists mise; then
        info "mise already installed, skipping..."
        return 0
    fi

    info "Installing mise..."
    curl https://mise.run | sh

    # Source mise config
    export PATH="$HOME/.local/bin:$PATH"
    eval "$(mise activate bash)"

    success "mise installed"

    info "Installing tools via mise..."
    mise use -g python@latest -y
    mise use -g go@latest -y
    mise use -g rust@latest -y
    mise use -g eza -y
    mise use -g fzf -y
    mise use -g starship -y
    mise use -g lazygit -y
    mise use -g ripgrep -y
    mise use -g bat -y
    mise use -g zoxide -y
    mise use -g uv -y
    mise use -g zellij -y
    mise use -g gum -y
    mise use -g yazi -y
    mise use -g terraform -y
    mise use -g terraform-ls -y

    success "mise tools installed"
}

install_docker() {
    info "Installing docker..."
    # Add Docker's official GPG key:
    sudo apt update
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources << END
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
END

    sudo apt update
    info "Docker installed!"
}

install_rust() {
    info "Installing cargo tools..."
    cargo install scooter --locked
    cargo install mergiraf --locked
    cargo install difftastic --locked
    cargo install git-delta --locked
    cargo install simple-completion-language-server --locked
    cargo install ast-grep --locked

    success "Cargo tools installed"

    if [ -d "$HOME/src/helix" ]; then
        info "Helix already cloned, skipping..."
    else
        info "Cloning and building helix..."
        mkdir -p "$HOME/src"
        git clone git@github.com:kxnr/helix "$HOME/src/helix"
    fi

    info "Building helix (this may take a while)..."
    cargo install \
       --profile opt \
       --config 'build.rustflags="-C target-cpu=native"' \
       --path "$HOME/src/helix/helix-term" \
       --locked

    mkdir -p "$HOME/.config/helix"
    ln -sfn "$HOME/src/helix/runtime" "$HOME/.config/helix/runtime"

    install_helix_dictionary

    success "Helix installed"
}

install_helix_dictionary() {
    local DICT_DIR="$HOME/src/helix/runtime/dictionaries/en_US"
    local BASE_URL="https://raw.githubusercontent.com/wooorm/dictionaries/main/dictionaries/en"

    if [ -f "$DICT_DIR/en_US.aff" ] && [ -f "$DICT_DIR/en_US.dic" ]; then
        info "Helix en_US dictionary already installed, skipping..."
        return 0
    fi

    info "Installing en_US hunspell dictionary for Helix spell-checking..."
    mkdir -p "$DICT_DIR"
    curl -fsSL "$BASE_URL/index.aff" -o "$DICT_DIR/en_US.aff"
    curl -fsSL "$BASE_URL/index.dic" -o "$DICT_DIR/en_US.dic"
    success "Dictionary installed"
}

install_shell_tools() {
    local REPO="$HOME/src/shell-tools"

    if [ -d "$REPO" ]; then
        info "shell-tools already cloned, pulling latest..."
        git -C "$REPO" pull --ff-only
    else
        info "Cloning shell-tools..."
        git clone git@github.com:kxnr/shell-tools "$REPO"
    fi

    if ! command_exists just; then
        error "just not found; install it (cargo install just) and re-run"
        return 1
    fi

    info "Installing shell-tools..."
    just -f "$REPO/justfile" install
    success "shell-tools installed"
}

install_atuin() {
    if command_exists atuin; then
        info "atuin already installed, skipping..."
        return 0
    fi

    info "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    success "atuin installed"
}

install_python_tools() {
    info "Installing Python tools with uv..."

    if ! command_exists uv; then
        error "uv not found. Please install mise first."
        return 1
    fi

    # Install ruff (linter/formatter)
    if command_exists ruff; then
        info "ruff already installed, skipping..."
    else
        info "Installing ruff..."
        uv tool install ruff
        success "ruff installed"
    fi

    # Install pyrefly (Meta's type checker)
    if command_exists pyrefly; then
        info "pyrefly already installed, skipping..."
    else
        info "Installing pyrefly..."
        uv tool install pyrefly
        success "pyrefly installed"
    fi

    success "Python tools installed"
}

setup_shell() {
    info "Setting up zsh..."

    if ! command_exists zsh; then
        error "zsh not found. Installing..."
        if command_exists apt-get; then
            sudo apt-get install -y zsh
        elif command_exists yum; then
            sudo yum install -y zsh
        elif command_exists dnf; then
            sudo dnf install -y zsh
        fi
    fi

    # Change shell if not already zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
        success "Changed default shell to zsh"
    else
        info "zsh already default shell"
    fi

    mkdir -p "$HOME/.zsh"

    if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
    else
        info "zsh-autosuggestions already installed"
    fi

    if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"
    else
        info "zsh-syntax-highlighting already installed"
    fi

    success "Shell setup complete"
}

install_formatters() {
    sudo apt install tidy
}

install_nerd_font() {
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_ZIP="$FONT_DIR/DroidSansMono.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/DroidSansMono.zip"
    # FONT_INSTALLED=$(fc-list | grep -i "DroidSans" || true)

    # if [ -n "$FONT_INSTALLED" ]; then
    #     info "Nerd-fonts already installed"
    #     return 0
    # fi

    info "Installing Nerd-fonts..."
    mkdir -p "$FONT_DIR"

    if [ ! -f "$FONT_ZIP" ]; then
        wget -P "$FONT_DIR" "$FONT_URL"
    fi

    unzip -o "$FONT_ZIP" -d "$FONT_DIR"
    rm -f "$FONT_ZIP"
    fc-cache -fv

    success "Nerd-fonts installed"
}

info "Starting setup..."

install_build_essentials
install_docker
install_mise
install_rust
install_atuin
install_python_tools
install_nerd_font
setup_shell
install_shell_tools
install_formatters

success "Setup complete!"

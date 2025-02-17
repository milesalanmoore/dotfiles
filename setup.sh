#!/bin/bash

# Exit on any error
set -e

# Function to output status messages
log_message() {
  echo "➜ $1"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect operating system
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

OS=$(detect_os)
log_message "Detected operating system: $OS"

# Install package manager if needed
install_package_manager() {
  if [[ "$OS" == "macos" ]]; then
    if ! command_exists brew; then
      log_message "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      # Add Homebrew to PATH for Apple Silicon Macs
      if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
    fi
  elif [[ "$OS" == "linux" ]]; then
    log_message "Updating package lists..."
    sudo apt-get update
  fi
}

# Install essential packages
install_essential_packages() {
  log_message "Installing essential packages..."

  if [[ "$OS" == "macos" ]]; then
    brew install git curl wget zsh
  elif [[ "$OS" == "linux" ]]; then
    sudo apt-get install -y git curl wget zsh
  fi
}

# Install and configure chezmoi
install_chezmoi() {
  if ! command_exists chezmoi; then
    log_message "Installing chezmoi..."
    if [[ "$OS" == "macos" ]]; then
      brew install chezmoi
    else
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
      export PATH="$HOME/.local/bin:$PATH"
    fi
  fi

  log_message "Initializing chezmoi with your dotfiles..."
  chezmoi init https://github.com/milesalanmoore/dotfiles.git
}

# Install Miniconda
install_conda() {
  if ! command_exists conda; then
    log_message "Installing Miniconda..."

    # Download Miniconda installer
    if [[ "$OS" == "macos" ]]; then
      if [[ $(uname -m) == "arm64" ]]; then
        CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
      else
        CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
      fi
    else
      CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    fi

    wget $CONDA_URL -O /tmp/miniconda.sh
    bash /tmp/miniconda.sh -b -p $HOME/miniconda3
    rm /tmp/miniconda.sh

    # Initialize conda
    eval "$($HOME/miniconda3/bin/conda shell.$(basename $SHELL) hook)"
    conda init $(basename $SHELL)
  fi
}

# Install Oh My Zsh
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_message "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi
}

install_powerlevel10k() {
  if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    log_message "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  fi
}

# Install Ruby environment (macOS only)
install_ruby_env() {
  log_message "Installing Ruby environment..."
  brew install chruby ruby-install
  ruby-install ruby 3.3.5
}

# Install Julia (macOS only)
install_julia() {
  log_message "Installing Julia..."
  brew install juliaup
  juliaup add release
}

install_nvim() {
  log_message "Setting up Neovim environment..."

  # Install Neovim
  if ! command_exists nvim; then
    log_message "Installing Neovim..."
    if [[ "$OS" == "macos" ]]; then
      brew install neovim

      # Install additional dependencies that Neovim might need
      brew install ripgrep fd
    elif [[ "$OS" == "linux" ]]; then
      # Add Neovim repository for latest version
      sudo apt install neovim
    fi
  fi

  log_message "Neovim installation complete. Configurations will be applied through chezmoi."
}

install_lazyvim_distro() {
  log_message "Installing the lazyvim distro..."
  if [ -d "$HOME/.config/nvim" ]; then
    mv ~/.config/nvim{,.bak}
  fi
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git
  log_message "Lazyvim successfully installed."
}

main() {
  log_message "Starting development environment setup..."

  install_package_manager
  install_essential_packages
  install_chezmoi
  install_conda
  install_oh_my_zsh
  install_powerlevel10k
  install_nvim
  install_lazyvim_distro

  if [[ "$OS" == "macos" ]]; then
    install_ruby_env
    install_julia
  fi

  log_message "Applying dotfiles configuration..."
  # Ensure the chezmoi config directory exists
  mkdir -p ~/.config/chezmoi

  # Move chezmoi.toml only if it exists in the main directory
  if [[ -f "$HOME/chezmoi.toml" ]]; then
    mv "$HOME/chezmoi.toml" "$HOME/.config/chezmoi/chezmoi.toml"
  else
    log_message "Warning: chezmoi.toml not found in $HOME"
  fi

  # Apply chezmoi configuration
  chezmoi apply --config ~/.config/chezmoi/chezmoi.toml

  log_message "Installation complete! Please restart your terminal and run $(chezmoi apply)!"
  log_message "WARNING: Jump not installed."
  log_message "WARNING: Check neovim version. Lazyvim config requires v>0.8.0"
}

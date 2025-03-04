#!/bin/bash
# Note: 'set -e' is removed to prevent the script from exiting on any error.

# fzf
sudo apt install -y fzf || echo "Failed to install fzf"
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash || echo "Failed to source fzf key-bindings file"
else
  echo "Warning: fzf key-bindings file not found."
fi

# gh (GitHub CLI)
if ! type -p wget >/dev/null; then
  sudo apt update && sudo apt-get install -y wget || echo "Failed to install wget"
fi

sudo mkdir -p -m 755 /etc/apt/keyrings || echo "Failed to create /etc/apt/keyrings"
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null || echo "Failed to download GitHub CLI keyring"
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg || echo "Failed to update permissions for GitHub CLI keyring"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null || echo "Failed to add GitHub CLI repository"
sudo apt update || echo "Failed to update apt"
sudo apt install -y gh || echo "Failed to install gh"
if ! gh auth status >/dev/null 2>&1; then
  gh auth login || echo "Failed to login with gh"
fi

# nvim (Neovim)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || echo "Failed to download Neovim tarball"
sudo rm -rf /opt/nvim || echo "Failed to remove previous Neovim installation"
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz || echo "Failed to extract Neovim tarball"
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc || echo "Failed to update PATH for Neovim"

# zellij binary download
ZELLIJ_VERSION="v0.41.2"
curl -LO "https://github.com/zellij-org/zellij/releases/download/${ZELLIJ_VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz" || echo "Failed to download Zellij tarball"
tar -xzf zellij-x86_64-unknown-linux-musl.tar.gz || echo "Failed to extract Zellij tarball"
sudo mv zellij /usr/local/bin/ || echo "Failed to move Zellij binary to /usr/local/bin"
sudo chmod +x /usr/local/bin/zellij || echo "Failed to set executable permissions on Zellij"
rm zellij-x86_64-unknown-linux-musl.tar.gz || echo "Failed to remove Zellij tarball"

# Set default editor shortcut (C-x C-e)
echo 'export EDITOR=nvim' >> ~/.bashrc || echo "Failed to set default editor"

# dotfiles
if [ ! -d "$HOME/.config/dotfiles" ]; then
  git clone https://github.com/ajit283/dotfiles.git "$HOME/.config/dotfiles" || echo "Failed to clone dotfiles repository"
else
  echo "Dotfiles already exist in ~/.config/dotfiles."
fi

# atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || echo "Failed to install atuin"
# Ensure Atuin binary is available in PATH (typically installed to $HOME/.local/bin)
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  export PATH="$HOME/.local/bin:$PATH"
fi
atuin login -u ajit283 || echo "Failed to log in to atuin"
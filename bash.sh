#!/bin/bash
set -e  # Exit immediately if any command fails

# fzf
# • Use sudo with apt and add the -y flag for non-interactive installs.
sudo apt install -y fzf
# • If the key-bindings file isn’t found, print a warning.
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  source /usr/share/doc/fzf/examples/key-bindings.bash
else
  echo "Warning: fzf key-bindings file not found."
fi

# gh (GitHub CLI)
# • Check if wget exists; if not, update and install wget.
if ! type -p wget >/dev/null; then
  sudo apt update && sudo apt-get install -y wget
fi
# • Create keyrings directory with proper permissions.
sudo mkdir -p -m 755 /etc/apt/keyrings
# • Download and install the GitHub CLI keyring.
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
# • Add the GitHub CLI repository.
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# • Initiate GitHub CLI authentication (this is interactive).
# Check if already authenticated; if not, run authentication.
if ! gh auth status >/dev/null 2>&1; then
  gh auth login
fi

# nvim (Neovim)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
# • Remove any previous installation (be cautious with rm -rf).
sudo rm -rf /opt/nvim
# • Extract Neovim to /opt.
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# • Fix the export command by closing the quote properly.
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc

# rust
# • Use the -y flag to run the installer non-interactively.
curl https://sh.rustup.rs -sSf | sh -s -- -y
# • Source the Cargo environment to have access to cargo in the current session.
source "$HOME/.cargo/env"

# zellij
# • Ensure that Cargo is now available and install zellij.
cargo install --locked zellij

# Set default editor shortcut (C-x C-e)
# • Fix the export command: remove the $ from the variable name.
echo 'export EDITOR=nvim' >> ~/.bashrc

# dotfiles
# • Check if the dotfiles directory already exists to avoid cloning repeatedly.
if [ ! -d "$HOME/.config/dotfiles" ]; then
  git clone https://github.com/ajit283/dotfiles.git "$HOME/.config/dotfiles"
else
  echo "Dotfiles already exist in ~/.config/dotfiles."
fi

# atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
source ~/.bashrc
atuin login -u ajit283


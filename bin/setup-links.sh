#!/bin/bash

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
IDEAVIM_CONFIG="$HOME/.ideavimrc"
ZED_CONFIG_DIR="$HOME/.config/zed"
ZED_CONFIG_FILE="$ZED_CONFIG_DIR/settings.json"
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/config"
ZSHRC_CONFIG="$HOME/.zshrc"
ZSH_DIR="$HOME/.zsh"
BARTENDER_PLIST="$HOME/Library/Preferences/com.surteesstudios.Bartender.plist"
BARTENDER_CONFIG_DIR="$HOME/Library/Application Support/Bartender 5"

# Function to create a symlink with backup
create_link() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    echo "Source $src does not exist. Skipping."
    return
  fi

  if [ -L "$dest" ]; then
    echo "Symlink already exists for $dest. Removing and recreating."
    rm "$dest"
  elif [ -e "$dest" ]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi

  echo "Creating symlink: $dest -> $src"
  ln -s "$src" "$dest"
}

# Ensure .config directories exist
mkdir -p "$HOME/.config"
mkdir -p "$ZED_CONFIG_DIR"
mkdir -p "$GHOSTTY_CONFIG_DIR"
mkdir -p "$ZSH_DIR"

# Link Neovim config
# Use the editors/nvim directory as the source for ~/.config/nvim
create_link "$REPO_ROOT/editors/nvim" "$NVIM_CONFIG_DIR"

# Link .ideavimrc
create_link "$REPO_ROOT/editors/.ideavimrc" "$IDEAVIM_CONFIG"

# Link Zed settings
create_link "$REPO_ROOT/editors/zed_settings.json" "$ZED_CONFIG_FILE"

# Link Terminal settings
create_link "$REPO_ROOT/terminal/config.ghostty" "$GHOSTTY_CONFIG_FILE"
create_link "$REPO_ROOT/terminal/.zshrc" "$ZSHRC_CONFIG"

# Link Bartender settings
create_link "$REPO_ROOT/desktop/bartender/com.surteesstudios.Bartender.plist" "$BARTENDER_PLIST"
create_link "$REPO_ROOT/desktop/bartender/Bartender5" "$BARTENDER_CONFIG_DIR"

# Link individual .zsh files
if [ -d "$REPO_ROOT/terminal/.zsh" ]; then
  for f in "$REPO_ROOT/terminal/.zsh/"*; do
    if [ -f "$f" ]; then
      filename=$(basename "$f")
      create_link "$f" "$ZSH_DIR/$filename"
    fi
  done
fi

echo "Setup complete!"

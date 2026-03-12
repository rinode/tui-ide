#!/usr/bin/env bash
# Usage: ./workspace.sh [project-dir]

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
DIR="${1:-$(pwd)}"

# Install JetBrainsMono Nerd Font if not already present
if ! fc-list | grep -qi "JetBrainsMono"; then
  echo "Installing JetBrainsMono Nerd Font..."
  mkdir -p ~/.local/share/fonts
  curl -sLO --output-dir ~/.local/share/fonts \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -qo ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts/
  rm ~/.local/share/fonts/JetBrainsMono.zip
  fc-cache -fv
  echo "Font installed. Set 'JetBrainsMono Nerd Font' in your terminal settings."
fi

cd "$DIR" && XDG_CONFIG_HOME="$DOTFILES" exec nvim

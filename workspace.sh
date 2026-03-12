#!/usr/bin/env bash
# Usage: ./workspace.sh [project-dir]

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
SESSION="workspace"
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

# If session exists, prompt to reattach or recreate
if tmux -f "$DOTFILES/tmux/tmux.conf" has-session -t "$SESSION" 2>/dev/null; then
  read -rp "Session '$SESSION' exists. [a]ttach or [r]ecreate? " choice
  case "$choice" in
    r|R) tmux kill-session -t "$SESSION" ;;
    *)   tmux attach -t "$SESSION"; exit 0 ;;
  esac
fi

# Start tmux with repo config and expose DOTFILES to all panes/popups
tmux -f "$DOTFILES/tmux/tmux.conf" new-session -d -s "$SESSION" -n "editor" -c "$DIR"
tmux set-environment -t "$SESSION" DOTFILES "$DOTFILES"
tmux set-environment -t "$SESSION" XDG_CONFIG_HOME "$DOTFILES"

# Window 1: nvim (left 65%) | claude (top-right) | shell (bottom-right)
tmux send-keys -t "$SESSION:editor" "XDG_CONFIG_HOME='$DOTFILES' nvim" Enter

tmux split-window -h -p 35 -t "$SESSION:editor" -c "$DIR"
tmux send-keys -t "$SESSION:editor" "claude" Enter

tmux split-window -v -p 30 -t "$SESSION:editor" -c "$DIR"

tmux select-pane -t "$SESSION:editor.0"

# Window 2: two shell panes
tmux new-window -t "$SESSION" -n "shell" -c "$DIR"
tmux split-window -v -p 40 -t "$SESSION:shell" -c "$DIR"
tmux select-pane -t "$SESSION:shell.0"

# Prefix+/ opens the reference menu
tmux bind-key '/' display-popup -E -w 80% -h 80% "$DOTFILES/tmux/tmux-menu.sh"

tmux select-window -t "$SESSION:editor"
tmux -f "$DOTFILES/tmux/tmux.conf" attach -t "$SESSION"

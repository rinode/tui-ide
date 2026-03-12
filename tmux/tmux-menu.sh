#!/usr/bin/env bash
# Reference menu popup. Add entries to MENUS to extend it.

DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")/.." && pwd)}"

declare -A MENUS=(
  ["Vim cheat sheet"]="$DOTFILES/cheatsheets/vim"
  ["Tmux cheat sheet"]="$DOTFILES/cheatsheets/tmux"
  ["Git cheat sheet"]="$DOTFILES/cheatsheets/git"
  ["Claude Code cheat sheet"]="$DOTFILES/cheatsheets/claude"
)

choice=$(printf '%s\n' "${!MENUS[@]}" | sort | fzf \
  --no-sort \
  --reverse \
  --prompt='menu> ' \
  --header='Select a list  |  type to filter  |  ESC to close' \
  --color=header:italic)

[[ -z "$choice" ]] && exit 0

fzf --no-sort --reverse \
  --prompt="${choice}> " \
  --header="${choice}  |  type to filter  |  ESC to close" \
  --color=header:italic \
  < "${MENUS[$choice]}"

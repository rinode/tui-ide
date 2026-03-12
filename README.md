# tui-ide

A self-contained terminal workspace: Neovim + Claude Code + tmux, configured from a single repo.

## Requirements

- tmux
- nvim
- claude (Claude Code CLI)
- fzf
- curl, unzip (for font install)

## Setup

```bash
git clone <repo> ~/tui-ide
cd ~/tui-ide
./workspace.sh [project-dir]
```

If no `project-dir` is given, the current directory is used.

On first run, JetBrainsMono Nerd Font is installed automatically. Set it as your terminal font to get file icons in Neovim.

On first Neovim launch, lazy.nvim bootstraps itself and installs all plugins. Mason installs the configured LSP servers (TypeScript, PHP) in the background.

## Layout

```
Window 1 (editor)
+---------------------------+----------+
|                           |  claude  |
|          nvim             +----------+
|                           |  shell   |
+---------------------------+----------+

Window 2 (shell)
+-------------------------------------+
|              shell                  |
+-------------------------------------+
|              shell                  |
+-------------------------------------+
```

Switch windows with `Ctrl+b 1` / `Ctrl+b 2`.

## Reference menu

Press `Ctrl+b /` from any pane to open a searchable reference menu. Select a list and type to filter.

Available lists:

- Vim cheat sheet
- Tmux cheat sheet
- Git cheat sheet
- Claude Code cheat sheet

The same menu is available inside Neovim with `<leader>/`.

To add a new list, create a file in `cheatsheets/` and add an entry to the `MENUS` array in `tmux/tmux-menu.sh`.

## Neovim keybindings

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `<leader>e` | Toggle file tree |
| `<leader>x` | Close buffer |
| `<leader>/` | Open reference menu |
| `Shift+L` | Next buffer |
| `Shift+H` | Previous buffer |
| `gd` | Go to definition |
| `gr` | Show references |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format file |

## Customization

- **tmux config**: `tmux/tmux.conf`
- **Neovim config**: `nvim/init.lua`
- **LSP servers**: edit `ensure_installed` in `nvim/init.lua`
- **Cheat sheets**: plain text files in `cheatsheets/`

# tmux config

Personal tmux configuration using the Catppuccin theme, with automatic
light/dark switching, a window sidebar, and an fzf window picker.

## Location

Clone this repo to `~/.config/tmux` — tmux 3.1+ reads
`~/.config/tmux/tmux.conf` automatically, and the scripts/plugins are
referenced by absolute path from there.

```sh
git clone https://github.com/jason-cmk/tmux-configs ~/.config/tmux
```

Make sure there is no `~/.tmux.conf`, as it takes precedence over
`~/.config/tmux/tmux.conf`.

## Dependencies

| Dependency | Why | Install (macOS) |
|---|---|---|
| tmux 3.2+ (tested on 3.6a) | `display-popup`, `%if` conditionals | `brew install tmux` |
| fzf | Window picker (`prefix + w`) | `brew install fzf` |
| A Nerd Font | Catppuccin status-line icons | `brew install --cask font-jetbrains-mono-nerd-font` (or any Nerd Font), then select it in your terminal |
| Terminal with true colour | Catppuccin colours | Most modern terminals (WezTerm, iTerm2, Ghostty, Kitty) |

### Plugins

Plugins are installed manually (no TPM) into `plugins/`, which is
gitignored:

```sh
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
git clone https://github.com/tmux-plugins/tmux-cpu ~/.config/tmux/plugins/tmux-cpu
```

- **catppuccin/tmux** — theme (`latte` for light, `mocha` for dark). Pin a
  release tag; see https://github.com/catppuccin/tmux/releases for the latest.
- **tmux-cpu** — CPU module shown in the status bar.

## Light/dark switching

The theme follows the `LIGHT_SWITCH` environment variable, inherited when
the tmux server starts:

- `LIGHT_SWITCH=1` (or unset) → Catppuccin Latte (light)
- `LIGHT_SWITCH=0` → Catppuccin Mocha (dark)

Set it in `~/.zprofile`, e.g. `export LIGHT_SWITCH=1`. Because it's read at
server start, restart the server (`tmux kill-server`) after changing it.

## Keybinds

| Keys | Action |
|---|---|
| `prefix + h` | Split horizontally |
| `prefix + v` | Split vertically |
| `prefix + a` | Set session working dir to current pane's path |
| `prefix + p` | Toggle window-list sidebar (width via `@window_sidebar_width`, default 28) |
| `prefix + w` | fzf window picker popup with live preview |

## Reloading

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

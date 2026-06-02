# tmux configuration

Red/black themed tmux config with vim-style navigation and persistent sessions.

## Prefix

`C-Space` (replaces default `C-b`)

## Pane navigation

| Key | Action |
|-----|--------|
| `<prefix> h/j/k/l` | Move between panes (vim-style) |
| `M-Left/Right/Up/Down` | Move between panes (no prefix) |
| `<prefix> "` | Split vertically (inherits cwd) |
| `<prefix> %` | Split horizontally (inherits cwd) |

## Window navigation

| Key | Action |
|-----|--------|
| `S-Left / S-Right` | Previous / next window |
| `M-H / M-L` | Previous / next window (vim-style) |

## Copy mode (vi)

| Key | Action |
|-----|--------|
| `<prefix> [` | Enter copy mode |
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Yank to system clipboard (via tmux-yank) |

## Plugins

| Plugin | Purpose |
|--------|---------|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Unified vim/tmux pane navigation |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Clipboard integration |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions manually |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15 min, restore on start |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx) | Fuzzy session switcher (`<prefix> o`) |
| [tmux-fingers](https://github.com/Morantron/tmux-fingers) | Keyboard-driven text picking (`<prefix> F`) |

## Session management

- `<prefix> o` — open sessionx fuzzy session switcher
- Sessions auto-save every 15 minutes and restore automatically on tmux start

## Theme

Black background (`#000000`) with red (`#ff0000`) accents on the active window, active pane border, session name, and hostname in the status bar.

## Plugin installation

Plugins are managed by TPM. The plugin path is pinned to `~/dotfiles/.config/tmux/plugins` so it works correctly under Nix (which does not follow git submodules in the standard location).

Install plugins: `<prefix> I`
Update plugins: `<prefix> U`

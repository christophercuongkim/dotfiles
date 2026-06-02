# Ghostty Config

Red/black themed Ghostty terminal configuration.

## Quick Start

Edit `config` directly — changes apply on next terminal open (no restart needed for new windows).

**Change font size:**
```
font-size = 14
```

**Change font:**
```
font-family = SomethingElse Nerd Font Mono
```

**Change background color:**
```
background = #1a1a1a
```

**Add a keybind:**
```
keybind = ctrl+shift+t=new_tab
```

**Apply immediately** — open a new Ghostty window. No NixOS rebuild needed; `~/.config/ghostty/` is symlinked directly from this repo.

---

## Structure

| File | Description |
|------|-------------|
| `config` | Active configuration |
| `config.old` | Previous config kept as reference |

---

## Key Settings

| Setting | Value | What it does |
|---------|-------|-------------|
| `font-family` | `JetBrainsMono Nerd Font Mono` | Terminal font |
| `font-size` | `12` | Font size in pt |
| `background` | `#000000` | Terminal background |
| `foreground` | `#ffffff` | Default text color |
| `cursor-color` | `#ffffff` | Cursor color |
| `selection-background` | `#ff0000` | Selection highlight (red) |
| `shell-integration` | `zsh` | Shell integration features |

---

## Theming

Red/black color scheme to match the desktop.

**ANSI palette:**

| Index | Color | Hex |
|-------|-------|-----|
| 0 (black) | Background | `#000000` |
| 1 (red) | Red | `#ff0000` |
| 2 (green) | Green | `#44ff44` |
| 8 (bright black) | Dark grey | `#666666` |
| 9 (bright red) | Bright red | `#ff4444` |

To switch themes, replace the `background`, `foreground`, `cursor-color`, `selection-background`, and `palette` lines. Ghostty also supports loading themes by name if installed:
```
theme = catppuccin-mocha
```

---

## Keybindings

| Binding | Action |
|---------|--------|
| `Ctrl+P` | Paste from clipboard |

Ghostty default bindings (copy, new window, etc.) remain active unless explicitly overridden.

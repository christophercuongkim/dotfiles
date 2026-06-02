# Alacritty Config

Single-file Alacritty terminal configuration using the TOML format.

## Quick Start

All changes are live immediately — edit `alacritty.toml` and the terminal picks them up without restart (`live_config_reload = true`).

**Change font size:**
```toml
[font]
size = 14  # change this
```

**Change font family:**
```toml
[font.normal]
family = "SomeOtherNerdFont"
style = "Regular"
```

**Change a color:**
```toml
[colors.primary]
background = "0x1E1D2F"  # hex color
foreground = "0xD9E0EE"
```

**Change the shell:**
```toml
[shell]
program = "/bin/bash"  # or any absolute path
```

**Add a keybinding:**
```toml
[[keyboard.bindings]]
key = "V"
mods = "Control|Shift"
action = "Paste"
```

No `nixos-rebuild` needed — the file is symlinked directly from this repo to `~/.config/alacritty/alacritty.toml`.

---

## Structure

```
alacritty/
└── alacritty.toml   # single config file, all settings
```

Everything lives in `alacritty.toml`. Alacritty supports splitting config across multiple files via `import`, but this setup does not use that.

---

## Key Settings

| Setting | Location in file |
|---|---|
| Font family & style | `[font.normal]`, `[font.bold]`, `[font.italic]` |
| Font size | `[font]` → `size` |
| Colors | `[colors.primary]`, `[colors.normal]`, `[colors.bright]` |
| Cursor shape/blink | `[cursor]`, `[cursor.style]` |
| Shell | `[shell]` → `program` |
| Window size & padding | `[window.dimensions]`, `[window.padding]` |
| Mouse bindings | `[[mouse.bindings]]` |
| Keyboard bindings | `[[keyboard.bindings]]` |

---

## Theming

The color scheme is **Catppuccin Mocha** (dark purple-tinted theme).

Key colors:
- Background: `#1E1D2F`
- Foreground: `#D9E0EE`
- Cursor: `#F5E0DC` (text) / `#1E1D2F` (background)
- Indexed color 16: `#F8BD96` (peach)
- Indexed color 17: `#F5E0DC` (rosewater)

`draw_bold_text_with_bright_colors = true` means bold text uses the `[colors.bright]` palette instead of the normal palette.

To switch themes, replace the entire `[colors]` section. Community theme collections (e.g. [alacritty-theme](https://github.com/alacritty/alacritty-theme)) provide ready-to-paste TOML snippets.

# Rofi Configuration

## Quick Start

### Change accent color
Edit the `red` and `red-dark` variables in `config.rasi`:
```rasi
red:      #ff0000;   /* primary accent */
red-dark: #cc0000;   /* darker variant (unused currently) */
```
Every element that references `@red` (border, prompt text, selected item background,
scrollbar handle, active mode button) updates automatically.

### Change icon theme
```rasi
configuration {
    icon-theme: "Papirus-Dark";   /* any installed icon theme */
}
```

### Change font
```rasi
configuration {
    font: "JetBrainsMono Nerd Font 11";   /* family + size */
}
```
The `prompt` block has its own override (`Bold 11`) — update both if you change the family.

### Add or remove modes
```rasi
configuration {
    modi: "drun,run,window";   /* comma-separated, order sets tab order */
}
```

### Adjust window size
```rasi
window {
    width: 600px;   /* absolute px or percentage, e.g. 40% */
}
```
Number of visible list rows is controlled separately:
```rasi
listview {
    lines: 8;
}
```

---

## Structure

Single file, no external theme imports:

```
~/.config/rofi/
└── config.rasi    # everything inline
```

All colors, layout, and element states live in `config.rasi`. There is no
`themes/` directory and no `@import` or `@theme` directive.

---

## Themes

### Color variables (defined in the `*` block)

| Variable      | Hex       | Applied to                                              |
|---------------|-----------|---------------------------------------------------------|
| `bg`          | `#000000` | Window background                                       |
| `bg-alt`      | `#111111` | Inputbar, message box, scrollbar track, mode buttons    |
| `bg-selected` | `#222222` | Defined but not referenced in current layout            |
| `fg`          | `#ffffff` | Default text, selected-item text                        |
| `fg-alt`      | `#aaaaaa` | Search placeholder text                                 |
| `red`         | `#ff0000` | Window border, prompt text, selected item bg, scrollbar handle, active mode button bg |
| `red-dark`    | `#cc0000` | Defined but not referenced in current layout            |
| `urgent`      | `#ff4444` | Urgent-state item text and selected background          |

`background-color: transparent` is set globally on `*` so individual blocks
only need to override where they want an explicit fill.

---

## Modes

| Mode     | Display label | Description                   |
|----------|---------------|-------------------------------|
| `drun`   | " Apps"      | Launched desktop applications |
| `run`    | " Run"       | Arbitrary command execution   |
| `window` | " Windows"   | Switch between open windows   |

Mode switcher tabs appear at the bottom when rofi is opened with `-show drun`
(or any other mode). The active tab gets the `@red` background; inactive tabs
use `@bg-alt`.

---

## Keybindings

Rofi is launched from Hyprland via `/home/chriskim/dotfiles/.config/hypr/keybinds.conf`:

| Keybind       | Command           | Opens       |
|---------------|-------------------|-------------|
| `Super+Space` | `rofi -show drun` | Apps mode   |

To add launchers for the other modes, add lines to `keybinds.conf`:
```
bind = $mod, R, exec, rofi -show run
bind = $mod, W, exec, rofi -show window
```

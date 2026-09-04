# Hyprland Configuration

The compositor config is **Lua**. Hyprland deprecated its old `hyprlang` `.conf`
format in 0.55 and drops it after 0.56; we run 0.56.2.

The `.conf` files are still in this directory during the migration. Hyprland
prefers `hyprland.lua` when both exist and picks one **once at startup**, so
they are dead weight for the compositor but serve as the rollback path. They
will be deleted once the Lua config has survived a few real logins.

`hyprlock.conf`, `hypridle.conf` and `hyprpaper.conf` are **not** affected —
those are separate hypr\* applications and remain hyprlang.

---

## Quick Start

**Add a keybinding** — open `keybinds.lua`:
```lua
bind(mod .. " + T", hl.dsp.exec_cmd("alacritty"), "Alacritty")
```
The local `bind()` wrapper takes a description and forwards to `hl.bind`.
Descriptions are not decoration: see *Keybindings* below.

**Add a window rule** — open `windowrules.lua`:
```lua
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^pavucontrol$" },
    float = true,
})
```

**Change monitor layout** — edit `monitors.lua`, then `hyprctl reload`.

**Apply a single setting without editing files** — use `hyprctl eval`:
```bash
hyprctl eval 'hl.config({ decoration = { rounding = 8 } })'
hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.5 })'
```

> **`hyprctl keyword` no longer works.** It is gated on the legacy parser and
> returns the string `"keyword can't work with non-legacy parsers. Use eval."`
> **with exit status 0**, so anything calling it appears to succeed while doing
> nothing. Use `hyprctl eval` instead.

---

## Structure

| Path | Description |
|---|---|
| `hyprland.lua` | Entry point; `require`s the other modules |
| `vars.lua` | Shared values (`mod`, `terminal`, `scripts` path) — locals do not cross a `require` boundary |
| `monitors.lua` | Monitor layout, HiDPI scaling, lid-switch binds |
| `input.lua` | Touchpad and keyboard input settings |
| `autostart.lua` | Session services and app launch, via `hl.on("hyprland.start", ...)` |
| `appearance.lua` | Decorations, animation curves and per-leaf animations |
| `keybinds.lua` | All keyboard and mouse binds |
| `windowrules.lua` | Per-application window rules (currently empty) |
| `hypridle.conf` | Idle timeout chain — **hyprlang**, separate daemon |
| `hyprlock.conf` | Lock screen layout — **hyprlang**, separate app |
| `hyprpaper.conf` | Wallpaper — **hyprlang**, separate app |
| `scripts/hypr-lib.sh` | Shared helper; routes monitor/device changes to `keyword` or `eval` depending on which config manager is live |
| `scripts/keybind-help.sh` | Rofi cheatsheet of active binds |
| `scripts/swap-monitors.sh` | Swaps the x-positions of two external monitors |
| `scripts/position-monitor.sh` | Moves focused monitor adjacent to nearest (or chosen) monitor |
| `scripts/reset-monitors.sh` | Resets all monitors to default layout |
| `scripts/toggle-trackpad.sh` | Toggles the touchpad enabled state |
| `scripts/lid-switch.sh` | Lid open/close handling |
| `scripts/toggle-idle.sh`, `scripts/toggle-lid.sh` | Idle-lock and lid-suspend inhibitors |

**Shared values** (`vars.lua`, replaces the old `$mod`-style variables):

| Key | Value |
|---|---|
| `mod` | `SUPER` |
| `terminal` | `ghostty` |
| `file_manager` | `dolphin` |
| `ss` | `hyprshot` |
| `scripts` | `~/.config/hypr/scripts` |

Pull them in with `local v = require("vars")`.

---

## Monitors

**Current configuration** (`monitors.lua`):

```lua
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.5 })
hl.monitor({ output = "",      mode = "preferred", position = "auto-left", scale = 1 })
```

An empty `output` is the catch-all: every monitor without an explicit rule is
placed to the left of the laptop screen at its preferred (native) mode.

**Lid switch** — the laptop display is disabled on lid close *only when an
external monitor is present*; disabling the sole output leaves it black on the
next lid open, so `lid-switch.sh` guards on that.

```lua
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd(v.scripts .. "/lid-switch.sh close"), { locked = true, description = "Lid close" })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(v.scripts .. "/lid-switch.sh open"),  { locked = true, description = "Lid open" })
```

`switch:` key strings are passed through verbatim by the Lua bind parser and
matched by the keybind manager, so this behaves exactly as the old `bindl` did.

**Runtime monitor changes** — `hyprctl eval`:
```bash
# Disable a monitor
hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'

# Change scale on the fly
hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })'

# Reposition a monitor
hyprctl eval 'hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "1920x0", scale = 1 })'
```

From a script, prefer the wrapper — it works under either config manager:
```bash
source ~/.config/hypr/scripts/hypr-lib.sh
hypr_monitor eDP-1 preferred 0x0 1.5
hypr_monitor_disable HDMI-A-1
hypr_device_enabled "pixa3854:00-093a:0274-touchpad" false
```

**Swap two external monitors** — `Super + M` runs `scripts/swap-monitors.sh`,
reading current x-positions via `hyprctl monitors -j`. Requires `jq`.

**Reposition a monitor** — `Super + Alt + Shift + H/J/K/L` runs
`scripts/position-monitor.sh`, moving the focused monitor adjacent to the
nearest other monitor. With 3+ monitors, rofi prompts for the reference.

**Reset monitor layout** — `Super + Shift + M` runs `scripts/reset-monitors.sh`,
placing eDP-1 at origin and all externals to the left.

---

## Keybindings

`mod` = Super (Windows key).

Every bind carries a **description**, and that is load-bearing rather than
cosmetic. `hl.bind` pins every Lua bind to handler `__lua` with an opaque Lua
registry integer as its arg, so `hyprctl binds -j` reports `"dispatcher":
"__lua"` for *all* of them. A description is the only thing that identifies a
bind to a script — `keybind-help.sh` reads `.description`.

`keybinds.lua` wraps this:
```lua
local function bind(keys, dispatcher, description, opts)
    opts             = opts or {}
    opts.description = description
    hl.bind(keys, dispatcher, opts)
end
```

**Each modifier needs its own `+`.** The parser splits the key string on `+`
and trims each token, so `"SUPER SHIFT + 1"` is read as a single keysym named
`SUPER SHIFT` and the bind is silently dropped. Write `"SUPER + SHIFT + 1"`.

### Applications

| Binding | Action |
|---|---|
| `Super + Return` | Terminal (ghostty) |
| `Super + B` | Firefox |
| `Super + grave` | Lock screen (hyprlock) |
| `Super + Space` | App launcher (rofi drun) |
| `Super + /` | Keybind cheatsheet |
| `Super + Shift + S` | Screenshot region (hyprshot → `~/Pictures/screen_shots`) |
| `Super + XF86AudioPlay` | Spotify |

### Window Management

| Binding | Action |
|---|---|
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + X` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle float |
| `Super + Ctrl + Arrow` | Resize active window by 20 px |
| `Super + LMB drag` | Move floating window |
| `Super + RMB drag` | Resize floating window |

### Workspaces

| Binding | Action |
|---|---|
| `Super + 1-5` | Switch to workspace 1-5 |
| `Super + Shift + 1-5` | Move window to workspace 1-5 |
| `Super + Shift + 9` | Move window to previous workspace |
| `Super + Shift + 0` | Move window to next workspace |
| `Super + N` | First empty workspace |
| `Super + Shift + N` | Previous empty workspace |
| `Super + Tab` | Next workspace on monitor |
| `Super + Shift + Tab` | Previous workspace on monitor |

### Monitors

| Binding | Action |
|---|---|
| `Super + Ctrl + H/J/K/L` | Focus monitor left/down/up/right |
| `Super + Ctrl + Tab` | Focus next monitor |
| `Super + Ctrl + Shift + Tab` | Focus previous monitor |
| `Super + Shift + H/J/K/L` | Move window to monitor in direction |
| `Super + Alt + H/J/K/L` | Move workspace to monitor in direction |
| `Super + Alt + Tab` | Move workspace to next monitor |
| `Super + Alt + Shift + Tab` | Move workspace to previous monitor |
| `Super + Alt + Shift + H/J/K/L` | Reposition focused monitor |
| `Super + Alt + Shift + M` | Swap workspaces between monitors |
| `Super + M` | Swap external monitor positions |
| `Super + Shift + M` | Reset monitor layout |

### Toggles

| Binding | Action |
|---|---|
| `Super + Shift + T` | Toggle trackpad |
| `Super + Shift + I` | Toggle idle lock/sleep |
| `Super + Shift + A` | Toggle lid-close suspend |

### Media Keys

| Binding | Action |
|---|---|
| `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` | Volume ±5% (wpctl) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` / `XF86AudioPrev` / `XF86AudioNext` | playerctl transport |
| `XF86MonBrightnessUp` / `XF86MonBrightnessDown` | Brightness ±10% (brightnessctl) |

Media and brightness binds use `{ locked = true, repeating = true }` (the old
`bindel`); mute and transport use `{ locked = true }` (`bindl`).

This table is maintained by hand. The live list is always
`hyprctl binds -j`, or `Super + /`.

---

## Window Rules

`windowrules.lua` is empty and ready to populate:

```lua
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^pavucontrol$" },
    float = true,
})

hl.window_rule({
    name  = "firefox-on-2",
    match = { class = "^firefox$" },
    workspace = "2",
})

hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})
```

Rules are named tables rather than the old comma-separated `windowrulev2`
strings, and `hl.window_rule` returns a handle with `:set_enabled(false)`.
`hl.layer_rule` and `hl.workspace_rule` follow the same shape.

Match on `class`, `title`, `workspace`, `float`, `fullscreen`, `xwayland` and
more — see the [Hyprland wiki](https://wiki.hypr.land/Configuring/Basics/Window-Rules/).

---

## Autostart

`autostart.lua` registers one handler:

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("mako")
    -- ...
end)
```

`hyprland.start` is fired from the compositor event bus at startup, **not** on
config load — so `hyprctl reload` does not re-run any of this.

**Phase 1 — session environment and services:** export `DISPLAY`,
`WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE` and `XDG_CURRENT_DESKTOP` into
the systemd user environment and restart `hyprland-session.target`, then start
`hyprpolkitagent`, `mako`, `hypridle`, `gnome-keyring-daemon`, `hyprpaper`, the
cursor theme, and `blueman-applet`.

**Phase 2 — lock and workspace binding:** locks on start; after unlock,
workspaces 1-4 are bound to the first external monitor (falling back to
`eDP-1`). The pinning goes through `hyprctl eval` with `hl.workspace_rule` —
the old `hyprctl keyword workspace` form is a silent no-op under Lua.

**Phase 3 — app launch** (staggered): `ghostty` 1 s, `brave` 1.5 s,
`spotify` 2 s, `1password` 2.5 s.

**Phase 4 — move windows to workspaces:** ghostty→1 at 5 s, brave→2 at 6 s,
spotify→3 at 7 s, 1password→4 at 8 s.

> Phases 3 and 4 are a straight port of the old `sleep N &&` ladder. The delays
> are a guess that breaks on a slow boot; replacing them with real window-open
> event handlers is tracked separately.

**Adding a new autostart app** — inside the existing handler:
```lua
hl.exec_cmd("sleep 3 && myapp")
hl.exec_cmd("sleep 9 && hyprctl dispatch movetoworkspacesilent 5,class:^(myapp)$")
```
Use `hyprctl clients -j | jq '.[].class'` to find the window class.

---

## Appearance

Configured in `appearance.lua`.

**Decorations:**

| Property | Value |
|---|---|
| `rounding` | 10 px |
| `rounding_power` | 2.0 |
| `active_opacity` / `inactive_opacity` / `fullscreen_opacity` | 1.0 |
| `dim_inactive` | false |
| `dim_strength` / `dim_special` / `dim_around` | 0.5 / 0.2 / 0.4 |
| `border_part_of_window` | true |

To enable inactive window dimming at runtime:
```bash
hyprctl eval 'hl.config({ decoration = { dim_inactive = true, dim_strength = 0.3 } })'
```

**Animations** are a named curve plus one `hl.animation` call per leaf, rather
than the old `bezier =` / `animation =` lines:

```lua
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
```

Applied to `windows`, `windowsOut`, `border`, `fade` and `workspaces`. To
disable all animations:
```bash
hyprctl eval 'hl.config({ animations = { enabled = false } })'
```

**Wallpaper** (`hyprpaper.conf`, still hyprlang) — currently only `eDP-1`:
```
wallpaper {
  monitor = eDP-1
  path = /home/chriskim/wallpapers/jjk_wallpaper.jpg
  fit_mode = cover
}
```

---

## Idle & Lock

Managed by `hypridle` (`hypridle.conf`) and `hyprlock` (`hyprlock.conf`), both
still hyprlang.

### Timeout chain

| Timeout | Event |
|---|---|
| 2.5 min | Dim screen: `brightnessctl -s set 10` |
| 2.5 min | Keyboard backlight off |
| 5 min | Lock screen (skipped if `hyprlock` already running) |
| 5.5 min | Screen off: `hyprctl dispatch dpms off` |
| 30 min | Suspend: `systemctl suspend` |

State is restored on resume from each timeout.

**Lock before suspend** — `hypridle` runs `hyprlock` in `before_sleep_cmd`, so
manual `systemctl suspend` locks too.

**Manual lock** — `Super + grave`.

### Hyprlock features

- Background: blurred desktop screenshot (3 passes), all monitors.
- Clock: 90 pt time top-right, 25 pt date below, refreshed every 60 s.
- Password field: centered, gradient outline, 15 px rounding, PAM failure text.
- Keyboard layout indicator: cycles via `hyprctl switchxkblayout all next`.
- Fingerprint authentication enabled.
- Clear buffer: `Esc`, `Ctrl+U`, `Ctrl+Backspace`.

---

## Reload and runtime changes

**Full reload** — re-reads the config:
```bash
hyprctl reload
```

**Full reset** — recreates the entire config context, and is what allows
switching between the Lua and hyprlang managers without logging out:
```bash
hyprctl reload full-reset
```

**Evaluate Lua against the running compositor:**
```bash
hyprctl eval 'hl.config({ decoration = { rounding = 0 } })'
hyprctl eval 'hl.config({ general = { gaps_out = 10 } })'
hyprctl eval 'hl.device({ name = "pixa3854:00-093a:0274-touchpad", enabled = false })'
hyprctl eval 'return #hl.get_monitors()'
```

`eval` only works under the Lua config manager; under hyprlang it returns
`eval is only supported with the lua config manager`. That string is how
`hypr-lib.sh` detects which manager is live.

Changes made via `eval` are **not persistent** — they revert on the next
reload or restart. Edit the `.lua` files to make them permanent.

**Dispatch a one-off action** (works under both managers):
```bash
hyprctl dispatch exec ghostty
hyprctl dispatch movetoworkspace 3
hyprctl dispatch dpms off
```

### Checking that a config change actually applied

**`hyprctl configerrors` is not a reliable check.** During this migration it
returned empty while 22 binds were failing to parse and Hyprland's own
on-screen error banner was listing them. Verify with:

```bash
hyprctl binds -j | jq length          # bind count
hyprctl getoption decoration:rounding # a specific option
tail -50 $XDG_RUNTIME_DIR/hypr/*/hyprland.log
```

and by watching for the red on-screen error banner.

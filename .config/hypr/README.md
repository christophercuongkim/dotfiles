# Hyprland Configuration

The compositor config is **Lua**. Hyprland deprecated its old `hyprlang` `.conf`
format in 0.55 and drops it after 0.56; we run 0.56.2.

The compositor `.conf` files are gone — the Lua config has survived real cold
boots. Hyprland prefers `hyprland.lua` when both exist and picks one **once at
startup**, so rolling back would mean restoring the `.conf` files from git and
restarting; a reload is not enough.

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

> **`hyprctl keyword` and `hyprctl dispatch` both changed.**
>
> `keyword` is gated on the legacy parser and returns
> `"keyword can't work with non-legacy parsers. Use eval."` **with exit status
> 0**, so callers appear to succeed while doing nothing. Use `hyprctl eval`.
>
> `dispatch` now parses its argument as **Lua**, so the old syntax is a syntax
> error: `hyprctl dispatch dpms on` fails with `')' expected near 'on'`.
> Write `hyprctl dispatch 'hl.dsp.dpms({ action = "on" })'` instead.

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
| `actions.lua` | Key actions needing real logic: swap monitors, reset layout, toggle trackpad |
| `scripts/position-monitor.sh` | Moves focused monitor adjacent to nearest (or chosen) monitor |
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

Inside the config, skip `hyprctl` entirely — `hl.get_monitors()` returns
`HL.Monitor` objects and `hl.bind` accepts a plain Lua function, so a bind can
run logic directly. See `actions.lua`. Note the fields are **snake_case**
(`refresh_rate`, `active_workspace`), unlike the camelCase `hyprctl -j` emits.

From a shell script, prefer the wrapper — it works under either config manager:
```bash
source ~/.config/hypr/scripts/hypr-lib.sh
hypr_monitor eDP-1 preferred 0x0 1.5
hypr_monitor_disable HDMI-A-1
hypr_device_enabled "pixa3854:00-093a:0274-touchpad" false
```

**Swap two external monitors** — `Super + M` runs `actions.swap_monitors`,
which exchanges the x positions of the first two externals.

**Reposition a monitor** — `Super + Alt + Shift + H/J/K/L` runs
`scripts/position-monitor.sh`, moving the focused monitor adjacent to the
nearest other monitor. With 3+ monitors, rofi prompts for the reference.

**Reset monitor layout** — `Super + Shift + M` runs `actions.reset_monitors`,
placing eDP-1 at the origin and stacking all externals to its left.

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
| `Super + Shift + A` | Toggle keep-awake (blocks lid-close *and* idle suspend) |

`Super + Shift + I` stops and starts the `hypridle` **unit**, not the process —
it has `Restart=always`, so `pkill hypridle` came straight back after ten
seconds. `Super + Shift + A` holds a `handle-lid-switch:sleep` inhibitor;
`sleep` is in there because hypridle's 30-minute listener calls
`systemctl suspend`, which a lid-only inhibitor does not block. While it is on,
a manual `systemctl suspend` is refused too.

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

`autostart.lua` registers two handlers.

**`hyprland.start`** — fired from the compositor event bus at startup, **not**
on config load, so `hyprctl reload` does not re-run any of it.

*Session setup:* export `DISPLAY`, `WAYLAND_DISPLAY`,
`HYPRLAND_INSTANCE_SIGNATURE` and `XDG_CURRENT_DESKTOP` into the systemd user
environment, then start `hyprpolkitagent`, `gnome-keyring-daemon` and the
cursor theme.

`mako`, `hypridle`, `hyprpaper`, `blueman-applet` and `waybar` are **not**
started here — they are systemd user units pulled in by
`graphical-session.target`. See
`modules/features/desktop/session-services.nix`. `gnome-keyring` and
`setcursor` stay inline: the first is partly PAM-managed, the second is a
one-shot rather than a daemon.

There is no `hyprland-session.target` on this system (`LoadState=not-found`) —
UWSM owns the session via `wayland-session@hyprland-uwsm.desktop.target`. An
earlier version chained session setup through
`systemctl --user stop hyprland-session.target && ...`, which broke at the stop
and silently skipped everything after it.

*Lock and workspace binding:* locks on start; after unlock, workspaces 1-4 are
bound to the first external monitor (falling back to `eDP-1`). The pinning goes
through `hyprctl eval` with `hl.workspace_rule` — the old
`hyprctl keyword workspace` form is a silent no-op under Lua.

*App launch:* `ghostty`, `brave`, `spotify` and `1password`, with no placement
arguments.

**`window.open`** — startup placement, keyed on window class:

```lua
local placements = {
    ["com.mitchellh.ghostty"] = 1,
    ["brave-browser"]         = 2,
    ["spotify"]               = 3,
    ["1password"]             = 4,
}

hl.on("window.open", function(w)
    local ws = placements[w.class]
    if not ws then return end
    placements[w.class] = nil          -- one-shot per class
    hl.dispatch(hl.dsp.window.move({
        workspace = ws,
        window    = "address:" .. w.address,
        follow    = false,
    }))
end)
```

**Why not an exec rule.** `hl.exec_cmd` takes a window rule as its second
argument (`hl.exec_cmd("brave", { workspace = "2 silent" })`) and it looks like
the right answer, but the rule is tied to the PID `hl.exec_cmd` spawns. Brave
launches through a wrapper that re-execs, so its window belongs to a different
PID, the rule silently misses, and the window lands on whatever workspace has
focus. ghostty, spotify and 1password are single-process and did match — which
made exec rules look correct until the first cold boot.

Matching the window is PID-independent and works for all four. The cost is that
placement happens just after the window maps, so there can be a brief flash on
the wrong workspace. Still far better than the `sleep 5..8` ladder both
approaches replaced, which left windows misplaced for seconds and lost them
outright if an app started slowly.

Exec rules are still fine for a single-process app, and any window-rule effect
works in that table, not just `workspace`. An unknown key is a hard error, not
a silent no-op.

**Adding a new autostart app** — `hl.exec_cmd("myapp")` inside the
`hyprland.start` handler, plus an entry in `placements` if it needs a
workspace.
Use `hyprctl clients -j | jq '.[].class'` if you need the window class for a
separate rule in `windowrules.lua`.

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
| 5.5 min | Screen off: `scripts/dpms.sh off` |
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

**Dispatch a one-off action** — the argument is Lua, not the old syntax:
```bash
hyprctl dispatch 'hl.dsp.exec_cmd("ghostty")'
hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })'
hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'

# move a window by class without following it (the old movetoworkspacesilent)
hyprctl dispatch 'hl.dsp.window.move({ workspace = 2, window = "class:brave-browser", follow = false })'
```

`hl.dsp.dpms` accepts `on`/`enable`, `off`/`disable`, `toggle`, plus an
optional `monitor`.

From a script, `hypr_dpms on|off [monitor]` in `hypr-lib.sh` picks the right
form for whichever manager is live.

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

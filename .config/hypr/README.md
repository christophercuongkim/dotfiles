# Hyprland Configuration

## Quick Start

**Add a keybinding** — open `keybinds.conf` and add a `bind` line:
```
bind = $mod, T, exec, alacritty
```
Reload with `hyprctl reload` or restart Hyprland.

**Add a window rule** — open `windowrules.conf` and add a `windowrulev2` line:
```
windowrulev2 = float, class:^(pavucontrol)$
```

**Change monitor layout** — edit `monitors.conf`. Reload applies immediately:
```
hyprctl reload
```

**Apply a single setting without reloading** — use `hyprctl keyword`:
```
hyprctl keyword decoration:rounding 8
hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"
```

---

## Structure

| Path | Description |
|---|---|
| `hyprland.conf` | Entry point; defines global variables and sources all other files |
| `monitors.conf` | Monitor layout, HiDPI scaling, lid-switch bindings |
| `input.conf` | Touchpad and keyboard input settings |
| `autostart.conf` | Applications launched on session start; staggered workspace placement |
| `appearance.conf` | Animations, window decorations, rounding, opacity |
| `keybinds.conf` | All keyboard and mouse bindings |
| `windowrules.conf` | Per-application window rules (currently empty, ready to populate) |
| `hypridle.conf` | Idle timeout chain: dim → lock → screen off → suspend |
| `hyprlock.conf` | Lock screen layout: blurred screenshot background, clock, password field |
| `hyprpaper.conf` | Wallpaper assignment per monitor |
| `scripts/swap-monitors.sh` | Swaps the x-positions of two external monitors at runtime |
| `scripts/toggle-trackpad.sh` | Toggles the touchpad enabled/disabled state via hyprctl |
| `scripts/position-monitor.sh` | Moves focused monitor adjacent to nearest (or chosen) monitor |
| `scripts/reset-monitors.sh` | Resets all monitors to default layout (eDP-1 at origin, externals left) |

**Global variables** (defined in `hyprland.conf`):

| Variable | Value |
|---|---|
| `$mod` | `SUPER` |
| `$terminal` | `ghostty` |
| `$file_manager` | `dolphin` |
| `$ss` | `hyprshot` |

---

## Monitors

**Current configuration** (`monitors.conf`):

```
monitor = eDP-1, preferred, 0x0, 1.5        # laptop display, 1.5x HiDPI scale
monitor = , highrr, auto-left, 1            # any other monitor: high refresh, auto-placed left, 1x scale
```

The catch-all rule (`monitor = , highrr, auto-left, 1`) applies to every monitor that does not match an explicit rule. New external monitors are placed to the left of the laptop screen at their highest refresh rate automatically.

**Lid switch** — the laptop display is disabled when the lid closes and re-enabled (with a 0.5 s delay to let hardware settle) when the lid opens:

```
bindl = , switch:on:Lid Switch,  exec, hyprctl keyword monitor "eDP-1, disable"
bindl = , switch:off:Lid Switch, exec, sleep 0.5 && hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5" && hyprctl dispatch dpms on eDP-1
```

**Runtime monitor changes** — use `hyprctl keyword`:
```bash
# Disable a monitor
hyprctl keyword monitor "HDMI-A-1, disable"

# Change scale on the fly
hyprctl keyword monitor "eDP-1, preferred, 0x0, 2"

# Reposition a monitor
hyprctl keyword monitor "DP-1, 1920x1080@144, 1920x0, 1"
```

**Swap two external monitors** — `Super + M` runs `scripts/swap-monitors.sh`, which reads the current x-positions of both external monitors via `hyprctl monitors -j` and swaps them. Requires `jq`.

**Reposition a monitor** — `Super + Shift + Alt + H/J/K/L` runs `scripts/position-monitor.sh`, moving the focused monitor adjacent to the nearest other monitor (centered on the perpendicular axis). With 3+ monitors, rofi prompts to pick the reference. Note: run `Super + Shift + M` to reset layout after `hyprctl reload` before repositioning.

**Reset monitor layout** — `Super + Shift + M` runs `scripts/reset-monitors.sh`, placing eDP-1 at origin and all externals to the left. Use this after `hyprctl reload` to restore clean positions.

---

## Keybindings

`$mod` = Super (Windows key).

### Applications

| Binding | Action |
|---|---|
| `Super + Return` | Open terminal (ghostty) |
| `Super + B` | Open Firefox |
| `Super + grave` | Lock screen (hyprlock) |
| `Super + Space` | App launcher (rofi drun) |
| `Super + Shift + S` | Screenshot region (hyprshot → `~/Pictures/screen_shots`) |
| `Super + Shift + T` | Toggle trackpad on/off |
| `Super + M` | Swap external monitor positions |
| `Super + Shift + M` | Reset all monitors to default layout (externals left of laptop) |
| `Super + XF86AudioPlay` | Launch Spotify |

### Window Management

| Binding | Action |
|---|---|
| `Super + H/J/K/L` | Move focus left/down/up/right |
| `Super + X` | Close active window |
| `Super + F` | Toggle fullscreen |
| `Super + V` | Toggle floating |
| `Super + Ctrl + Arrow` | Resize active window by 20 px |
| `Super + LMB drag` | Move floating window |
| `Super + RMB drag` | Resize floating window |

### Workspaces

| Binding | Action |
|---|---|
| `Super + 1-5` | Switch to workspace 1-5 |
| `Super + Shift + 1-5` | Move active window to workspace 1-5 |
| `Super + Shift + H` | Move window to previous workspace |
| `Super + Shift + L` | Move window to next workspace |
| `Super + Shift + J` | Move window to next existing workspace |
| `Super + Shift + K` | Move window to previous existing workspace |
| `Super + N` | Switch to next empty workspace |
| `Super + Shift + N` | Switch to next empty workspace (offset -1) |
| `Super + Tab` | Next workspace on current monitor |
| `Super + Shift + Tab` | Swap active workspaces between current and next monitor |

### Monitor Focus

| Binding | Action |
|---|---|
| `Super + Ctrl + H/J/K/L` | Focus monitor left/down/up/right |
| `Super + Ctrl + Tab` | Focus next monitor |
| `Super + Ctrl + Shift + Tab` | Focus previous monitor |
| `Super + Alt + H/J/K/L` | Move current workspace to monitor in direction |
| `Super + Alt + Tab` | Move current workspace to next monitor |
| `Super + Alt + Shift + Tab` | Move current workspace to previous monitor |
| `Super + Shift + Alt + H/J/K/L` | Reposition focused monitor adjacent to nearest (or rofi-picked) monitor |

### Media Keys

| Binding | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume +5% (pipewire via wpctl) |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play/pause (playerctl) |
| `XF86AudioPrev` | Previous track |
| `XF86AudioNext` | Next track |
| `XF86MonBrightnessUp` | Brightness +10% (brightnessctl) |
| `XF86MonBrightnessDown` | Brightness -10% |

---

## Window Rules

`windowrules.conf` is currently empty and ready to populate. Add rules in `windowrulev2` format:

```
# Float a specific app
windowrulev2 = float, class:^(pavucontrol)$

# Open an app on a specific workspace
windowrulev2 = workspace 2, class:^(firefox)$

# Pin a floating window (stays on all workspaces)
windowrulev2 = pin, class:^(obs)$

# Force a specific size
windowrulev2 = size 800 600, class:^(mpv)$

# Suppress maximize for apps that request it
windowrulev2 = suppressevent maximize, class:.*
```

Match on `class`, `title`, `tag`, `workspace`, `floating`, `fullscreen`, and more. See the [Hyprland wiki](https://wiki.hyprland.org/Configuring/Window-Rules/) for the full list of properties and rules.

---

## Autostart

The startup sequence in `autostart.conf` runs in three ordered phases:

**Phase 1 — Session environment and services** (immediate):
1. Export `DISPLAY`, `WAYLAND_DISPLAY`, `HYPRLAND_INSTANCE_SIGNATURE`, and `XDG_CURRENT_DESKTOP` into the systemd user environment, then restart `hyprland-session.target`.
2. Start `hyprpolkitagent` (authentication agent).
3. Start `hypridle` (idle/lock daemon).
4. Start `gnome-keyring-daemon` (secrets and SSH keys).
5. Start `hyprpaper` (wallpaper).
6. Set cursor theme: `Future-Cyan-Hyprcursor_Theme` at size 40.
7. Start `blueman-applet` (Bluetooth tray).

**Phase 2 — Lock and workspace binding** (immediate, blocks until unlocked):
```
exec-once = hyprlock || hyprctl dispatch exit && sleep 0.5 && { ... bind workspaces to external monitor ... }
```
Locks on start. After unlock, workspaces 1-4 are bound to the first external monitor (falls back to `eDP-1` if none is connected).

**Phase 3 — App launch** (staggered delays):
| Delay | App |
|---|---|
| 1 s | `ghostty` |
| 1.5 s | `brave` |
| 2 s | `spotify` |
| 2.5 s | `1password` |

**Phase 4 — Move windows to workspaces** (generous delays for slow startup):
| Delay | App class | Target workspace |
|---|---|---|
| 5 s | `com.mitchellh.ghostty` | 1 |
| 6 s | `brave-browser` | 2 |
| 7 s | `spotify` | 3 |
| 8 s | `1password` | 4 |

**Adding a new autostart app:**
```
exec-once = sleep 3 && myapp
exec-once = sleep 9 && hyprctl dispatch movetoworkspacesilent 5,class:^(myapp)$
```
Use `hyprctl clients -j | jq '.[].class'` to find the correct window class after the app is running.

---

## Appearance

Configured in `appearance.conf`.

**Decorations:**

| Property | Value |
|---|---|
| `rounding` | 10 px |
| `rounding_power` | 2.0 |
| `active_opacity` | 1.0 (fully opaque) |
| `inactive_opacity` | 1.0 (fully opaque) |
| `fullscreen_opacity` | 1.0 |
| `dim_inactive` | false |

To enable inactive window dimming:
```
hyprctl keyword decoration:dim_inactive true
hyprctl keyword decoration:dim_strength 0.3
```

**Animations** use a custom bezier curve (`myBezier = 0.05, 0.9, 0.1, 1.0`) applied to window open/close, border, fade, and workspace transitions. To disable all animations:
```
hyprctl keyword animations:enabled false
```

**Wallpaper** (`hyprpaper.conf`) — currently set only for `eDP-1`:
```
wallpaper {
  monitor = eDP-1
  path = /home/chriskim/wallpapers/jjk_wallpaper.jpg
  fit_mode = cover
}
```
Add a `wallpaper { monitor = HDMI-A-1; path = ... }` block for each additional monitor.

---

## Idle & Lock

Managed by `hypridle` (config in `hypridle.conf`) and `hyprlock` (config in `hyprlock.conf`).

### Timeout chain

| Timeout | Event |
|---|---|
| 2.5 min (150 s) | Dim screen: `brightnessctl -s set 10` (saves current brightness, sets to ~4%) |
| 2.5 min (150 s) | Turn off keyboard backlight |
| 5 min (300 s) | Lock screen: run `hyprlock` (skipped if already running) |
| 5.5 min (330 s) | Screen off: `hyprctl dispatch dpms off` |
| 30 min (1800 s) | Suspend: `systemctl suspend` |

On resume from each timeout, the previous state is restored (brightness, DPMS, screen).

**Lock before suspend** — `hypridle` runs `hyprlock` in `before_sleep_cmd` so the screen is locked even on manual suspend (`systemctl suspend`).

**Manual lock** — `Super + grave` (backtick).

### Hyprlock features

Lock screen layout (`hyprlock.conf`):
- Background: blurred screenshot of the desktop (3 passes), applied to all monitors.
- Clock: large time label (90 pt, top-right), date below it (25 pt, updates every 60 s).
- Password input field: centered, gradient outline, rounded corners (15 px), shows PAM failure message on wrong password.
- Keyboard layout indicator: clickable label that cycles layouts via `hyprctl switchxkblayout all next`.
- Fingerprint authentication: enabled; shows "Scan fingerprint to unlock" / "Scanning..." messages.
- Clear password buffer: `Esc`, `Ctrl+U`, or `Ctrl+Backspace`.
- Animations: fade in/out for the overlay and input field dots.

---

## Reload

**Full reload** — re-reads all config files:
```bash
hyprctl reload
```

**Runtime keyword change** — applies a single setting immediately without reloading:
```bash
hyprctl keyword <section>:<key> <value>

# Examples
hyprctl keyword decoration:rounding 0
hyprctl keyword animations:enabled false
hyprctl keyword general:gaps_out 10
hyprctl keyword monitor "eDP-1, preferred, 0x0, 2"
hyprctl keyword device[pixa3854:00-093a:0274-touchpad]:enabled false
```

Keyword changes are **not persistent** — they revert on the next `hyprctl reload` or Hyprland restart. To make a change permanent, edit the relevant `.conf` file.

**Dispatch a one-off action:**
```bash
hyprctl dispatch exec ghostty
hyprctl dispatch movetoworkspace 3
hyprctl dispatch dpms off
```

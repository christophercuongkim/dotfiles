# Waybar Config

## Quick Start

**Reload waybar** (after any config or CSS change):
```sh
pkill waybar && waybar &
```

**Add a module:**
1. Add the module name to `modules-left`, `modules-center`, or `modules-right` in `config.jsonc`.
2. Add a configuration block for it (same file).
3. Add styling for `#module-name` in `style.css`.
4. Reload.

**Remove a module:**
1. Delete its entry from the `modules-*` array in `config.jsonc`.
2. Optionally remove its config block and CSS rules.
3. Reload.

**Change styling:**
Edit `style.css` and reload. All colors are plain hex values — search for the color you want to change and replace it directly (no CSS variable layer).

---

## Structure

| File | Purpose |
|------|---------|
| `config.jsonc` | Main bar config — module list, positions, per-module settings |
| `style.css` | All visual styling — colors, fonts, spacing, animations |
| `volume_slider.py` | Floating Tk GUI slider for PulseAudio volume (run manually) |
| `power_menu.xml` | GTK menu definition for the power button (`custom/power`) |

---

## Modules

### Left
| Module | What it shows |
|--------|--------------|
| `hyprland/workspaces` | Active workspaces with per-app Nerd Font icons; scroll to switch |
| `hyprland/submap` | Current Hyprland submap name (hidden when none active) |
| `mpris` | Now-playing info from any MPRIS player; click to play/pause, right-click next, middle-click previous |

### Center
| Module | What it shows |
|--------|--------------|
| `hyprland/window` | Focused window title (max 50 chars) |

### Right (left to right)
| Module | What it shows |
|--------|--------------|
| `idle_inhibitor` | Toggle to prevent sleep; icon changes when active |
| `pulseaudio` | Speaker + mic volume; click opens `pavucontrol`, right-click mutes |
| `bluetooth` | BT status / connected device + battery; click opens `blueman-manager` |
| `network` | WiFi SSID + signal or Ethernet IP; click opens `nm-connection-editor` |
| `power-profiles-daemon` | Current power profile icon (performance / balanced / power-saver) |
| `temperature` | CPU temperature; icon and color change at critical threshold (80 °C) |
| `backlight` | Screen brightness percentage |
| `battery` | Battery level with charging/plugged icons; alt-click shows time remaining |
| `tray` | System tray icons (15 px, 10 px spacing) |
| `clock` | `HH:MM`; alt-click shows `YYYY-MM-DD`; tooltip shows calendar |
| `custom/power` | Power button — opens GTK menu for suspend / hibernate / shutdown / reboot |

---

## Styling

**Font:** `JetBrainsMono Nerd Font Mono` (primary) + `Font Awesome 6 Free` (fallback), 13 px.

**Color palette** (all defined inline in `style.css`):

| Role | Value |
|------|-------|
| Bar background | `#000000` |
| Bar bottom border / accent | `#ff0000` (red) |
| Module background | `#111111` |
| Hover background | `#222222` |
| Inactive workspace text | `#888888` |
| Active workspace bg | `#ff0000` |
| Battery warning | `#ff9900` |
| Battery critical | `#ff0000` (blink animation) |
| Battery charging | `#00ff00` |
| Bluetooth connected | `#00aaff` |
| Network disconnected | `#ff4444` |
| MPRIS playing | `#1db954` (Spotify green) |
| MPRIS paused | `#888888` |

**Module pill shape:** 4 px border-radius, 2 px margin, 8 px horizontal padding.

**Animations:** Battery critical state blinks between `#ff0000` background and `#111111` background at 0.5 s.

To retheme, the main values to swap are the `#ff0000` accent and `#000000`/`#111111` backgrounds.

---

## Scripts

### `volume_slider.py`

A small standalone Tkinter window (200×50 px, top-right of screen) with a horizontal slider that reads and sets PulseAudio volume on the default sink via `pulsectl`.

**Dependencies:** `python3`, `tkinter`, `pulsectl` (`pip install pulsectl`)

**Run manually:**
```sh
python3 ~/.config/waybar/volume_slider.py
```

This is not wired into the waybar config — it is a utility you launch separately (e.g., bound to a key in your Hyprland config).

### `power_menu.xml`

A GTK `GtkMenu` definition consumed by the `custom/power` module. Defines four menu items:

| Label | Action |
|-------|--------|
| Suspend | `systemctl suspend` |
| Hibernate | `systemctl hibernate` |
| Shutdown | `shutdown` |
| Reboot | `reboot` |

To add or reorder items, edit the `<child>` entries in this file and update the matching `menu-actions` map in `config.jsonc`.

---

## Reload

```sh
pkill waybar && waybar &
```

Or if you have a Hyprland keybind that dispatches `exec, pkill waybar && waybar &`, use that instead.

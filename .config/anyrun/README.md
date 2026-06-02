# anyrun

Keyboard-driven launcher for Wayland. Dark red/black theme with JetBrainsMono.

---

## Quick Start

**Add a plugin** — add its path to `plugins: [...]` in `config.ron` and create a corresponding `<plugin>.ron` config file in this directory.

**Change appearance** — edit `style.css`. Color variables are at the top; selectors are documented in the [Styling](#styling) section below.

**Launch anyrun manually:**
```sh
anyrun
```

**Switch hyprland from rofi back to anyrun** — in `.config/hypr/keybinds.conf`, change:
```
bind = $mod, space, exec, rofi -show drun
```
to:
```
bind = $mod, space, exec, anyrun
```
Then rename `config.ron.old` to `config.ron`.

---

## Launch

| Launcher | Keybind | Status |
|----------|---------|--------|
| rofi | `$mod, Space` | **active** |
| anyrun | `Super+Space` (in `config.ron.old`) | inactive — no `config.ron` present |

The hyprland keybind (`keybinds.conf` line 7) currently launches rofi. anyrun is installed and configured but not wired to the hotkey. To switch, see [Quick Start](#quick-start) above.

---

## Structure

| File | Purpose |
|------|---------|
| `config.ron.old` | Previous anyrun config (600x400 window, `Super+Space` hotkey, 9 plugins listed). Rename to `config.ron` to activate. |
| `applications.ron` | App launcher plugin config |
| `shell.ron` | Shell command plugin config |
| `websearch.ron` | Web search plugin config |
| `dictionary.ron` | Dictionary lookup plugin config |
| `symbols.ron` | Unicode symbol picker plugin config |
| `translate.ron` | Translation plugin config |
| `style.css` | GTK CSS theme — dark red/black with glowing selection |

---

## Plugins

All plugins listed below have a corresponding `.ron` config file. The `config.ron.old` also references `rink`, `kidex`, and `randr` which do not have per-plugin config files here (they use defaults).

| Plugin | Prefix | Notes |
|--------|--------|-------|
| applications | *(none — matches everything)* | Shows `.desktop` entries from `/run/current-system/sw/share/applications`; max 5 entries; desktop actions enabled; launches terminal apps in `ghostty -e {}` |
| symbols | *(none — matches everything)* | Unicode symbols + custom entry: `shrug` → `¯\_(ツ)_/¯`; max 3 entries |
| translate | `:` | Format: `:<target lang> <text>` or `:<src>><target> <text>`; delimiter `>`; max 3 entries |
| shell | `:sh` | Runs commands via `zsh` |
| dictionary | `:def` | Defines a word; max 5 entries |
| websearch | `?` | Searches Google; format: `?<query>` |

**Note on prefix conflicts:** `translate` uses `:` and `shell` uses `:sh`, `dictionary` uses `:def` — the longer prefixes take precedence.

---

## Styling

`style.css` is a GTK CSS file. Colors are defined as variables at the top and referenced throughout.

### Color variables

| Variable | Value | Role |
|----------|-------|------|
| `@bg-color` | `#121212` | Very dark background |
| `@fg-color` | `#ff4c4c` | Primary text (red) |
| `@primary-color` | `#ff4c4c` | Borders, caret, accents |
| `@secondary-color` | `#aa0000` | Darker red for contrast |
| `@selected-bg-color` | `@primary-color` | Selected item background |
| `@selected-fg-color` | `#ffffff` | Text on selected item |

### Key CSS selectors

| Selector | Role |
|----------|------|
| `#window` | Main window — transparent background |
| `box#main` | Container — transparent, no border |
| `entry#entry` | Search input — 24px, dark bg, red border, 8px radius |
| `list#main` | Results list — transparent background |
| `#plugin` | Individual result row — dark bg, 6px radius, fade transition |
| `#plugin:selected`, `#plugin:hover` | Selected/hovered row — red bg, white text, glowing red box-shadow, 6px red left border |
| `#match` | Match text within a row — 16px, white |
| `label#match-desc` | Description label — `@fg-color` |
| `label#plugin` | Plugin name label — 16px, `@fg-color` |

Font stack: `"JetBrainsMono Nerd Font", monospace` at 16px base (entry overrides to 24px).

The selection glow effect is a double box-shadow:
```css
box-shadow:
  0 0 8px 2px rgba(255, 76, 76, 0.8),
  0 0 15px 5px rgba(255, 76, 76, 0.5);
```

---

## NixOS wiring

**Installed** via the `anyrun` flake input in `modules/features/desktop/anyrun.nix`:
```nix
environment.systemPackages = [
  inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.anyrun-with-all-plugins
];
```
This installs the `anyrun-with-all-plugins` package, which bundles all official plugins.

**Config symlinked** via home-manager in `modules/features/dotfiles/symlinks.nix`:
```nix
".config/anyrun".source = "${dotfilesPath}/.config/anyrun";
```
The entire `.config/anyrun/` directory is symlinked from this dotfiles repo into `~/.config/anyrun`.

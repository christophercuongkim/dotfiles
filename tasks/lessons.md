# Lessons Learned

## Hyprland 0.53+ Window Rules

**Problem:** Window rules weren't working - apps loading on wrong workspaces.

**Root cause:** Hyprland 0.53 completely rewrote the windowrule syntax.

**Correct syntax (0.53+):**
```
windowrule = match:class <classname>, <action>
```

**Example:**
```
windowrule = match:class spotify, workspace 3 silent
```

**Common mistakes:**
- Using `class:value` or `class=value` (old syntax) - gives "missing a value" error
- Using `windowrulev2` - deprecated in 0.53+
- Wrong order: action must come AFTER the match condition
- Case-sensitive class names: use `spotify` not `Spotify`, `1password` not `1Password`

**How to verify class names:**
```bash
hyprctl clients -j | jq -r '.[] | .class' | sort -u
```

**How to test a rule without restart:**
```bash
hyprctl keyword windowrule "match:class test, workspace 1 silent"
```

**Window rules + exec-once interaction:**
- Window rules are registered when config loads
- exec-once spawns apps
- Rules are evaluated when each window is created
- `silent` prevents focus switching when window moves to workspace

## Hyprpaper 0.8+ Config Format

**Problem:** Wallpaper not displaying - "Monitor eDP-1 has no target: no wp will be created"

**Root cause:** Hyprpaper 0.8+ changed config syntax from key-value to block format.

**Old syntax (broken):**
```
preload = /path/to/wallpaper.jpg
wallpaper = eDP-1,/path/to/wallpaper.jpg
```

**Correct syntax (0.8+):**
```
wallpaper {
  monitor = eDP-1
  path = /path/to/wallpaper.jpg
  fit_mode = cover
}
```

**Key changes:**
- No more `preload` line needed
- Uses block syntax with `wallpaper { ... }`
- `fit_mode` replaces old scaling options (values: cover, contain, fill, etc.)
- Empty `monitor =` acts as fallback for all monitors

**Config location change:**
- Old: `~/.config/hypr/hyprpaper.conf`
- New: `~/.config/hyprpaper/hyprpaper.conf`

**Reference:** https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/

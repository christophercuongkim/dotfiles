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

## Persistent vs One-Time Workspace Assignment

**Problem:** Apps always open on their assigned workspace, even when launched manually from a different workspace.

**Root cause:** `windowrule` with `workspace X silent` is persistent - it applies to EVERY window created by that app, forever.

**Solution:** Use `movetoworkspacesilent` dispatch command for one-time startup placement:
```bash
exec-once = sleep 1 && ghostty && sleep 0.3 && hyprctl dispatch movetoworkspacesilent 1,class:com.mitchellh.ghostty
```

**Key difference:**
- `windowrule = workspace X silent` → Persistent, every window goes to X
- `hyprctl dispatch movetoworkspacesilent X,class:app` → One-time, only moves existing window

**Use case:** You want Brave on workspace 2 at startup, but later want to open a new Brave window on workspace 5.

## exec-once with movetoworkspacesilent

**Problem:** Apps all launching on workspace 1 despite move commands.

**Root cause:** Using `&&` chains without backgrounding apps:
```bash
# BROKEN - if app blocks, move never runs; if app forks, 0.3s may be too short
exec-once = sleep 1 && app && sleep 0.3 && hyprctl dispatch movetoworkspacesilent N,class:app
```

**Correct pattern:**
```bash
# WORKS - app backgrounded, staggered launches, longer wait for window
exec-once = sleep 1 && ghostty & sleep 2 && hyprctl dispatch movetoworkspacesilent 1,class:com.mitchellh.ghostty
exec-once = sleep 2 && brave & sleep 2 && hyprctl dispatch movetoworkspacesilent 2,class:brave-browser
```

**Key fixes:**
- Use `&` after app to background it - shell continues regardless of whether app blocks
- Stagger app launches (1s, 2s, 3s...) to avoid race conditions
- Use 2s delay before move (0.3s is often too short for window creation)
- The `&` goes BEFORE the `sleep` that precedes the move command

## hyprctl dispatch exec with [workspace N silent]

**Problem:** `hyprctl dispatch exec '[workspace 2 silent] brave'` doesn't work - app lands on workspace 1.

**Root cause:** The `[workspace N silent]` rule is **temporary** and applies when the **window is created**, not when the command runs.

**Why some apps work and others don't:**
- Fast apps (1Password, Ghostty) → window created within delay → rule applied ✓
- Slow apps (Brave, Spotify, Electron) → window created after next command runs → rule expired ✗

**Broken pattern:**
```bash
# 0.5s between commands isn't enough for slow apps
exec-once = ... && hyprctl dispatch exec '[workspace 2 silent] brave' && sleep 0.5 && hyprctl dispatch exec '[workspace 3 silent] spotify'
```

**Correct pattern:** Separate launching from positioning:
```bash
# Phase 1: Launch all apps
exec-once = sleep 1 && brave
exec-once = sleep 1.5 && spotify

# Phase 2: Move windows after they definitely exist (generous delays for slow apps)
exec-once = sleep 6 && hyprctl dispatch movetoworkspacesilent 2,class:brave-browser
exec-once = sleep 7 && hyprctl dispatch movetoworkspacesilent 3,class:spotify
```

**Key insight:** Don't rely on temporary rules for slow-starting apps. Move them after they exist.

## SUPERSEDED (Lua config): exec rules now work, drop the sleep ladder

The two lessons above — "stagger app launches" and "hyprctl dispatch exec with
[workspace N silent]" — described a real hyprlang limitation. Under the Lua
config that limitation is gone.

`hl.exec_cmd` takes a window rule as its second argument, attached to the
**spawn request** rather than being a temporary global rule that can expire:

```lua
hl.exec_cmd("brave", { workspace = "2 silent" })
```

Source: `hlExecCmd` in `LuaBindingsToplevel.cpp` builds the rule via
`buildRuleFromTable` and passes it into `executor()->spawn(SExecRequest{...})`.
Because the rule travels with that specific process, a slow-starting app cannot
outrun it — which was the entire failure mode above.

Verified live: `hl.exec_cmd("kitty", { workspace = "5 silent" })` put kitty on
workspace 5 with focus never leaving workspace 1.

**So:** no launch stagger, no `sleep N && hyprctl dispatch movetoworkspacesilent`
second phase. Four lines replace eight, and placement no longer depends on
guessing how long an app takes to open a window.

**AMENDED — exec rules only work for single-process apps.** The rule is attached
to the PID `hl.exec_cmd` spawns, so it matches only a window that comes from
that exact process. Brave launches through a wrapper that re-execs; its window
belongs to a different PID, the rule silently misses, and the window lands on
the focused workspace.

The live test above used kitty, which is single-process — as are ghostty,
spotify and 1password. All four matched, which is why this read as a general
result. Only a cold boot with brave in the set exposed it.

Startup placement now matches the window instead (`autostart.lua`, commit
`83c8c5f`):

```lua
hl.on("window.open", function(w)
    local ws = placements[w.class]
    if not ws then return end
    placements[w.class] = nil          -- one-shot per class
    hl.dispatch(hl.dsp.window.move({ workspace = ws, window = "address:" .. w.address, follow = false }))
end)
```

PID-independent, so it works for all four. Costs a possible brief flash on the
wrong workspace, since placement lands just after the window maps.

**The general lesson:** verifying a spawn-time rule against a single-process app
proves nothing about wrapper-launched ones. Electron and browser packages are
the usual re-exec offenders. Test placement with the awkward app, not the easy
one.

Any window-rule effect works in that table, not just `workspace`. An unknown key
is a hard error (`buildRuleFromTable: unknown effect '...'`), not a silent
no-op — unusual and welcome in this codebase.

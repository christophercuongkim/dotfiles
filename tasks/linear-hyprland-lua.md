# Linear: Hyprland Lua config migration

**CREATED.** Project + issues live in Linear team `Christopherkim` (CHR).

Project: https://linear.app/christopherkim/project/hyprland-lua-config-migration-3e94a7acd149

| Ticket | Issue |
|---|---|
| CHR-110 | Spike: close the two open Lua API questions |
| CHR-111 | Scaffold hyprland.lua with require() split |
| CHR-112 | Port monitors.conf to hl.monitor |
| CHR-113 | Port input.conf and appearance.conf |
| CHR-114 | Port keybinds.conf (~60 binds) |
| CHR-115 | Port autostart.conf to hl.on("hyprland.start") |
| CHR-116 | Port windowrules.conf placeholder |
| CHR-117 | Audit the six hypr helper scripts for Lua compatibility |
| CHR-119 | Cutover: delete .conf files and update README |
| CHR-118 | Bump home-manager (no project — DONE, commit 6e4a1c7) |

Blocking graph: CHR-110 blocks CHR-111/112/117; CHR-111 blocks 112-116;
112-117 all block CHR-119.

The section below is the source text the tickets were created from.

---

## PROJECT

**Name:** Hyprland Lua config migration

**Summary:** Port the Hyprland compositor config in `dotfiles/.config/hypr/` from the
deprecated hyprlang `.conf` format to the new Lua format before upstream drops
hyprlang support.

**Description:**

Hyprland deprecated its hyprlang config format in 0.55 in favour of Lua. Per the
upstream announcement: *"The old hyprlang syntax will continue to be supported for
1 - 2 releases starting from 0.55. After that, hyprlang will be dropped."* New config
features are no longer being added to hyprlang.

We currently run **0.56.2** (from nixpkgs), so the removal lands roughly at 0.57–0.58 —
one or two nixpkgs bumps away. The compositor already looks for `hyprland.lua` first
and logs the fallback:

```
[cfg] Lua config not found, using legacy config at /home/chriskim/.config/hypr/hyprland.conf
```

**In scope** — compositor config only:
`hyprland.conf`, `monitors.conf`, `input.conf`, `autostart.conf`, `appearance.conf`,
`keybinds.conf`, `windowrules.conf`

**Out of scope** — separate hypr* applications, still hyprlang, unaffected:
`hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf`

**Migration is low-risk by construction:** Hyprland picks `hyprland.lua` over
`hyprland.conf` when both exist (checked once at startup). We can land the Lua config
alongside the `.conf` files, test it, and only delete the old ones once proven.

**Links:**
- https://hypr.land/news/26_lua/
- https://wiki.hypr.land/Configuring/Start/
- https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

---

## ISSUES

### HYPR-1 — Spike: close the two open API questions
**Estimate:** S · **Priority:** Urgent · **Blocks:** everything else

Two unknowns must be resolved before writing any port, because both can change the
shape of the whole migration.

1. **Lid-switch binds.** `monitors.conf` has:
   ```
   bindl = , switch:on:Lid Switch, exec, ~/.config/hypr/scripts/lid-switch.sh close
   bindl = , switch:off:Lid Switch, exec, ~/.config/hypr/scripts/lid-switch.sh open
   ```
   The upstream `example/hyprland.lua` documents no `switch:` equivalent. Find the Lua
   form (or the event-handler equivalent via `hl.on(...)`).

2. **`hyprctl keyword` under a Lua config.** Six helper scripts shell out to
   `hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"` — a hyprlang string. Confirm
   whether `keyword` still accepts hyprlang values when the session was started from a
   Lua config, or whether these must move to `hyprctl eval` + `hl.monitor({...})`.

**How:** 0.56 ships `hyprctl eval <lua>` and a built-in Lua REPL. `hyprctl reload
full-reset` recreates the config context and can switch between lua/hyprlang live, so
both questions are answerable on the running machine without a logout.

**Done when:** both answers are written into `tasks/todo.md`, and HYPR-2 / HYPR-8 are
updated with the concrete approach.

---

### HYPR-2 — Scaffold `hyprland.lua` with `require()` split
**Estimate:** S · **Depends on:** HYPR-1

Create `.config/hypr/hyprland.lua` mirroring the existing modular layout, using
`require("monitors")` etc. in place of `source =`. Leave every `.conf` file in place —
Hyprland prefers the `.lua`, so this is a reversible cutover (delete the `.lua` to roll
back instantly).

Port the `hyprland.conf` variables to Lua locals:
```lua
local mod         = "SUPER"
local terminal    = "ghostty"
local fileManager = "dolphin"
local ss          = "hyprshot"
```

**Done when:** Hyprland starts from the Lua config, `hyprctl configerrors` is clean,
and the startup log no longer says "Lua config not found".

---

### HYPR-3 — Port `monitors.conf`
**Estimate:** S · **Depends on:** HYPR-2

```lua
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.5 })
hl.monitor({ output = "",      mode = "preferred", position = "auto-left", scale = 1 })
```
Plus the lid-switch binds, using whatever HYPR-1 established.

Note: the working tree already has an uncommitted change here (`highrr` → `preferred`
for external monitors). Port the *current* intent, not the committed version.

**Done when:** laptop display scales at 1.5, external monitors land auto-left at native
mode, and lid open/close still drives `lid-switch.sh`.

---

### HYPR-4 — Port `input.conf` and `appearance.conf`
**Estimate:** S · **Depends on:** HYPR-2

Input is a direct table translation:
```lua
hl.config({
    input = {
        natural_scroll = true,
        touchpad = { natural_scroll = true },
    },
})
```

Appearance splits in two — `decoration` is a `hl.config` table, but the animation block
becomes `hl.curve` + one `hl.animation` call per leaf:
```lua
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
```

**Done when:** natural scroll works on trackpad and mouse, rounding/opacity/dim values
match, and window animations look unchanged.

---

### HYPR-5 — Port `keybinds.conf`
**Estimate:** M · **Depends on:** HYPR-2 · **Largest single file (~60 binds)**

Mapping rules:
- `bind`   → `hl.bind("SUPER + X", dispatcher)`
- `bindm`  → `{ mouse = true }`
- `bindl`  → `{ locked = true }`
- `bindel` → `{ locked = true, repeating = true }`
- `exec`   → `hl.dsp.exec_cmd(cmd)`
- `movefocus, l` → `hl.dsp.focus({ direction = "left" })`
- `killactive` → `hl.dsp.window.close()`, `togglefloating` → `hl.dsp.window.float({ action = "toggle" })`

Collapse the repetitive blocks with a loop instead of transcribing them line by line —
workspaces 1–5 switch + move is 10 lines of hyprlang, 4 lines of Lua:
```lua
for i = 1, 5 do
    hl.bind(mod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end
```
Same treatment for the four directional families (focus / move window to monitor /
move workspace to monitor / focus monitor), which are `h j k l` → `l d u r` tables.

Dispatchers with no obvious Lua equivalent in the upstream example — `swapactiveworkspaces`,
`movecurrentworkspacetomonitor`, `workspace, empty`, `workspace, m+1` — need looking up;
fall back to `hl.dsp.exec_cmd("hyprctl dispatch ...")` only as a last resort, and note
any that required it.

**Done when:** `hyprctl binds -j` lists the same set of binds as before the port
(diff the before/after JSON), and a manual pass over the monitor/workspace binds works.

---

### HYPR-6 — Port `autostart.conf`
**Estimate:** M · **Depends on:** HYPR-2 · **Most likely to need redesign**

`exec-once` becomes:
```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    -- ...
end)
```

The straight translation works, but the current file is three phases of `sleep N &&`
racing against app startup:
```
exec-once = sleep 5 && hyprctl dispatch movetoworkspacesilent 1,class:com.mitchellh.ghostty
exec-once = sleep 6 && hyprctl dispatch movetoworkspacesilent 2,class:brave-browser
...
```
This is exactly the kind of thing Lua's event handlers exist to fix — a window-open
event handler that matches on class and moves the window is deterministic, where the
sleeps are a guess that breaks on a slow boot.

Decide during the port: straight translation first (keeps the diff reviewable), then a
follow-up to replace the sleeps with real event handlers. Split into HYPR-6b if it grows.

**Done when:** all session services start, the lock-on-start flow still works, and the
four apps land on workspaces 1–4.

---

### HYPR-7 — Port `windowrules.conf`
**Estimate:** XS · **Depends on:** HYPR-2

File is a single comment line, no actual rules. Create the Lua equivalent as an empty
placeholder with a pointer to `hl.window_rule({ name, match = {...}, ... })` syntax so
the next rule added lands in the right shape.

---

### HYPR-8 — Audit the six helper scripts
**Estimate:** M · **Depends on:** HYPR-1 · **Highest risk of silent breakage**

The scripts are not config files, so they will not error at startup — they will just
stop working. Each needs checking against whatever HYPR-1 determined:

| Script | Call | Risk |
|---|---|---|
| `swap-monitors.sh` | `hyprctl keyword monitor "$mon,$res,${x}x${y},$scale"` | hyprlang string |
| `reset-monitors.sh` | `hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"` | hyprlang string |
| `position-monitor.sh` | `hyprctl keyword monitor "$focused, preferred, ..."` | hyprlang string |
| `lid-switch.sh` | `hyprctl keyword monitor "eDP-1, disable"` | hyprlang string |
| `toggle-trackpad.sh` | `hyprctl keyword "device[$TOUCHPAD]:enabled" false` | hyprlang keyword path |
| `keybind-help.sh` | `hyprctl binds -j \| jq '.dispatcher, .arg'` | IPC — check fields still populate under Lua binds |

`keybind-help.sh` reads via IPC rather than parsing config files, so it survives the
format change structurally — but its `format_action()` switch matches on dispatcher
names (`movefocus`, `killactive`, `togglefloating`, …). If Lua binds report different
dispatcher names in `hyprctl binds -j`, every label falls through to the default case.

Also note `reset-monitors.sh:15` still uses `highrr`, which contradicts the
`preferred` change now sitting uncommitted in `monitors.conf`. Reconcile while here.

**Done when:** every script is exercised by hand under the Lua config and behaves
identically.

---

### HYPR-9 — Cutover and cleanup
**Estimate:** S · **Depends on:** HYPR-3 … HYPR-8

- Full logout/login test (not just `hyprctl reload full-reset`) — the lua/conf choice
  is made once at startup, so a reload is not a faithful test of a cold boot.
- `hyprctl configerrors` clean.
- Delete the seven migrated `.conf` files.
- Update `.config/hypr/README.md` (12K, documents the old syntax throughout).
- Confirm `modules/features/dotfiles/symlinks.nix` needs no change — it symlinks the
  whole `.config/hypr` directory (`symlinks.nix:41`), so new files are picked up
  automatically. Note that `hyprpaper.conf` is *separately* symlinked at line 42 and
  stays hyprlang.

**Done when:** no `.conf` files remain for the compositor, a cold boot comes up clean,
and README matches reality.

---

## SEPARATE ISSUE (not part of the project)

### NIX-1 — Bump home-manager to clear `stdenv.isLinux` eval warnings ✅ DONE
**Estimate:** XS · **Status:** Done

```
evaluation warning: stdenv.isLinux is deprecated, use stdenv.hostPlatform.isLinux instead
evaluation warning: stdenv.isDarwin is deprecated, use stdenv.hostPlatform.isDarwin instead
```

Not our code — zero hits for `stdenv.is(Linux|Darwin)` in this repo. Source was the
pinned home-manager input (105 hits, e.g. `modules/systemd.nix:250`,
`modules/misc/nixpkgs.nix:146`), which upstream has since fixed.

Bumped `144f4e36` (2026-07-09) → `693e8ce0` (2026-09-04). New revision has 0 hits.
Verified with `nix eval --no-eval-cache` on
`.#nixosConfigurations.AppleII.config.system.build.toplevel.drvPath` — evaluates
clean, zero warnings.

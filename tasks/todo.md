# Plan: Remote laptop display via wayvnc + Tailscale

## Goal
Remote into AppleII (Framework, Hyprland/Wayland) and drive the real
desktop session over the tailnet. Secure by default: reachable only via
Tailscale, never the public internet.

## Why this design
- **wayvnc** = VNC server built for wlroots compositors. Hyprland is
  wlroots-based, so it mirrors the *live* physical session (not a separate
  headless X server). Standard VNC (x11vnc/TigerVNC) is X11-only — won't work.
- **Tailscale** already enabled (`modules/features/networking/tailscale.nix`)
  and the firewall already fully trusts `tailscale0`
  (`firewall.nix:25`). So the transport is already WireGuard-encrypted,
  device-authenticated, and invisible to internet scans. We just bolt the
  VNC server onto that trusted interface.
- Security model: **firewall default-denies; only `tailscale0` is trusted;
  5900 is NOT in global `allowedTCPPorts`.** => Binding wayvnc means it's
  reachable *only* from the tailnet. No public exposure possible.

## Current state (verified)
- `tailscale.nix` — `services.tailscale.enable = true` ✓
- `firewall.nix` — `trustedInterfaces = [ "tailscale0" ]`, default deny ✓
- `hyprland.nix` — wlroots compositor, UWSM session ✓
- Autostart uses `exec-once` (mako, hypridle…) AND a
  `hyprland-session.target` systemd user target (`autostart.conf:4`)
- Dotfiles land via home-manager `home.file` symlinks (`symlinks.nix`)
- Host wires features by name in `modules/hosts/AppleII.nix` imports list
- `wayvnc` 0.10.0 available in nixpkgs ✓

## Steps

### 1. New NixOS feature module — `modules/features/networking/wayvnc.nix`
- `flake.modules.nixos.wayvnc` following the repo's dendritic pattern.
- Install `pkgs.wayvnc` into `environment.systemPackages`.
- No port opened globally (firewall stays closed to WAN); rely on
  `tailscale0` trust.

### 2. Run wayvnc inside the Hyprland session — ON-DEMAND, TWO MODES (decided)
Two home-manager systemd **user** services, `PartOf`/`After`
`graphical-session.target`, **no `[Install]`/WantedBy** so neither
auto-starts. Both bind :5900 and `Conflicts=` each other (starting one
stops the other).
- **`wayvnc`** (plain) — mirrors whatever output is currently active. No
  monitor changes. `systemctl --user start wayvnc`.
- **`wayvnc-headless`** — create virtual output, then `eDP-1,disable`
  (laptop panel dark), serve the virtual output. On stop: remove the
  virtual output + `hyprctl reload` to restore eDP-1 from monitors.conf.
  `systemctl --user start wayvnc-headless`.
- Both inherit `WAYLAND_DISPLAY`/`HYPRLAND_INSTANCE_SIGNATURE` from the user
  env (already exported via `autostart.conf:4`
  `dbus-update-activation-environment`).

### 3. Wire the module into the host
- Add `nixos.wayvnc` to the Networking block in `modules/hosts/AppleII.nix`.

### 4. Bind address — `0.0.0.0:5900` (decided)
- Safe *because* the firewall default-denies and only `tailscale0` is
  trusted, so it's reachable from the tailnet and nowhere else. One line,
  no async-IP race.

### 5. wayvnc TLS auth — SKIPPED (decided)
- Rely on Tailscale (device auth + WireGuard encryption). No cert/password.

### 6. Headless output — INCLUDED as a SECOND mode (decided)
- `wayvnc` (plain): `wayvnc 0.0.0.0 5900`, no monitor changes.
- `wayvnc-headless` wrapper: create virtual output (`hyprctl output create
  headless`), set 1920x1080, `eDP-1,disable`, `wayvnc -o <out> 0.0.0.0
  5900`. On stop/crash: kill wayvnc + `hyprctl output remove <out>` +
  `hyprctl reload` (restores eDP-1). Drives the session with panel dark,
  no monitor.
- Create-headless-before-disable-eDP-1 ordering avoids the sole-output
  black-screen trap noted in monitors.conf.

### 7. (Optional, not in repo) Tailscale ACL hardening
- Restrict tailnet so only *your* devices reach port 5900 on AppleII.
- Lives in the Tailscale admin console. Snippet available on request.

### 8. Verify
- `nix flake check` / build the host config.
- `systemctl --user start wayvnc`, confirm listening (`ss -tlnp | grep 5900`).
- From another tailnet device: VNC viewer -> `<tailscale-ip>:5900`, confirm
  live session appears and input works.
- Confirm from a NON-tailnet network the port is unreachable (scan blocked).

## Decisions (from user)
1. **On-demand / manual** — do NOT auto-start. systemd user service with no
   `[Install]` section => runs only on `systemctl --user start wayvnc`.
   Use case: rare remote-in to click 1Password and unlock the SSH agent.
2. **Skip** wayvnc TLS auth — rely on Tailscale.
3. **Headless now** — wrapper creates a virtual output, serves it, removes it
   on stop. Drives the session lid-closed with no physical monitor.

## Final implementation
- `modules/features/networking/wayvnc.nix` defines BOTH:
  - `flake.modules.nixos.wayvnc` — `environment.systemPackages = [ wayvnc ]`
  - `flake.modules.homeManager.wayvnc` — on-demand user service running a
    `writeShellApplication` wrapper (`wayvnc-headless`) that:
    create headless output -> set 1920x1080 -> `wayvnc -o <out> 0.0.0.0 5900`
    -> on stop/crash, kill wayvnc + `hyprctl output remove <out>`.
- Wire `nixos.wayvnc` into `modules/hosts/AppleII.nix` (Networking block).
- Wire `homeManager.wayvnc` into `modules/outputs/home-manager.nix` imports.
- Bind `0.0.0.0:5900` — safe: firewall default-denies, only `tailscale0`
  trusted, 5900 not in `allowedTCPPorts`.

### Usage
```
systemctl --user start wayvnc     # enable when you need it
systemctl --user stop wayvnc      # tears down the headless output
# from another tailnet device:  vncviewer <applell-tailscale-ip>:5900
```

## Review
(to be filled after implementation)

---

# Plan: Hyprland hyprlang (.conf) → Lua config migration

## Why now
- Hyprland wiki: "Since Hyprland 0.55, hyprlang is deprecated in favor of lua."
- Announcement: "The old hyprlang syntax will continue to be supported for
  1 - 2 releases starting from 0.55. After that, hyprlang will be dropped."
  New config features are no longer added to hyprlang.
- We run **0.56.2** (nixpkgs `hyprland` 0.56.2). Drop lands ~0.57/0.58.
- Live log proof: `[cfg] Lua config not found, using legacy config at
  ~/.config/hypr/hyprland.conf`

## Scope — compositor only
Migrate: `hyprland.conf`, `monitors.conf`, `input.conf`, `autostart.conf`,
`appearance.conf`, `keybinds.conf`, `windowrules.conf`.
**Not affected** (separate hypr* apps, still hyprlang):
`hyprlock.conf`, `hypridle.conf`, `hyprpaper.conf`.

## Target shape
`~/.config/hypr/hyprland.lua` + `require("monitors")` etc. Hyprland loads
`hyprland.lua` if present, else falls back to `.conf` (checked once at
startup — restart required to switch).

API surface (from upstream `example/hyprland.lua`, 0.56):
- `hl.monitor({ output, mode, position, scale })`
- `hl.config({ general = {...}, decoration = {...}, input = {...} })`
- `hl.bind("SUPER + Q", hl.dsp.exec_cmd(cmd), { locked=, repeating=, mouse= })`
- `hl.dsp.focus({direction=|workspace=})`, `hl.dsp.window.close/float/move/drag/resize`
- `hl.curve(name, {...})`, `hl.animation({ leaf=, speed=, bezier=|spring= })`
- `hl.env(k, v)`, `hl.on("hyprland.start", fn)` + `hl.exec_cmd` (replaces `exec-once`)
- `hl.window_rule({ name, match={...}, ... })`, `hl.workspace_rule`, `hl.layer_rule`
- `hl.device({ name, sensitivity })`, `hl.gesture({...})`

## Steps
- [ ] 1. Add `hyprland.lua` alongside existing `.conf` (both present, `.lua` wins).
      Keep `.conf` in tree until the lua config is proven, then delete.
- [ ] 2. Port `monitors.conf` → `hl.monitor` + lid `bindl` (switch: binds).
      **Open question:** lua equivalent of `bindl = , switch:on:Lid Switch`.
- [ ] 3. Port `input.conf`, `appearance.conf` → `hl.config({ input=, decoration= })`,
      `hl.curve`/`hl.animation` for the `myBezier` animation block.
- [ ] 4. Port `keybinds.conf` (~60 binds). Loop over workspaces 1..5 instead of
      repeating lines. `bindel`/`bindl` → `{ locked=true, repeating=true }`.
- [ ] 5. Port `autostart.conf` `exec-once` → `hl.on("hyprland.start", ...)`.
      The staggered `sleep N && hyprctl dispatch movetoworkspacesilent` phases
      are a good candidate to replace with real Lua event handlers.
- [ ] 6. **Verify the 6 helper scripts** in `.config/hypr/scripts/`:
      - `hyprctl keyword monitor "..."` (swap-monitors, reset-monitors,
        position-monitor, lid-switch) — confirm `keyword` still accepts
        hyprlang strings under a lua config; if not, port to `hyprctl eval`
        with `hl.monitor({...})`.
      - `hyprctl keyword "device[...]:enabled"` (toggle-trackpad) — same.
      - `keybind-help.sh` uses `hyprctl binds -j` (IPC, not file parsing) —
        confirm `.dispatcher`/`.arg` fields still populate under lua binds.
- [ ] 7. Update `modules/features/dotfiles/symlinks.nix` — none needed, the whole
      `.config/hypr` dir is symlinked. Confirm only.
- [ ] 8. Test: `hyprctl reload full-reset` (switches lua/hyprlang contexts), then
      a full logout/login. Check `hyprctl configerrors` clean.
- [ ] 9. Delete the `.conf` files, update `.config/hypr/README.md`.

## Notes
- `hyprctl eval <lua>` and a built-in Lua REPL exist in 0.56 for live testing.
- Community converter exists (`hyprlang2lua`, tracks 0.56.1 mappings) — use as a
  first pass at most, hand-review everything.

---

# Plan: nixpkgs stdenv.isLinux/isDarwin eval warnings

## Finding
```
evaluation warning: stdenv.isLinux is deprecated, use stdenv.hostPlatform.isLinux instead
evaluation warning: stdenv.isDarwin is deprecated, use stdenv.hostPlatform.isDarwin instead
```
**Not our code.** `grep -rn 'stdenv\.is(Linux|Darwin)' --include='*.nix' .` in this
repo → 0 hits. Source is the pinned **home-manager** input (105 hits), e.g.
`modules/systemd.nix:250` and `modules/misc/nixpkgs.nix:146`.

home-manager `master` has already fixed it:
`default = pkgs.stdenv.hostPlatform.isLinux;`

Our lock: home-manager `144f4e36` (2026-07-09) — predates the fix.

## Steps
- [x] 1. `nix flake update home-manager` — `144f4e36` (2026-07-09) →
      `693e8ce0` (2026-09-04). New rev has 0 `stdenv.is*` hits.
- [x] 2. `nix eval --no-eval-cache .#nixosConfigurations.AppleII.config.system.build.toplevel.drvPath`
      — evaluates clean, zero warnings, no HM option breakage.
- [x] 3. n/a — no breaking changes surfaced.

**DONE.** `flake.lock` change is uncommitted and sits alongside the pre-existing
nixpkgs bump + the wayvnc work in the tree.

See `tasks/linear-hyprland-lua.md` for the Linear project + ticket breakdown.

# AppleII: lid sensor + keyboard death (2026-09-12)

## ROOT CAUSE FOUND: external magnet, not a faulty sensor

Framework 13's lid switch is a **Hall effect sensor**. Laptop has been sitting
on top of a MacBook Pro -- the MacBook's lid/case magnets trip it. That is the
whole "faulty sensor" story:

- sensor reads `closed` with the lid open  -> magnet, not a broken part
- "triggered by nudging the screen"        -> nudging moved it over the magnet
- logind latches that and re-fires its lid action every `HoldoffTimeoutSec`
  (30s) -> endless suspend/resume loop -> i8042 keyboard death

The earlier theory ("this board drops the SW_LID open event") was wrong. The
open event was never sent, because as far as the sensor was concerned the lid
never opened.

**Fix is free: don't rest the Framework on the MacBook.** No RMA, no ticket.

### Confirm (do this once)

Put the laptop back on the MacBook and watch:

```
for i in $(seq 60); do printf '%s %s\n' "$(date +%T)" "$(cat /proc/acpi/button/lid/LID0/state)"; sleep 1; done
```

`closed` with the lid open == confirmed.

## What that changes

Two of the five changes were treating the symptom. Two are independent and
stay.

| Change | Verdict |
|---|---|
| `boot.nix` -- `i8042.reset=1` | **keep**. Keyboard death after s2idle is a real, separate bug; the loop only made it frequent. Boot-only, zero cost. |
| `framework-udev.nix` -- Goodix `27c6` no-autosuspend | **keep**. Unrelated to the lid entirely. |
| `logind.nix` -- `HandleLidSwitch=ignore` | **revert**. Only existed to defuse the latch. Costs real behaviour: lid close at a TTY or the greetd login screen now does nothing. |
| `lid-switch.sh` -- issues `suspend-then-hibernate` itself | **revert**. Same reason -- logind goes back to owning the lid. |
| `toggle-lid.sh` -- comment rewrite | **revert** with the above (the comment describes the reverted design). |

## Do this next

- [ ] confirm the magnet with the loop above
- [x] revert `logind.nix`, `lid-switch.sh`, `toggle-lid.sh` -- done, tree is clean of them
- [ ] `sudo nixos-rebuild switch --flake .#AppleII` (needs an interactive terminal)
- [ ] reboot -- still needed for `i8042.reset=1`
- [ ] `grep -o 'i8042\.reset=1' /proc/cmdline`
- [ ] drop the temp workaround if still present:
      `systemctl --user disable --now lid-loop-guard.service && rm ~/.config/systemd/user/lid-loop-guard.service`
- [ ] commit `boot.nix` + `framework-udev.nix`
- [ ] ~~Framework support ticket~~ -- not a hardware fault

## Keyboard death (still real, still worth the kernel param)

i8042 keyboard dies after repeated s2idle resumes. IRQ 1 frozen in
`/proc/interrupts`, `/dev/input/event1` returns 0 bytes, device present in
`/proc/bus/input/devices` but absent from `hyprctl devices`. Below libinput --
restarting Hyprland does not fix it. The USB fingerprint reader keeps working
(USB re-enumerates), which is the tell.

## Gotchas learned

- Do NOT kill hyprlock to unstick a lock screen. Under ext-session-lock a lock
  client dying without `unlock_and_destroy` leaves the compositor in
  abandoned-lock state: failure screen, all input swallowed. Strictly worse.
  Recover with `uwsm stop` (greetd autologins back; tmux survives, it parents
  to `user@1000.service`).
- `hyprctl dispatch exit` is a Lua-config syntax error here. Same trap
  `dpms.sh` exists to work around.
- Recover the keyboard without rebooting:
  `echo -n serio0 > /sys/bus/serio/drivers/atkbd/unbind` then `.../bind` (root).
  A USB keyboard also works immediately.

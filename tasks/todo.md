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

- [x] revert `logind.nix`, `lid-switch.sh`, `toggle-lid.sh`
- [x] `nixos-rebuild switch --flake .#AppleII`
- [x] reboot -- `i8042.reset=1` confirmed present in `/proc/cmdline`
- [x] commit `boot.nix` + `framework-udev.nix` (ae648ad, e49072b)
- [x] remove the temp workaround -- `lid-loop-guard.service` disabled, unit
      file deleted, inhibitor confirmed gone from `systemd-inhibit --list`.
      It was holding a permanent `handle-lid-switch` block, which masked the
      restored `HandleLidSwitch=suspend-then-hibernate`.

- [ ] optional: confirm the magnet with the loop above, for the record
- [x] ~~Framework support ticket~~ -- not a hardware fault, cancelled

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

## Hibernate "stays on" / lid-open black screen (2026-09-20)

Journal timeline, this boot:

| time | event |
|---|---|
| 09:02 | lid closed, s2idle suspend; lid open 09:08 resumed fine |
| 09:08:55 | lid closed, s2idle suspend |
| 10:08:57 | HibernateDelaySec=60min hit: RTC wake, hibernate, 30 GB image, power off |
| 10:11:25 | resumed from that image, same session (lid-open event delivered post-resume) |

So lid close works as configured. What the user saw (black screen, power LED
on, needed the power button) is the machine already hibernated and coming back
up. Nothing failed today.

Manual `systemctl hibernate` (waybar) is the real problem, and it is
intermittent. Since Sep 12: 5 resumed fine, 3 never came back. Every failure
looks the same in the next boot's initrd: `HibernateLocation` EFI var is set
(systemd got as far as handing off to the kernel) but
`systemd-hibernate-resume: Unable to resume` / `PM: Image not found (code -22)`
(no valid image signature in swap). That means the kernel died or was
force-powered-off between "hibernation entry" and the final swap-header
commit. Same symptom logind.nix's comment blamed on HibernateMode=platform, so
that switch was not the root cause.

Failed: Sep 14 14:34, Sep 14 17:52, Sep 17 17:49. OK: Sep 13 00:06, Sep 13
23:10, Sep 14 21:45, Sep 15 21:21, Sep 16 16:43, plus today's auto one.

Unknowns the log cannot answer: image size on the failed runs (93 GB RAM, so
a heavy session can mean a 60+ GB write taking minutes with a black screen),
and how long the user waited before holding the power button.

- [ ] next hang: wait 5 min before forcing off; note it
- [ ] `echo 1 | sudo tee /sys/power/pm_trace` before `systemctl hibernate`;
      after the forced reboot `sudo dmesg | grep -A3 'Magic number'` names
      the last device touched (RTC time gets clobbered, timesyncd fixes it)
- [ ] `sudo ls /sys/fs/pstore` after a forced reboot, in case it panicked
- [ ] `Super+Shift+A` / `Super+Shift+I` are keep-awake toggles; they block
      sleep, they do not cause it. Neither was active today.

---

# ani-cli: nix package -> live git checkout (2026-10-04)

Goal: stop installing `pkgs.ani-cli`, run `~/repos/ani-cli/ani-cli` instead so
a `git pull` is the whole update path.

The nix `ani-cli` is a wrapper script that injects its deps on PATH internally,
so dropping it also drops `mpv`, `yt-dlp` and `curl-impersonate` (`fzf`,
`ffmpeg`, `sed`, `grep` were already system-wide). The bare script would have
fallen back to `vlc` for playback and lost download mode entirely.

- [x] `modules/features/apps/media.nix`: `ani-cli` -> `mpv`, `yt-dlp`,
      `curl-impersonate`
- [x] `modules/features/dotfiles/symlinks.nix`: `.local/bin/ani-cli` via
      `config.lib.file.mkOutOfStoreSymlink` (store `.source` would copy the
      repo in and freeze it)
- [x] `.zshrc`: `~/.local/bin` was not on PATH
- [ ] `sudo nixos-rebuild switch --flake .#AppleII`

## Review

Verified by eval + build, not by switch:

- `systemPackages` now matches `[ mpv-with-scripts-0.41.0 yt-dlp-2026.08.19
  curl-impersonate-2.1.1 ]`, no `ani-cli`
- built the hm entry: `hm_anicli -> /home/chriskim/repos/ani-cli/ani-cli`

`curl-impersonate` matters more than it looks: the script picks
`curl_firefox135`/`curl_chrome136` over plain `curl` by name, and allanime
rejects a vanilla curl fingerprint.

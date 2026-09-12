#!/usr/bin/env bash
# Toggle hypridle (idle dim / lock / suspend) on and off, with a notification.
#
# hypridle is a systemd user unit (modules/features/desktop/session-services.nix)
# with Restart=always, RestartSec=10. `pkill hypridle` therefore turned idle off
# for exactly ten seconds before systemd brought it back, and the ON branch
# would have spawned a second, unmanaged instance alongside the unit.
# `systemctl stop` is not a failure, so the restart policy does not apply.

if systemctl --user is-active --quiet hypridle; then
    systemctl --user stop hypridle
    brightnessctl -r 2>/dev/null || true          # undo any dim left by hypridle
    notify-send "Idle lock OFF" "Screen won't dim, lock, or sleep" 2>/dev/null || true
else
    systemctl --user start hypridle
    notify-send "Idle lock ON" "Auto dim, lock, and sleep enabled" 2>/dev/null || true
fi

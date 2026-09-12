#!/usr/bin/env bash
# Toggle an on-demand inhibitor that keeps the machine awake, with a
# notification. The inhibitor is transient: it clears on reboot/logout, so the
# machine returns to "lid closes -> suspend" by default.
#
# It covers two things, because covering only the first made the toggle lie.
# handle-lid-switch blocks logind acting on the lid (logind.nix sets
# HandleLidSwitch=suspend-then-hibernate). sleep blocks suspend outright --
# needed because hypridle.conf's 30-minute listener calls `systemctl suspend`,
# an explicit request that a handle-lid-switch inhibitor does not touch. So the
# lid would stay open-for-purposes and the machine would sleep anyway half an
# hour later.
#
# While this is on, a manual `systemctl suspend` is also refused; systemd names
# this inhibitor when it does. That is the point -- turn it off to suspend.

PIDFILE="/tmp/lid-inhibit.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Inhibitor active -> release it, restore default suspend-on-lid.
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    notify-send "Lid suspend ON" "Closing the lid will suspend" 2>/dev/null || true
else
    # No inhibitor -> hold one so the lid can be closed without suspending.
    systemd-inhibit --what=handle-lid-switch:sleep --who="lid-toggle" \
        --why="manual keep-awake" --mode=block sleep infinity &
    echo $! > "$PIDFILE"
    notify-send "Lid suspend OFF" "Laptop stays awake, lid closed or idle" 2>/dev/null || true
fi

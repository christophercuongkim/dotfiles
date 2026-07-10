#!/usr/bin/env bash
# Toggle an on-demand inhibitor that blocks lid-close suspend, with a
# notification. Independent of logind's default HandleLidSwitch=suspend and of
# hypridle (see toggle-idle.sh). The inhibitor is transient: it clears on
# reboot/logout, so the machine returns to "lid closes -> suspend" by default.

PIDFILE="/tmp/lid-inhibit.pid"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Inhibitor active -> release it, restore default suspend-on-lid.
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    notify-send "Lid suspend ON" "Closing the lid will suspend" 2>/dev/null || true
else
    # No inhibitor -> hold one so the lid can be closed without suspending.
    systemd-inhibit --what=handle-lid-switch --who="lid-toggle" \
        --why="manual keep-awake" --mode=block sleep infinity &
    echo $! > "$PIDFILE"
    notify-send "Lid suspend OFF" "Laptop stays awake with the lid closed" 2>/dev/null || true
fi

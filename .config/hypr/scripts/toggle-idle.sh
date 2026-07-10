#!/usr/bin/env bash
# Toggle hypridle (idle dim / lock / suspend) on and off, with a notification.

if pidof hypridle >/dev/null; then
    pkill hypridle
    brightnessctl -r 2>/dev/null || true          # undo any dim left by hypridle
    notify-send "Idle lock OFF" "Screen won't dim, lock, or sleep" 2>/dev/null || true
else
    hypridle & disown
    notify-send "Idle lock ON" "Auto dim, lock, and sleep enabled" 2>/dev/null || true
fi

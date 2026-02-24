#!/usr/bin/env bash
# Toggle trackpad on/off using hyprctl

TOUCHPAD="pixa3854:00-093a:0274-touchpad"
STATE_FILE="/tmp/trackpad-state"

if [[ ! -f "$STATE_FILE" ]]; then
    echo "1" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [[ "$STATE" == "1" ]]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" false
    echo "0" > "$STATE_FILE"
    notify-send "Trackpad OFF" 2>/dev/null || true
else
    hyprctl keyword "device[$TOUCHPAD]:enabled" true
    echo "1" > "$STATE_FILE"
    notify-send "Trackpad ON" 2>/dev/null || true
fi

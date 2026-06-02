#!/usr/bin/env bash
# Reset all monitors to default layout: eDP-1 at origin, externals stacked to the left.

monitors=$(hyprctl monitors -j)

# Reset laptop first
hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"

# Place each external to the left of eDP-1, stacked horizontally
offset=0
while IFS= read -r name; do
    [ "$name" = "eDP-1" ] && continue
    ew=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .width")
    offset=$(( offset + ew ))
    hyprctl keyword monitor "$name, highrr, -${offset}x0, 1"
done < <(echo "$monitors" | jq -r '.[].name')

pkill waybar; waybar &
notify-send "Monitors" "Reset to default layout"

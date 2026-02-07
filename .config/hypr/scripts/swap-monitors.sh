#!/usr/bin/env bash
# Swap positions of external monitors (relative to laptop eDP-1)

# Get external monitor names (everything except eDP-1)
externals=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name')
count=$(echo "$externals" | wc -l)

if [ "$count" -lt 2 ]; then
    notify-send "Swap Monitors" "Need 2+ external monitors to swap"
    exit 0
fi

# Get the two external monitors
mon1=$(echo "$externals" | sed -n '1p')
mon2=$(echo "$externals" | sed -n '2p')

# Get their current x positions
mon1_x=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon1\") | .x")
mon2_x=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon2\") | .x")

# Get their resolutions and other properties
mon1_res=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon1\") | \"\(.width)x\(.height)@\(.refreshRate)\"")
mon2_res=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon2\") | \"\(.width)x\(.height)@\(.refreshRate)\"")
mon1_y=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon1\") | .y")
mon2_y=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon2\") | .y")
mon1_scale=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon1\") | .scale")
mon2_scale=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$mon2\") | .scale")

# Swap their x positions
hyprctl keyword monitor "$mon1,$mon1_res,${mon2_x}x${mon1_y},$mon1_scale"
hyprctl keyword monitor "$mon2,$mon2_res,${mon1_x}x${mon2_y},$mon2_scale"

notify-send "Swap Monitors" "Swapped $mon1 <-> $mon2"

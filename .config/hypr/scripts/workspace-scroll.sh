#!/usr/bin/env bash
# workspace-scroll.sh <e+1|e-1|...>
#
# Exists so waybar can change workspace without caring which Hyprland config
# manager is live. `hyprctl dispatch workspace e+1` is a Lua syntax error under
# a Lua config.
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/hypr-lib.sh"

if [ "$(hypr_config_kind)" = "lua" ]; then
    hyprctl dispatch "hl.dsp.focus({ workspace = '$1' })"
else
    hyprctl dispatch workspace "$1"
fi

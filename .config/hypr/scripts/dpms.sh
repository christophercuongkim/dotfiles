#!/usr/bin/env bash
# dpms.sh <on|off|toggle> [monitor]
#
# Exists so hypridle.conf can drive DPMS without caring which Hyprland config
# manager is live. `hyprctl dispatch dpms off` is a Lua syntax error under a
# Lua config; hypr-lib.sh picks the right form.
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/hypr-lib.sh"
hypr_dpms "$@"

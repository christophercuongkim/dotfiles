#!/usr/bin/env bash
# Shared helpers for talking to Hyprland from scripts.
#
# Why this exists: `hyprctl keyword` only works under the legacy hyprlang config
# manager. Under a Lua config it is refused --- and refused *softly*, returning
# the string "keyword can't work with non-legacy parsers. Use eval." with exit
# status 0, so a script that does not inspect the output looks like it worked.
#
# These wrappers probe which config manager is live and issue either a
# `hyprctl keyword` or the equivalent `hyprctl eval` call, so the same script
# works before, during and after the hyprlang -> Lua migration, and keeps
# working if we ever roll back.

_HYPR_CFG=""

# "lua" or "legacy". Probed once per script run.
hypr_config_kind() {
    if [ -z "$_HYPR_CFG" ]; then
        if hyprctl eval 'return 1' 2>&1 | grep -q "only supported with the lua config manager"; then
            _HYPR_CFG="legacy"
        else
            _HYPR_CFG="lua"
        fi
    fi
    printf '%s' "$_HYPR_CFG"
}

# hypr_monitor <output> <mode> <position> <scale>
hypr_monitor() {
    local output="$1" mode="$2" position="$3" scale="$4"

    if [ "$(hypr_config_kind)" = "lua" ]; then
        hyprctl eval "hl.monitor({ output = '$output', mode = '$mode', position = '$position', scale = $scale })"
    else
        hyprctl keyword monitor "$output,$mode,$position,$scale"
    fi
}

# hypr_monitor_disable <output>
hypr_monitor_disable() {
    local output="$1"

    if [ "$(hypr_config_kind)" = "lua" ]; then
        hyprctl eval "hl.monitor({ output = '$output', disabled = true })"
    else
        hyprctl keyword monitor "$output, disable"
    fi
}

# hypr_dpms <on|off|toggle> [monitor]
#
# `hyprctl dispatch` is gated the same way `keyword` is: under a Lua config it
# parses its argument as Lua, so the legacy `dpms off eDP-1` form fails with a
# syntax error rather than doing anything.
hypr_dpms() {
    local action="$1" monitor="${2:-}"

    if [ "$(hypr_config_kind)" = "lua" ]; then
        if [ -n "$monitor" ]; then
            hyprctl dispatch "hl.dsp.dpms({ action = '$action', monitor = '$monitor' })"
        else
            hyprctl dispatch "hl.dsp.dpms({ action = '$action' })"
        fi
    else
        if [ -n "$monitor" ]; then
            hyprctl dispatch dpms "$action" "$monitor"
        else
            hyprctl dispatch dpms "$action"
        fi
    fi
}

# hypr_device_enabled <device-name> <true|false>
hypr_device_enabled() {
    local name="$1" enabled="$2"

    if [ "$(hypr_config_kind)" = "lua" ]; then
        hyprctl eval "hl.device({ name = '$name', enabled = $enabled })"
    else
        hyprctl keyword "device[$name]:enabled" "$enabled"
    fi
}

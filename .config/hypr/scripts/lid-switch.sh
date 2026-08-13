#!/usr/bin/env bash
# Handle lid switch. Only disable eDP-1 when an external monitor is present;
# disabling the sole output leaves Hyprland unable to reliably re-enable it on
# lid open (black screen). With no external monitor, leave the display alone
# and let logind handle suspend (see modules/features/power/logind.nix).

action="$1"   # "close" or "open"

# Count monitors that are not the laptop panel.
externals=$(hyprctl monitors -j | jq -r '[.[] | select(.name != "eDP-1")] | length')

# Is lid-close suspend inhibited? (toggle-lid.sh "lid suspend OFF")
lid_inhibited() {
    local pf="/tmp/lid-inhibit.pid"
    [[ -f "$pf" ]] && kill -0 "$(cat "$pf")" 2>/dev/null
}

case "$action" in
    close)
        if [ "$externals" -gt 0 ]; then
            # External present: fully disable panel so workspaces relocate.
            hyprctl keyword monitor "eDP-1, disable"
        elif lid_inhibited; then
            # Sole panel + lid suspend OFF: logind won't suspend, so leave the
            # panel on. Blanking here would strand a running machine black.
            :
        else
            # Sole panel: dpms off (reliably restores), never disable.
            # logind will suspend-then-hibernate right after.
            hyprctl dispatch dpms off eDP-1
        fi
        ;;
    open)
        hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"
        hyprctl dispatch dpms on eDP-1
        ;;
esac

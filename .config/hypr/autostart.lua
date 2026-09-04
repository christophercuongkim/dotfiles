-- Autostart applications

local v = require("vars")

hl.on("hyprland.start", function()
    -- Session setup
    hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target")

    -- System services (start before lock)
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets,ssh")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("setcursor Future-Cyan-Hyprcursor_Theme 40")
    hl.exec_cmd("blueman-applet")

    -- Lock on start, then launch apps after unlock.
    -- Phase 1: lock and bind workspaces to the external monitor if there is one.
    --
    -- The old version pinned workspaces with `hyprctl keyword workspace`, which
    -- is a no-op under a Lua config (hyprctl keyword is gated on the legacy
    -- parser and returns a message instead of an error). Same work via eval.
    hl.exec_cmd([[hyprlock || hyprctl dispatch 'hl.dsp.exit()' && sleep 0.5 && { ext=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -1); mon=${ext:-eDP-1}; for ws in 1 2 3 4; do hyprctl eval "hl.workspace_rule({ workspace = '$ws', monitor = '$mon' })"; done; }]])

    -- Phase 2: launch apps (staggered to avoid races)
    hl.exec_cmd("sleep 1 && ghostty")
    hl.exec_cmd("sleep 1.5 && brave")
    hl.exec_cmd("sleep 2 && spotify")
    hl.exec_cmd("sleep 2.5 && 1password")

    -- Phase 3: move windows to workspaces after they exist.
    --
    -- TODO: replace these sleeps with a window-open event handler that matches
    -- on class. The delays are a guess that breaks on a slow boot; Lua event
    -- handlers make this deterministic. Tracked separately from the port.
    hl.exec_cmd([[sleep 5 && hyprctl dispatch "hl.dsp.window.move({ workspace = 1, window = 'class:com.mitchellh.ghostty', follow = false })"]])
    hl.exec_cmd([[sleep 6 && hyprctl dispatch "hl.dsp.window.move({ workspace = 2, window = 'class:brave-browser', follow = false })"]])
    hl.exec_cmd([[sleep 7 && hyprctl dispatch "hl.dsp.window.move({ workspace = 3, window = 'class:spotify', follow = false })"]])
    hl.exec_cmd([[sleep 8 && hyprctl dispatch "hl.dsp.window.move({ workspace = 4, window = 'class:1password', follow = false })"]])
end)

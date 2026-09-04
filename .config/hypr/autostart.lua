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

    -- Phase 2: launch apps, each pinned to its workspace.
    --
    -- The second argument to hl.exec_cmd is a window rule attached to the spawn
    -- request and applied when that process's window appears -- so placement is
    -- deterministic no matter how long an app takes to start.
    --
    -- This replaces a two-phase sleep ladder: four staggered launches followed
    -- by four `sleep 5..8 && hyprctl dispatch movetoworkspacesilent` calls that
    -- guessed at startup times. On a slow boot the guesses lost and windows
    -- stayed wherever they opened; on a warm one we idled for eight seconds.
    --
    -- "silent" keeps focus where it is rather than following each window.
    hl.exec_cmd("ghostty",   { workspace = "1 silent" })
    hl.exec_cmd("brave",     { workspace = "2 silent" })
    hl.exec_cmd("spotify",   { workspace = "3 silent" })
    hl.exec_cmd("1password", { workspace = "4 silent" })
end)

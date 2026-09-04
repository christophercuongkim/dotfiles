-- Autostart applications

local v = require("vars")

-- Startup window placement.
--
-- The obvious approach is an exec rule -- the second argument to hl.exec_cmd,
-- which attaches a window rule to the spawned process. It does not work for
-- every app: the rule is tied to the PID that hl.exec_cmd spawns, so it only
-- matches if the window comes from that exact process.
--
-- Brave does not. It launches through a wrapper script that re-execs, so its
-- window belongs to a different PID and the rule silently misses -- the window
-- lands on whatever workspace happens to be focused. ghostty, spotify and
-- 1password are single-process and did match, which made this look like it
-- worked until the first cold boot.
--
-- Matching the window itself is PID-independent and works for all four. The
-- cost is that the window is placed just after it maps rather than before, so
-- there can be a brief flash on the wrong workspace. That is still far better
-- than the `sleep 5..8` ladder this replaced, which left windows misplaced for
-- seconds and lost outright if an app started slowly.
local placements = {
    ["com.mitchellh.ghostty"] = 1,
    ["brave-browser"]         = 2,
    ["spotify"]               = 3,
    ["1password"]             = 4,
}

hl.on("window.open", function(w)
    local ws = placements[w.class]
    if not ws then
        return
    end

    -- One-shot per class. A browser window opened an hour into the session
    -- should stay where it is.
    placements[w.class] = nil

    hl.dispatch(hl.dsp.window.move({
        workspace = ws,
        window    = "address:" .. w.address,
        follow    = false,
    }))
end)

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

    -- Phase 2: launch apps. Placement is handled by the window.open handler
    -- above, not here.
    hl.exec_cmd("ghostty")
    hl.exec_cmd("brave")
    hl.exec_cmd("spotify")
    hl.exec_cmd("1password")
end)

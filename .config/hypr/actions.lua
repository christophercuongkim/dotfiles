-- Actions bound to keys that need real logic.
--
-- These were shell scripts under the hyprlang config, because that config had
-- no way to run logic. Each one shelled out to `hyprctl monitors -j` and jq --
-- swap-monitors called it eight separate times to read six fields off two
-- monitors. In Lua that is one hl.get_monitors() and field access.
--
-- HL.Monitor fields are snake_case, not the camelCase that `hyprctl -j` emits:
-- name, x, y, width, height, scale, refresh_rate, focused, description, id,
-- active_workspace, transform.

local M = {}

local LAPTOP   = "eDP-1"
local TOUCHPAD = "pixa3854:00-093a:0274-touchpad"

local function notify(text)
    hl.notification.create({ text = text, timeout = 3000, icon = "info" })
end

-- waybar loses track of outputs when the layout changes under it.
local function restart_waybar()
    hl.exec_cmd("pkill waybar; waybar")
end

local function externals()
    local out = {}
    for _, m in ipairs(hl.get_monitors()) do
        if m.name ~= LAPTOP then
            out[#out + 1] = m
        end
    end
    return out
end

local function pos(x, y)
    return string.format("%dx%d", x, y)
end

local function mode_of(m)
    return string.format("%dx%d@%s", m.width, m.height, tostring(m.refresh_rate))
end

-- eDP-1 at the origin, externals stacked to its left.
function M.reset_monitors()
    hl.monitor({ output = LAPTOP, disabled = false, mode = "preferred", position = "0x0", scale = 1.5 })

    local offset = 0
    for _, m in ipairs(externals()) do
        offset = offset + m.width
        hl.monitor({ output = m.name, disabled = false, mode = "preferred", position = pos(-offset, 0), scale = 1 })
    end

    restart_waybar()
    notify("Monitors reset to default layout")
end

-- Exchange the x positions of the first two external monitors.
function M.swap_monitors()
    local ext = externals()

    if #ext < 2 then
        notify("Need 2+ external monitors to swap")
        return
    end

    local a, b = ext[1], ext[2]

    hl.monitor({ output = a.name, mode = mode_of(a), position = pos(b.x, a.y), scale = a.scale })
    hl.monitor({ output = b.name, mode = mode_of(b), position = pos(a.x, b.y), scale = b.scale })

    notify("Swapped " .. a.name .. " <-> " .. b.name)
end

-- There is no query binding for input devices, so the state is tracked here
-- rather than read back. It resets to enabled on a config reload, which the old
-- /tmp/trackpad-state file did not -- if the trackpad is off across a reload,
-- the first press re-sends "disable" and the second re-enables it.
local trackpad_enabled = true

function M.toggle_trackpad()
    trackpad_enabled = not trackpad_enabled
    hl.device({ name = TOUCHPAD, enabled = trackpad_enabled })
    notify(trackpad_enabled and "Trackpad ON" or "Trackpad OFF")
end

return M

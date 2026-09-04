-- Keybindings

local v   = require("vars")
local mod = v.mod

-- Every bind carries a description. hyprctl binds -j reports dispatcher
-- "__lua" and an opaque registry integer for every Lua bind, so
-- scripts/keybind-help.sh reads .description instead.
local function bind(keys, dispatcher, description, opts)
    opts             = opts or {}
    opts.description = description
    hl.bind(keys, dispatcher, opts)
end

-- Apps
bind(mod .. " + slash",   hl.dsp.exec_cmd(v.scripts .. "/keybind-help.sh"), "Keybind cheatsheet")
bind(mod .. " + Return",  hl.dsp.exec_cmd(v.terminal),                      "Terminal")
bind(mod .. " + B",       hl.dsp.exec_cmd("firefox"),                       "Firefox")
bind(mod .. " + grave",   hl.dsp.exec_cmd("hyprlock"),                      "Lock screen")
bind(mod .. " + space",   hl.dsp.exec_cmd("rofi -show drun"),               "App launcher")
bind(mod .. " + SHIFT + s",
    hl.dsp.exec_cmd("HYPRSHOT_DIR='" .. os.getenv("HOME") .. "/Pictures/screen_shots' " .. v.ss .. " -m region"),
    "Screenshot region")

-- Focus (vim-style)
local dirs = {
    { key = "H", dir = "left"  },
    { key = "J", dir = "down"  },
    { key = "K", dir = "up"    },
    { key = "L", dir = "right" },
}

for _, d in ipairs(dirs) do
    bind(mod .. " + " .. d.key, hl.dsp.focus({ direction = d.dir }), "Focus " .. d.dir)
end

-- Windows
bind(mod .. " + X", hl.dsp.window.close(),                       "Close window")
bind(mod .. " + f", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")
bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }),  "Toggle float")

-- Float move/resize (hold mod + drag)
bind(mod .. " + mouse:272", hl.dsp.window.drag(),   "Move floating window (drag)",   { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize floating window (drag)", { mouse = true })

-- Workspaces - switch and move window
for i = 1, 5 do
    bind(mod .. " + " .. i,           hl.dsp.focus({ workspace = i }),       "Workspace " .. i)
    bind(mod .. " SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }), "Window to workspace " .. i)
end

-- Workspaces - relative navigation
bind(mod .. " SHIFT + 9",   hl.dsp.window.move({ workspace = "-1" }), "Window to previous workspace")
bind(mod .. " SHIFT + 0",   hl.dsp.window.move({ workspace = "+1" }), "Window to next workspace")
bind(mod .. " + N",         hl.dsp.focus({ workspace = "empty" }),    "First empty workspace")
bind(mod .. " SHIFT + N",   hl.dsp.focus({ workspace = "empty:-1" }), "Previous empty workspace")
bind(mod .. " + Tab",       hl.dsp.focus({ workspace = "m+1" }),      "Next workspace on monitor")
bind(mod .. " SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }),      "Previous workspace on monitor")

-- Monitor selectors are the same strings the old config used: l/r/u/d, +1, -1.
local mons = {
    { key = "H", sel = "l", label = "left"  },
    { key = "L", sel = "r", label = "right" },
    { key = "J", sel = "d", label = "down"  },
    { key = "K", sel = "u", label = "up"    },
}

for _, m in ipairs(mons) do
    -- Focus monitor
    bind(mod .. " CTRL + " .. m.key, hl.dsp.focus({ monitor = m.sel }),
        "Focus monitor " .. m.label)
    -- Move window to monitor
    bind(mod .. " SHIFT + " .. m.key, hl.dsp.window.move({ monitor = m.sel }),
        "Window to monitor " .. m.label)
    -- Move workspace to monitor
    bind(mod .. " ALT + " .. m.key, hl.dsp.workspace.move({ monitor = m.sel }),
        "Workspace to monitor " .. m.label)
end

bind(mod .. " CTRL + Tab",         hl.dsp.focus({ monitor = "+1" }),          "Focus next monitor")
bind(mod .. " CTRL SHIFT + Tab",   hl.dsp.focus({ monitor = "-1" }),          "Focus previous monitor")
bind(mod .. " ALT + Tab",          hl.dsp.workspace.move({ monitor = "+1" }), "Workspace to next monitor")
bind(mod .. " ALT SHIFT + Tab",    hl.dsp.workspace.move({ monitor = "-1" }), "Workspace to previous monitor")

-- Swap workspaces between monitors
bind(mod .. " ALT SHIFT + M",
    hl.dsp.workspace.swap_monitors({ monitor1 = "current", monitor2 = "+1" }),
    "Swap workspaces between monitors")

-- Monitor layout helpers
bind(mod .. " + M",       hl.dsp.exec_cmd(v.scripts .. "/swap-monitors.sh"),  "Swap monitor positions")
bind(mod .. " SHIFT + M", hl.dsp.exec_cmd(v.scripts .. "/reset-monitors.sh"), "Reset monitor layout")

for _, p in ipairs({
    { key = "H", where = "left"  },
    { key = "L", where = "right" },
    { key = "K", where = "above" },
    { key = "J", where = "below" },
}) do
    bind(mod .. " SHIFT ALT + " .. p.key,
        hl.dsp.exec_cmd(v.scripts .. "/position-monitor.sh " .. p.where),
        "Move monitor " .. p.where)
end

-- Toggles
bind(mod .. " SHIFT + T", hl.dsp.exec_cmd(v.scripts .. "/toggle-trackpad.sh"), "Toggle trackpad")
bind(mod .. " SHIFT + I", hl.dsp.exec_cmd(v.scripts .. "/toggle-idle.sh"),     "Toggle idle lock/sleep")
bind(mod .. " SHIFT + A", hl.dsp.exec_cmd(v.scripts .. "/toggle-lid.sh"),      "Toggle lid-close suspend")

-- Window resizing
bind(mod .. " CTRL + right", hl.dsp.window.resize({ x =  20, y =   0, relative = true }), "Grow width")
bind(mod .. " CTRL + left",  hl.dsp.window.resize({ x = -20, y =   0, relative = true }), "Shrink width")
bind(mod .. " CTRL + up",    hl.dsp.window.resize({ x =   0, y = -20, relative = true }), "Shrink height")
bind(mod .. " CTRL + down",  hl.dsp.window.resize({ x =   0, y =  20, relative = true }), "Grow height")

-- Media keys. bindel -> locked + repeating, bindl -> locked.
local el = { locked = true, repeating = true }
local l  = { locked = true }

bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), "Volume up",   el)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), "Volume down", el)
bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), "Mute",       l)
bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), "Play/pause", l)
bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),   "Previous track", l)
bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),       "Next track", l)
bind(mod .. " + XF86AudioPlay", hl.dsp.exec_cmd("spotify"), "Spotify")

-- Brightness
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"), "Brightness down", el)
bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 10%+"), "Brightness up",   el)

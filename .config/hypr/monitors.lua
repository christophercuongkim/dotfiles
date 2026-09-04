-- Monitor configuration

local v = require("vars")

-- Laptop display (scaled for HiDPI)
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1.5 })

-- All other monitors: preferred (native) mode, auto-position to the left
hl.monitor({ output = "", mode = "preferred", position = "auto-left", scale = 1 })

-- Lid switch - disable laptop display only when an external monitor is present.
-- Disabling the sole output leaves it black on lid open; script guards on that.
--
-- switch: key strings are passed through verbatim by the Lua bind parser and
-- matched by KeybindManager, so this is the same behaviour as the old bindl.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(v.scripts .. "/lid-switch.sh close"), {
    locked      = true,
    description = "Lid close",
})
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd(v.scripts .. "/lid-switch.sh open"), {
    locked      = true,
    description = "Lid open",
})

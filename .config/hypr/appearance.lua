-- Appearance - animations and decorations

hl.config({
    decoration = {
        rounding              = 10,
        rounding_power        = 2.0,
        active_opacity        = 1.0,
        inactive_opacity      = 1.0,
        fullscreen_opacity    = 1.0,
        dim_inactive          = false,
        dim_strength          = 0.5,
        dim_special           = 0.2,
        dim_around            = 0.4,
        border_part_of_window = true,
    },

    animations = {
        enabled = true,
    },
})

-- The old `bezier = myBezier, 0.05, 0.9, 0.1, 1.0` becomes a curve plus one
-- hl.animation call per leaf.
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })

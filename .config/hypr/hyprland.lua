-- Hyprland configuration
-- https://wiki.hypr.land/
--
-- Ported from the hyprlang .conf format, which upstream deprecated in 0.55 and
-- drops after 0.56. Hyprland loads this file in preference to hyprland.conf
-- when both exist; the choice is made once at startup, so switching back means
-- removing this file and restarting.

require("monitors")
require("input")
require("autostart")
require("appearance")
require("keybinds")
require("windowrules")

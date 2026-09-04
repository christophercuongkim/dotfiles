-- Shared values for the other config modules.
--
-- Locals do not cross a require() boundary, so anything the old hyprland.conf
-- exposed as a $variable lives here and is pulled in with:
--   local v = require("vars")

return {
    mod          = "SUPER",
    terminal     = "ghostty",
    file_manager = "dolphin",
    ss           = "hyprshot",

    scripts      = os.getenv("HOME") .. "/.config/hypr/scripts",
}

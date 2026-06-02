#!/usr/bin/env bash
# Show a searchable rofi cheatsheet of all active Hyprland keybindings.

decode_mods() {
    local mask=$1
    local mods=""
    (( mask & 64 )) && mods+="Super + "
    (( mask & 1  )) && mods+="Shift + "
    (( mask & 4  )) && mods+="Ctrl + "
    (( mask & 8  )) && mods+="Alt + "
    echo "$mods"
}

# Build readable label for dispatcher + arg
format_action() {
    local dispatcher="$1"
    local arg="$2"
    case "$dispatcher" in
        exec)
            # Strip long paths/flags, show just the binary name or short command
            short=$(echo "$arg" | sed 's|.*/||; s| .*||; s|"||g')
            echo "exec: $short"
            ;;
        workspace)            echo "workspace: $arg" ;;
        movetoworkspace)      echo "move window → workspace $arg" ;;
        movefocus)            echo "focus $arg" ;;
        killactive)           echo "close window" ;;
        fullscreen)           echo "fullscreen" ;;
        togglefloating)       echo "toggle float" ;;
        resizeactive)         echo "resize $arg" ;;
        focusmonitor)         echo "focus monitor $arg" ;;
        movecurrentworkspacetomonitor) echo "workspace → monitor $arg" ;;
        swapactiveworkspaces) echo "swap workspaces: $arg" ;;
        movewindowtomonitor)  echo "window → monitor $arg" ;;
        *)                    echo "$dispatcher ${arg:0:40}" ;;
    esac
}

hyprctl binds -j | jq -r '.[] | select(.mouse == false) | "\(.modmask)\t\(.key)\t\(.dispatcher)\t\(.arg)"' | \
while IFS=$'\t' read -r modmask key dispatcher arg; do
    # Skip lid switch and raw keycodes with no useful label
    [[ "$key" == switch:* ]] && continue
    [[ "$key" == XF86* ]] && label="$key" || label="$key"

    mods=$(decode_mods "$modmask")
    action=$(format_action "$dispatcher" "$arg")
    printf "%-30s  %s\n" "${mods}${key}" "$action"
done | sort | rofi -dmenu -i \
    -p "Keybinds" \
    -theme-str 'window {width: 700px;} listview {lines: 20;}' \
    -no-custom

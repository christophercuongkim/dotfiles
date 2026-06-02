#!/usr/bin/env bash
# Move the focused monitor adjacent to a reference monitor.
# With 2 monitors: uses nearest automatically.
# With 3+ monitors: prompts via rofi to pick the reference.
# Usage: position-monitor.sh <left|right|above|below>

direction="${1:-right}"
monitors=$(hyprctl monitors -j)

focused=$(echo "$monitors" | jq -r '.[] | select(.focused == true) | .name')
if [ -z "$focused" ]; then
    notify-send "Position Monitor" "No focused monitor"
    exit 1
fi

f_x=$(echo "$monitors"     | jq -r ".[] | select(.name == \"$focused\") | .x")
f_y=$(echo "$monitors"     | jq -r ".[] | select(.name == \"$focused\") | .y")
f_w=$(echo "$monitors"     | jq -r ".[] | select(.name == \"$focused\") | .width")
f_h=$(echo "$monitors"     | jq -r ".[] | select(.name == \"$focused\") | .height")
f_scale=$(echo "$monitors" | jq -r ".[] | select(.name == \"$focused\") | .scale")
f_eff_w=$(echo "$f_w $f_scale" | awk '{printf "%d", $1/$2}')
f_eff_h=$(echo "$f_h $f_scale" | awk '{printf "%d", $1/$2}')
f_cx=$(( f_x + f_eff_w / 2 ))
f_cy=$(( f_y + f_eff_h / 2 ))

# Collect all other monitors with their geometry
other_names=()
declare -A mon_x mon_y mon_eff_w mon_eff_h mon_desc mon_scale

while IFS= read -r name; do
    [ "$name" = "$focused" ] && continue
    nx=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .x")
    ny=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .y")
    nw=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .width")
    nh=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .height")
    ns=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .scale")
    nd=$(echo "$monitors" | jq -r ".[] | select(.name == \"$name\") | .description")
    mon_x["$name"]="$nx"
    mon_y["$name"]="$ny"
    mon_eff_w["$name"]=$(echo "$nw $ns" | awk '{printf "%d", $1/$2}')
    mon_eff_h["$name"]=$(echo "$nh $ns" | awk '{printf "%d", $1/$2}')
    mon_desc["$name"]="$nd"
    mon_scale["$name"]="$ns"
    other_names+=("$name")
done < <(echo "$monitors" | jq -r '.[].name')

count="${#other_names[@]}"

if [ "$count" -eq 0 ]; then
    notify-send "Position Monitor" "Only one monitor connected"
    exit 1
elif [ "$count" -eq 1 ]; then
    # Fast path: only one other monitor
    ref="${other_names[0]}"
else
    # 3+ monitors: rofi picker — show name + current position for context
    menu=""
    for name in "${other_names[@]}"; do
        rx="${mon_x[$name]}"; ry="${mon_y[$name]}"
        rw="${mon_eff_w[$name]}"; rh="${mon_eff_h[$name]}"
        menu+="$name  (${rw}x${rh} @ ${rx},${ry})  [${mon_desc[$name]}]\n"
    done
    chosen=$(printf "%b" "$menu" | rofi -dmenu -p "Snap $focused $direction of:" -theme-str 'window {width: 500px;}')
    [ -z "$chosen" ] && exit 0
    ref=$(echo "$chosen" | awk '{print $1}')
fi

ref_x="${mon_x[$ref]}"
ref_y="${mon_y[$ref]}"
ref_eff_w="${mon_eff_w[$ref]}"
ref_eff_h="${mon_eff_h[$ref]}"
ref_cx=$(( ref_x + ref_eff_w / 2 ))
ref_cy=$(( ref_y + ref_eff_h / 2 ))

case "$direction" in
    left)  new_x=$(( ref_x - f_eff_w ));          new_y=$(( ref_cy - f_eff_h / 2 )) ;;
    right) new_x=$(( ref_x + ref_eff_w ));         new_y=$(( ref_cy - f_eff_h / 2 )) ;;
    above) new_x=$(( ref_cx - f_eff_w / 2 ));      new_y=$(( ref_y - f_eff_h )) ;;
    below) new_x=$(( ref_cx - f_eff_w / 2 ));      new_y=$(( ref_y + ref_eff_h )) ;;
    *)
        notify-send "Position Monitor" "Unknown direction: $direction"
        exit 1 ;;
esac

# Move the focused monitor
hyprctl keyword monitor "$focused, preferred, ${new_x}x${new_y}, $f_scale"

# Re-lock all other monitors at their pre-move positions —
# moving one monitor causes Hyprland to re-evaluate auto-left for others
for name in "${other_names[@]}"; do
    hyprctl keyword monitor "$name, preferred, ${mon_x[$name]}x${mon_y[$name]}, ${mon_scale[$name]}"
done

pkill waybar; waybar &
notify-send "Position Monitor" "$focused → $direction of $ref"

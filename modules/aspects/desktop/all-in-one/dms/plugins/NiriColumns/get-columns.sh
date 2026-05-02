#!/usr/bin/env sh
        
output="$1"
if [ -z "$output" ]; then
    exit 0
fi

idfocused="$(niri msg -j workspaces | jq -r '.[] | select(.is_active == true and .output == "'"$output"'") | .id')"

if [ -z "$idfocused" ] || [ "$idfocused" = "null" ]; then
    echo ""
    exit 0
fi

niri msg -j windows | jq -r --argjson wid "$idfocused" '
    map(select(.workspace_id == $wid)) |
    if length == 0 then
        ""
    else
        (map(.layout.pos_in_scrolling_layout[0]) | max) as $max_col |
        (map(select(.is_focused == true))[0]?.layout?.pos_in_scrolling_layout[0]) as $cur_col |
        if $cur_col then
            "\($cur_col)/\($max_col)"
        else
            "\($max_col)"
        end
    end
'

#!/usr/bin/env sh
        
output="$1"
if [ -z "$output" ]; then
    exit 0
fi

idfocused="$(niri msg -j workspaces | jq -r '.[] | select(.is_active == true and .output == "'"$output"'") | .id')"

if [ -z "$idfocused" ] || [ "$idfocused" = "null" ]; then
    echo '{"text": "", "columns": []}'
    exit 0
fi

niri msg -j windows | jq -c --argjson wid "$idfocused" '
    map(select(.workspace_id == $wid)) |
    if length == 0 then
        {"text": "", "columns": []}
    else
        (map(.layout.pos_in_scrolling_layout[0]) | max) as $max_col |
        (map(select(.is_focused == true))[0]?.layout?.pos_in_scrolling_layout[0]) as $cur_col |
        {
            "text": (if $cur_col then "\($cur_col)/\($max_col)" else "\($max_col)" end),
            "columns": (
                map({
                    "id": .id,
                    "title": .title,
                    "app_id": .app_id,
                    "column": .layout.pos_in_scrolling_layout[0],
                    "row": .layout.pos_in_scrolling_layout[1],
                    "is_focused": .is_focused,
                    "width": .layout.window_size[0],
                    "height": .layout.window_size[1]
                })
                | group_by(.column)
                | map({
                    "column_index": .[0].column,
                    "windows": sort_by(.row)
                })
            )
        }
    end
'

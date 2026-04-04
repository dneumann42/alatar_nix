function sway_find_marked_window --argument-names mark
    swaymsg -t get_tree | jq -r --arg mark $mark '
        def walk_nodes:
            . as $node
            | [$node]
            + ($node.nodes | map(walk_nodes) | add // [])
            + ($node.floating_nodes | map(walk_nodes) | add // []);

        walk_nodes[]
        | select(.marks? != null and (.marks | index($mark)))
        | .id
        | tostring
        ' | head -n 1
end

function sway_find_matching_window --argument-names field value
    swaymsg -t get_tree | jq -r --arg field $field --arg value $value '
        def walk_nodes:
            . as $node
            | [$node]
            + ($node.nodes | map(walk_nodes) | add // [])
            + ($node.floating_nodes | map(walk_nodes) | add // []);

        walk_nodes[]
        | select(.type == "con" or .type == "floating_con")
        | select(($field == "app_id" and (.app_id // "") == $value)
            or ($field == "class" and (.window_properties.class // "") == $value)
            or ($field == "instance" and (.window_properties.instance // "") == $value)
            or ($field == "title" and (.name // "") == $value))
        | .id
        | tostring
        ' | head -n 1
end

function sway_is_hidden_in_scratchpad --argument-names window_id
    swaymsg -t get_tree | jq -e --arg id $window_id '
        def walk_nodes:
            . as $node
            | [$node]
            + ($node.nodes | map(walk_nodes) | add // [])
            + ($node.floating_nodes | map(walk_nodes) | add // []);

        walk_nodes[]
        | select((.id | tostring) == $id)
        | (.scratchpad_state != "none") and (.visible == false)
        ' >/dev/null
end

function sway_parse_criterion --argument-names criterion
    set -l normalized (string trim -- $criterion)
    set normalized (string replace -r '^\\[(.*)\\]$' '$1' -- $normalized)

    if not string match -rq '^[A-Za-z_][A-Za-z0-9_]*=".*"$' -- $normalized
        echo "unsupported criterion: $criterion" >&2
        echo "expected a single criterion like title=\"termusic\" or app_id=\"ghostty\"" >&2
        return 1
    end

    set -l parsed (string match -r '^([A-Za-z_][A-Za-z0-9_]*)="(.*)"$' -- $normalized)
    set -l field $parsed[2]
    set -l value $parsed[3]

    switch $field
        case app_id class instance title
            echo $field
            echo $value
        case '*'
            echo "unsupported criterion field: $field" >&2
            echo "supported fields: app_id, class, instance, title" >&2
            return 1
    end
end

function sway_wait_for_window --argument-names field value attempts
    for attempt in (seq $attempts)
        set -l window_id (sway_find_matching_window $field $value)
        if test -n "$window_id"
            echo $window_id
            return 0
        end

        sleep 0.2
    end

    return 1
end

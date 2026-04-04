#!/usr/bin/env fish

source (string join / (status dirname) sway-utils.fish)

function usage
    echo "usage: toggler.fish <tag> <criterion> -- <command...>" >&2
end

set -l separator_index (contains -i -- -- $argv)
if test -z "$separator_index"
    usage
    exit 1
end

if test $separator_index -lt 3
    usage
    exit 1
end

set -l tag $argv[1]
set -l criterion $argv[2]
set -l command_argv $argv[(math $separator_index + 1)..-1]

if test -z "$tag" -o -z "$criterion" -o (count $command_argv) -eq 0
    usage
    exit 1
end

set -l parsed_criterion (sway_parse_criterion $criterion)
or exit 1

set -l field $parsed_criterion[1]
set -l value $parsed_criterion[2]
set -l mark "toggle:$tag"
set -l window_id (sway_find_marked_window $mark)
set -l launched_now 0

if test -z "$window_id"
    set window_id (sway_find_matching_window $field $value)

    if test -n "$window_id"
        swaymsg "[con_id=$window_id]" "mark --add \"$mark\"" >/dev/null
    else
        $command_argv >/dev/null 2>&1 &
        disown

        set window_id (sway_wait_for_window $field $value 25)
        if test -z "$window_id"
            echo "timed out waiting for window matching $criterion" >&2
            exit 1
        end

        swaymsg "[con_id=$window_id]" "mark --add \"$mark\"" >/dev/null
        set launched_now 1
    end
end

if test $launched_now -eq 1
    swaymsg "[con_mark=\"$mark\"] focus" >/dev/null
else if sway_is_hidden_in_scratchpad $window_id
    swaymsg "[con_mark=\"$mark\"] scratchpad show" >/dev/null
    swaymsg "[con_mark=\"$mark\"] focus" >/dev/null
else
    swaymsg "[con_mark=\"$mark\"] move scratchpad" >/dev/null
end

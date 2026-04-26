#!/usr/bin/env bash
# Switch to widescreen monitor only, disable all others

WIDESCREEN="DP-1"  # Change this to your widescreen output

swaymsg output "*" disable
swaymsg output "$WIDESCREEN" enable
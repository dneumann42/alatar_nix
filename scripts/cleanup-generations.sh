#!/usr/bin/env bash

PROFILE="/nix/var/nix/profiles/system"

CURRENT=$(sudo nix-env -p "$PROFILE" -q | head -1 | grep -oE '[0-9]+')
GENERATIONS=$(sudo nix-env -p "$PROFILE" --list-generations | tail -n +3 | awk -v cur="$CURRENT" 'NR==1 && $1==cur {next} {print $1}')

if [ -n "$GENERATIONS" ]; then
    sudo nix-env -p "$PROFILE" --delete-generations $GENERATIONS
else
    echo "No old generations to delete"
fi
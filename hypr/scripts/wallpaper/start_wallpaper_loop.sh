#!/bin/bash

WALLPAPER_DIR="$HOME/pictures/desktop"
LATEST_WALLPAPER=$(ls -t "$WALLPAPER_DIR"/* | head -n 1)

swaybg -i "$LATEST_WALLPAPER" -m fill > /dev/null 2>&1 &

while true; do
    sleep 600
    echo "Changing wallpaper at $(date)" >> $HOME/.config/hypr/scripts/wallpaper/wallpaper.log
    $HOME/.config/hypr/scripts/wallpaper/change_wallpaper.sh
done


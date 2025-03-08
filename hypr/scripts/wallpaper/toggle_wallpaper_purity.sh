#!/bin/bash

# File to store the current purity state
PURITY_FILE="$HOME/.purity"
WALLPAPER_DIR="/usr/share/wallpapers"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current_wallpaper"
WALLPAPER_LOG="$HOME/.config/hypr/scripts/wallpaper/wallpaper.log"

# Check if the purity file exists; if not, create it with the default value
if [[ ! -f $PURITY_FILE ]]; then
    echo "100" > "$PURITY_FILE"
fi

# Read the current purity state
CURRENT_PURITY=$(cat "$PURITY_FILE")

# Toggle the purity state
if [[ "$CURRENT_PURITY" == "100" ]]; then
    NEW_PURITY="011"
else
    NEW_PURITY="100"
fi

# Save the new purity state
echo "$NEW_PURITY" > "$PURITY_FILE"

# Output the new purity state
echo "Purity has been toggled to: $NEW_PURITY" >> "$WALLPAPER_LOG"
notify-send "Purity Changed" "Purity has been changed to: $NEW_PURITY" 

# Change wallpaper using the provided script
$HOME/.config/hypr/scripts/wallpaper/change_wallpaper.sh "$NEW_PURITY"


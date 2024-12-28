#!/bin/bash

# File to store the current purity state
PURITY_FILE="$HOME/.purity"
WALLPAPER_DIR="$HOME/pictures/desktop"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current_wallpaper"
SAFE_WALLPAPER="$WALLPAPER_DIR/safe_current_wallpaper"
WALLPAPER_LOG="$HOME/.config/hypr/scripts/wallpaper/wallpaper.log"

# Check if the purity file exists; if not, create it with the default value
if [[ ! -f $PURITY_FILE ]]; then
    echo "100" > "$PURITY_FILE"
fi

# Read the current purity state
CURRENT_PURITY=$(cat "$PURITY_FILE")

# Detect the current wallpaper file and extension
CURRENT_WALLPAPER_FILE=$(ls "$CURRENT_WALLPAPER".* 2>/dev/null | head -n 1)

if [[ -z "$CURRENT_WALLPAPER_FILE" ]]; then
    echo "Error: Current wallpaper file not found!" >> "$WALLPAPER_LOG"
    exit 1
fi

# Extract the file extension (e.g., .jpg, .png)
FILE_EXTENSION="${CURRENT_WALLPAPER_FILE##*.}"

# Define the safe wallpaper path with the correct extension
SAFE_WALLPAPER="$SAFE_WALLPAPER.$FILE_EXTENSION"

# Toggle the purity state
if [[ "$CURRENT_PURITY" == "100" ]]; then
    cp "$CURRENT_WALLPAPER_FILE" "$SAFE_WALLPAPER"
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
$HOME/.config/hypr/scripts/wallpaper/change_wallpaper.sh


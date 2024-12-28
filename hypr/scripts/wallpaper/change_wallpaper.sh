#!/bin/bash

# Paths
PYTHON_SCRIPT="$HOME/.config/hypr/scripts/wallpaper/fetch_wallpaper.py"  # Replace with the path to your Python script
WALLPAPER_DIR="$HOME/pictures/desktop"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current_wallpaper"
SAFE_WALLPAPER="$WALLPAPER_DIR/safe_current_wallpaper"
WALLPAPER_LOG="$HOME/.config/hypr/scripts/wallpaper/wallpaper.log"
MAX_IMAGES=100

# Ensure the wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

# Run the Python script to fetch a wallpaper
/usr/bin/python3 "$PYTHON_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch wallpaper using Python script." >> "$WALLPAPER_LOG"
    exit 1
fi

# Find the latest downloaded image in the wallpaper directory
LATEST_WALLPAPER=$(ls -t "$WALLPAPER_DIR"/* | head -n 1)

if [ -z "$LATEST_WALLPAPER" ]; then
    echo "$(date): No wallpaper found!" >> "$WALLPAPER_LOG"
    exit 1
fi

# Get the file extension of the latest wallpaper
LATEST_EXTENSION="${LATEST_WALLPAPER##*.}"
CURRENT_WALLPAPER_FILE="$CURRENT_WALLPAPER.$LATEST_EXTENSION"

# Check if the latest wallpaper is already set as the current wallpaper
if [ "$LATEST_WALLPAPER" = "$CURRENT_WALLPAPER_FILE" ]; then
    echo "$(date): The latest wallpaper is the same as the current wallpaper. No update needed." >> "$WALLPAPER_LOG"
else
    # Copy the latest wallpaper to a consistent file path for swaybg
    cp "$LATEST_WALLPAPER" "$CURRENT_WALLPAPER_FILE"

    # Set the wallpaper using swaybg
    swaybg -i "$LATEST_WALLPAPER" -m fill > /dev/null 2>&1 &
fi

# Clear old images if there are more than MAX_IMAGES
IMAGE_COUNT=$(ls "$WALLPAPER_DIR"/* 2>/dev/null | wc -l)
if [ "$IMAGE_COUNT" -gt "$MAX_IMAGES" ]; then
    echo "Cleaning up old wallpapers. Current count: $IMAGE_COUNT" >> "$WALLPAPER_LOG"
    # Find and delete the oldest files while keeping the latest MAX_IMAGES
    ls -t "$WALLPAPER_DIR"/* | tail -n +"$((MAX_IMAGES + 1))" | xargs -d '\n' rm -f
    echo "Cleanup complete. Remaining images: $(ls "$WALLPAPER_DIR"/* 2>/dev/null | wc -l)" >> "$WALLPAPER_LOG"
fi

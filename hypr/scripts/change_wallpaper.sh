#!/bin/bash

# Paths
PYTHON_SCRIPT="$HOME/.config/hypr/scripts/fetch_wallpaper.py"  # Replace with the path to your Python script
WALLPAPER_DIR="$HOME/pictures/desktop"
CURRENT_WALLPAPER="$WALLPAPER_DIR/current_wallpaper.jpg"
MAX_IMAGES=100

# Ensure the wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

# Run the Python script to fetch a wallpaper
python3 "$PYTHON_SCRIPT"
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch wallpaper using Python script."
    exit 1
fi

# Find the latest downloaded image in the wallpaper directory
LATEST_WALLPAPER=$(ls -t "$WALLPAPER_DIR"/*.jpg | head -n 1)

if [ -z "$LATEST_WALLPAPER" ]; then
    echo "$(date): No wallpaper found!" 
    exit 1
fi

# Copy the latest wallpaper to a consistent file path for swaybg
cp "$LATEST_WALLPAPER" "$CURRENT_WALLPAPER"

# Set the wallpaper using swaybg
swaybg -i "$CURRENT_WALLPAPER" -m fill &

# Update the wallpaper with swaybg or Hyprland's bg setting
pkill -o swaybg
swaybg -i "$LATEST_WALLPAPER" -m fill &

# Clear old images if there are more than MAX_IMAGES
IMAGE_COUNT=$(ls "$WALLPAPER_DIR"/*.jpg 2>/dev/null | wc -l)
if [ "$IMAGE_COUNT" -gt "$MAX_IMAGES" ]; then
    echo "Cleaning up old wallpapers. Current count: $IMAGE_COUNT"
    # Find and delete the oldest files while keeping the latest MAX_IMAGES
    ls -t "$WALLPAPER_DIR"/*.jpg | tail -n +"$((MAX_IMAGES + 1))" | xargs -d '\n' rm -f
    echo "Cleanup complete. Remaining images: $(ls "$WALLPAPER_DIR"/*.jpg 2>/dev/null | wc -l)"
fi

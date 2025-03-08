#!/bin/bash

# Paths
PURITY_FILE="$HOME/.purity"
PYTHON_SCRIPT="$HOME/.config/hypr/scripts/wallpaper/fetch_wallpaper.py"
WALLPAPER_DIR="/usr/share/wallpapers"
CURRENT_WALLPAPER="current_wallpaper"
SAFE_WALLPAPER="safe_wallpaper"
WALLPAPER_LOG="$HOME/.config/hypr/scripts/wallpaper/wallpaper.log"
MAX_IMAGES=100

change_wallpaper() {
  local CURRENT_PURITY="$1"
  local wallpaper_name="$SAFE_WALLPAPER"

  if [[ "$CURRENT_PURITY" != "100" ]]; then
    wallpaper_name="$CURRENT_WALLPAPER"
  fi

  latest_wallpaper=$(ls -t "$WALLPAPER_DIR"| grep $wallpaper_name | head -n 1)
  if [ -z "$latest_wallpaper" ]; then
    echo "$(date): No wallpaper found! $latest_wallpaper" >> "$WALLPAPER_LOG"
    return
  fi

  wallpaper_path="$WALLPAPER_DIR/$latest_wallpaper"
  pkill swaybg
  swaybg -i "$wallpaper_path" -m fill > /dev/null 2>&1
}

clean_old_images() {
IMAGE_COUNT=$(ls "$WALLPAPER_DIR"/* 2>/dev/null | wc -l)
if [ "$IMAGE_COUNT" -gt "$MAX_IMAGES" ]; then
    echo "Cleaning up old wallpapers. Current count: $IMAGE_COUNT" >> "$WALLPAPER_LOG"

    ls -t "$WALLPAPER_DIR"/* | grep -Ev "(safe_wallpaper|current_wallpaper)" | tail -n +"$((MAX_IMAGES + 1))" | xargs -d '\n' rm -f

    echo "Cleanup complete. Remaining images: $(ls "$WALLPAPER_DIR"/* 2>/dev/null | wc -l)" >> "$WALLPAPER_LOG"
fi
}

fetch_wallpaper() {
  local CURRENT_PURITY="$1"

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
  CURRENT_WALLPAPER_FILE="$WALLPAPER_DIR/$SAFE_WALLPAPER.$LATEST_EXTENSION"

  if [[ "$CURRENT_PURITY" != "100" ]]; then
    CURRENT_WALLPAPER_FILE="$WALLPAPER_DIR/$CURRENT_WALLPAPER.$LATEST_EXTENSION"
  fi

  echo "$(date): Latest wallpaper: $LATEST_WALLPAPER" >> "$WALLPAPER_LOG"
  echo "$(date): Current wallpaper: $CURRENT_WALLPAPER_FILE" >> "$WALLPAPER_LOG"

# Check if the latest wallpaper is already set as the current wallpaper
  if [ "$LATEST_WALLPAPER" = "$CURRENT_WALLPAPER_FILE" ]; then
    echo "$(date): The latest wallpaper is the same as the current wallpaper. No update needed." >> "$WALLPAPER_LOG"
  else
    # Copy the latest wallpaper to a consistent file path for swaybg
    cp "$LATEST_WALLPAPER" "$CURRENT_WALLPAPER_FILE"
  fi
}

if [ -n "$1" ]; then
  change_wallpaper "$1"
  exit 0
fi

# Ensure the wallpaper directory exists
mkdir -p "$WALLPAPER_DIR"

if [[ ! -f $PURITY_FILE ]]; then
  echo "100" > "$PURITY_FILE"
fi
CURRENT_PURITY=$(cat "$PURITY_FILE")

fetch_wallpaper $CURRENT_PURITY
change_wallpaper $CURRENT_PURITY

clean_old_images


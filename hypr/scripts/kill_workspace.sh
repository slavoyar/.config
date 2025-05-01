#!/bin/bash

# CONFIG: change this if you want to go to a specific workspace number
TARGET_WORKSPACE_ID=1  # fallback workspace to switch to after cleanup

# Get current workspace ID
current_ws=$(hyprctl activeworkspace -j | jq '.id')

# Get all existing workspaces (excluding current)
existing_workspaces=$(hyprctl workspaces -j | jq -r ".[] | select(.id != $current_ws) | .id")

# Prefer the most recently active one (excluding current)
last_active_ws=$(hyprctl workspaces -j | jq -r ".[] | select(.id != $current_ws) | sort_by(.lastwindowtitle) | reverse | .[0].id")

# Choose where to go
target_ws=${last_active_ws:-$TARGET_WORKSPACE_ID}

# Get clients on the current workspace
clients=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $current_ws) | .address")

# Kill all windows in this workspace
for addr in $clients; do
  hyprctl dispatch focuswindow address:$addr
  sleep 0.1
  hyprctl dispatch killactive
done

# Move to the target workspace
hyprctl dispatch workspace $target_ws

#!/usr/bin/env bash

# File storing the order in which workspaces were opened
history_file="$HOME/.project_workspace_history"

# Get current workspace name
current_workspace=$(hyprctl activeworkspace -j | jq -r '.name')

# Get currently available workspaces (that have windows)
available_workspaces=$(hyprctl workspaces -j | jq -r '.[].name')

# Read workspace history file and preserve order
mapfile -t ordered_workspaces < <(grep -Fx "$available_workspaces" "$history_file" | grep -Fx "$available_workspaces")

# If no valid workspaces, exit
if [ "${#ordered_workspaces[@]}" -eq 0 ]; then
    echo "No project workspaces are currently active."
    exit 1
fi

# If only one, just switch to it
if [ "${#ordered_workspaces[@]}" -eq 1 ]; then
    hyprctl dispatch workspace name:"${ordered_workspaces[0]}"
    exit 0
fi

# Find index of current workspace
current_index=$(printf "%s\n" "${ordered_workspaces[@]}" | grep -nx "$current_workspace" | cut -d: -f1)

# Determine next workspace
if [ -n "$current_index" ]; then
    next_index=$(( (current_index % ${#ordered_workspaces[@]}) + 1 ))
else
    next_index=1
fi

# Switch
next_workspace="${ordered_workspaces[$((next_index-1))]}"
hyprctl dispatch workspace name:"$next_workspace"

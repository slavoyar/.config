#!/usr/bin/bash

# Define named workspaces
workspaces=("lla" "llf" "llb" "lld" "laa")

# Get the current active workspace name
current_workspace=$(hyprctl activeworkspace -j | jq -r '.name')

available_workspaces=$(hyprctl workspaces -j | jq -r '.[].name')

# Filter workspaces to include only available ones
available_workspaces_filtered=()
for workspace in "${workspaces[@]}"; do
    if echo "$available_workspaces" | grep -q "^$workspace$"; then
        available_workspaces_filtered+=("$workspace")
    fi
done

# If only one workspace is available, switch to it
if [ "${#available_workspaces_filtered[@]}" -eq 1 ]; then
    echo "Only one workspace available: ${available_workspaces_filtered[0]}"
    hyprctl dispatch workspace name:"${available_workspaces_filtered[0]}"
    exit 0
fi

# Find the index of the current workspace
current_index=$(printf "%s\n" "${available_workspaces_filtered[@]}" | grep -nx "$current_workspace" | cut -d: -f1)

# Calculate the next workspace index
if [ -n "$current_index" ]; then
    next_index=$(( (current_index % ${#available_workspaces_filtered[@]}) + 1 ))
else
    next_index=1 # Default to the first workspace if the current one is invalid
fi

# Get the next workspace name
next_workspace="${available_workspaces_filtered[$((next_index-1))]}"

# Switch to the next workspace or create it if it doesn't exist
hyprctl dispatch workspace name:"$next_workspace"

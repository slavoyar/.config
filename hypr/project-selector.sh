#!/bin/bash

declare -A projects=(
    ["Lulight Auth"]="$HOME/projects/lulight/auth"
    ["Lulight Frontend"]="$HOME/projects/lulight/frontend"
    ["Lulight Backend"]="$HOME/projects/lulight/backend"
    ["Lulight Deploy"]="$HOME/projects/lulight/deploy"
)

declare -A project_shortcuts=(
    ["Lulight Auth"]="lla"
    ["Lulight Frontend"]="llf"
    ["Lulight Backend"]="llb"
    ["Lulight Deploy"]="lld"
)

# Prompt user to select a project
selected_project=$(printf "%s\n" "${!projects[@]}" | fzf --prompt="Select a project: ")

echo "Selected project: $selected_project"

if [ -n "$selected_project" ]; then
    project_path=${projects[$selected_project]}
    project_shortcut=${project_shortcuts[$selected_project]}

    WINDOW_OPENED=$(hyprctl workspaces -j | jq -r ".[] | select(.name == \"$project_shortcut\") | .windows | length > 0")

    if [ "$WINDOW_OPENED" == "true" ]; then
        hyprctl dispatch workspace name:"$project_shortcut"
    else
        hyprctl dispatch workspace name:"$project_shortcut"
        hyprctl dispatch exec "kitty --title nvim --hold -e bash -c \"cd $project_path && nvim\""
        hyprctl dispatch exec "kitty $project_path"
    fi
else
    echo "No project selected."
    exit 1
fi


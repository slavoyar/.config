#!/bin/bash

declare -A projects=(
    ["Lulight Auth"]="$HOME/projects/lulight/auth"
    ["Lulight Admin"]="$HOME/projects/lulight/admin"
    ["Lulight Frontend"]="$HOME/projects/lulight/frontend"
    ["Lulight Backend"]="$HOME/projects/lulight/backend"
    ["Lulight Deploy"]="$HOME/projects/lulight/deploy"
    ["Portfolio"]="$HOME/projects/portfolio"
    ["Bond Bot"]="$HOME/projects/bond-bot"
)

declare -A project_shortcuts=(
    ["Lulight Auth"]="lla"
    ["Lulight Admin"]="laa"
    ["Lulight Frontend"]="llf"
    ["Lulight Backend"]="llb"
    ["Lulight Deploy"]="lld"
    ["Portfolio"]="PF"
    ["Bond Bot"]="BB"
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
        hyprctl dispatch exec "kitty --title nvim --hold -e bash -c \"cd $project_path && nvim; exec bash\""
        hyprctl dispatch exec "kitty $project_path"
        sleep 0.1
        hyprctl dispatch resizeactive 400 0
    fi
else
    echo "No project selected."
    exit 1
fi


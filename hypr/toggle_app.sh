#!/bin/bash

toggle_app() {
    local WORKSPACE_NAME="$1"
    local APP_NAME="$2"

    WINDOW_OPENED=$(hyprctl workspaces -j | jq -r ".[] | select(.name == \"$WORKSPACE_NAME\") | .windows | length > 0")

    if [ "$WINDOW_OPENED" == "true" ]; then
        hyprctl dispatch workspace name:"$WORKSPACE_NAME"
    else
        hyprctl dispatch workspace name:"$WORKSPACE_NAME"
        exec "$APP_NAME" &  # Open the application in the background
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <workspace_name> <application_command>"
    exit 1
fi

toggle_app "$1" "$2"

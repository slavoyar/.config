#!/bin/bash

toggle_app() {
    local WORKSPACE_NAME="$1"
    local APP_NAME="$2"
    local APP_FLAGS="$3"  # Optional flags

    # Build the command to launch the application
    APP_CMD="$APP_NAME"

    # Append flags if provided
    if [ -n "$APP_FLAGS" ] && [ "$APP_FLAGS" != "" ]; then
        APP_CMD="$APP_CMD $APP_FLAGS"
    fi

    WINDOW_OPENED=$(hyprctl workspaces -j | jq -r ".[] | select(.name == \"$WORKSPACE_NAME\") | .windows | length > 0")

    if [ "$WINDOW_OPENED" == "true" ]; then
        hyprctl dispatch workspace name:"$WORKSPACE_NAME"
    else
        hyprctl dispatch workspace name:"$WORKSPACE_NAME"
        exec $APP_CMD &  # Open the application in the background
    fi
}

if [ "$#" -ne 3 || "$#" -ne 2 ]; then
    echo "Usage: $0 <workspace_name> <application_command> <optional_flags>"
    exit 1
fi

toggle_app "$1" "$2" "$3"

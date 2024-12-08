#!/usr/bin/bash

# Define the monitors
monitor_one="DP-2" 
monitor_two="HDMI-A-1" 

# Define workspace allocation
single_display_workspaces=("lla" "llf" "llb" "lld")
dual_display_monitor_one_workspaces=("lla" "llf")
dual_display_monitor_two_workspaces=("llb" "lld")   # Workspaces for monitor_two in dual display

# Get current monitors and workspace configuration
active_monitors=$(hyprctl monitors -j | jq -r '.[].name')
active_monitor_count=$(echo "$active_monitors" | wc -l)

# Check current display mode
if [ "$active_monitor_count" -eq 1 ]; then
    echo "Switching to dual-display mode..."
    
    # Enable monitor_two (adjust command based on your compositor setup)
    hyprctl keyword monitor "$monitor_two, auto, auto"

    # Move workspaces to the appropriate monitors
    for workspace in "${dual_display_monitor_one_workspaces[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$workspace" "$monitor_one"
    done

    for workspace in "${dual_display_monitor_two_workspaces[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$workspace" "$monitor_two"
    done

else
    echo "Switching to single-display mode..."

    # Disable monitor_two (adjust command based on your compositor setup)
    hyprctl keyword monitor "$monitor_two, disable"

    # Move all workspaces to monitor_one
    for workspace in "${single_display_workspaces[@]}"; do
        hyprctl dispatch moveworkspacetomonitor "$workspace" "$monitor_one"
    done
fi

echo "Display mode toggled successfully."

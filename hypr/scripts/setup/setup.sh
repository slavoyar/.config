#!/bin/bash

#### Check for yay ####
ISYAY=/sbin/yay
if [ -f "$ISYAY" ]; then 
    echo -e "yay was located, moving on.\n"
    yay -Suy
else 
    echo -e "yay was not located, please install yay. Exiting script.\n"
    exit 
fi

echo "Installing yay packages"
### Install all of the above pacakges ####
read -n1 -rep 'Would you like to install the packages? (y,n)' INST
if [[ $INST == "Y" || $INST == "y" ]]; then
    yay -S --noconfirm --needed - < yay-packages.txt

    # Start the bluetooth service
    echo -e "Starting the Bluetooth Service...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
    
    # Clean out other portals
    echo -e "Cleaning out conflicting xdg portals...\n"
    yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk
fi

### Install sddm ###
read -n1 -rep 'Would you like to install sddm? (y,n)' SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
    echo -e "Installing sddm...\n"
    yay -S --noconfirm qt6 sddm win11-sddm-theme
    sudo mkdir -p /etc/sddm.conf.d/
    sudo cp ./sddm/sddm.conf /etc/sddm.conf
    sudo cp ./sddm/kde_settings.conf /etc/sddm.conf.d/kde_settings.conf
    sudo cp ./sddm/theme.conf /usr/share/sddm/themes/win11-sddm-theme/theme.conf
    sudo cp ./sddm/default.conf /usr/lib/sddm/sddm.conf.d/default.conf
    echo -e "Enabling sddm...\n"
    sudo systemctl enable --now sddm.service
fi

BASHRC="$HOME/.bashrc"
### Install teh starship shell ###
read -n1 -rep 'Would you like to install the starship shell? (y,n)' STAR
if [[ $STAR == "Y" || $STAR == "y" ]]; then
    # install the starship shell
    echo -e "Updating .bashrc...\n"
    echo -e '\neval "$(starship init bash)"' >> $BASHRC
    echo -e "copying starship config file to ~/.confg ...\n"
    cp starship.toml ~/.config/
fi

ENV_FILE="/home/yaroslav/.config/hypr/scripts/setup/env_vars"

# Check if the file has already been sourced
if ! grep -q "source $ENV_FILE" "$BASHRC"; then
    echo "Appending environment variables from $ENV_FILE to $BASHRC"
    echo "" >> "$BASHRC"
    echo "# Added by startup script" >> "$BASHRC"
    echo "source $ENV_FILE" >> "$BASHRC"
else
    echo "Environment variables already added to $BASHRC"
fi

### Script is done ###
echo -e "Script had completed.\n"
echo -e "You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep 'Would you like to start Hyprland now? (y,n)' HYP
if [[ $HYP == "Y" || $HYP == "y" ]]; then
    exec Hyprland
else
    exit
fi

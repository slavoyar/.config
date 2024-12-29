# Dotconfig with Hyprland

## Setup Config

### Clone Your Config Repository First

It’s recommended to clone your configuration repository to your home directory before installing yay. This way, you can set up your environment properly from the start.

Clone your configuration repository to your home directory and ensure that the .config folder is owned by your user:

```bash
git clone https://github.com/slavoyar/.config.git $HOME/.config
sudo chown -R $USER:$USER $HOME/.config
```

### Install yay

Follow these steps to install it:

1. Clone the yay Repository:

```bash
git clone https://aur.archlinux.org/yay.git
```

2. Build and Install yay:

```bash
cd yay
makepkg -si
```

3. Ensure that the yay folder is owned by your user:

```bash
sudo chown -R $USER:$USER $HOME/yay
```

4. Clean Up: After installation, you can remove the cloned repository if you wish:

```bash
cd ..
rm -rf yay
```

### Setup Hyprland

Run the Setup Script: After cloning the repository, run the setup script to configure Hyprland:

```bash
cd $HOME/.config/hypr/scripts/setup
chmod +x setup.sh  # Ensure the script is executable
./setup.sh
```

### Start Hyprland

After completing the setup, log out of your current session and select Hyprland from your session manager. 

Log back in, and you should be ready to go!

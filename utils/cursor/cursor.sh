#!/bin/bash

# Cursor IDE Installation & Integration Script for Linux
# This script sets up Cursor IDE with desktop integration, file associations, and update capability

set -e # Exit on error

echo "🔹 Installing Cursor AI IDE..."
sudo apt update
sudo apt install -y curl gpg wget

# Adding keys
# Sourced from https://downloads.cursor.com/keys/anysphere.asc
sudo wget -qO- https://downloads.cursor.com/keys/anysphere.asc | gpg --dearmor > anysphere.gpg
sudo install -o root -g root -m 644 anysphere.gpg /usr/share/keyrings/
rm anysphere.gpg

# Adding repos
# sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/anysphere.gpg] https://downloads.cursor.com/aptrepo stable main" >> /etc/apt/sources.list.d/cursor.list'

# Write repository in deb822 format with Signed-By.
sudo sh -c 'echo "### THIS FILE IS AUTOMATICALLY CONFIGURED ###
# You may comment out this entry, but any other modifications may be lost.
Types: deb
URIs: https://downloads.cursor.com/aptrepo
Suites: stable
Components: main
Architectures: amd64,arm64
Signed-By: /usr/share/keyrings/anysphere.gpg" >> /etc/apt/sources.list.d/cursor.sources'

sudo apt update
sudo apt upgrade -y
sudo apt install -y cursor

# echo "Downloading Cursor AppImage..."
# sudo mkdir -p /opt/cursor
# CURSOR_DIR=/opt/cursor/cursor.AppImage
# sudo rm -rf $CURSOR_DIR
# sudo curl -L https://downloads.cursor.com/production/823f58d4f60b795a6aefb9955933f3a2f0331d7b/linux/x64/Cursor-1.5.5-x86_64.AppImage -o $CURSOR_DIR
# sudo ln -sf $CURSOR_DIR /usr/local/bin/cursor
# sudo chmod +x /usr/local/bin/cursor

    # TMP_DIR=$(mktemp -d)
    # cd $TMP_DIR
    # "/opt/cursor/cursor.AppImage" --appimage-extract >/dev/null 2>&1

# BASE_URL=https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor
# echo "Downloading Cursor icon..."
# sudo curl -L $BASE_URL/cursor.png -o /opt/cursor/cursor.png

# echo "🔹 Creating .desktop entry for Cursor..."
# mkdir -p "$HOME/.local/share/applications"
# rm -f $HOME/.local/share/applications/cursor.desktop
# curl -L $BASE_URL/cursor.desktop -o $HOME/.local/share/applications/cursor.desktop
# chmod +x $HOME/.local/share/applications/cursor.desktop

# mkdir -p ~/.local/share/kio
# mkdir -p ~/.local/share/kio/servicemenus
# curl -L $BASE_URL/openCursor.desktop -o $HOME/.local/share/kio/servicemenus/openCursor.desktop
# chmod +x $HOME/.local/share/kio/servicemenus/openCursor.desktop

xdg-mime default cursor.desktop text/plain
xdg-mime default cursor.desktop application/x-shellscript
xdg-mime default cursor.desktop text/x-script.python
xdg-mime default cursor.desktop text/javascript
xdg-mime default cursor.desktop text/x-c
xdg-mime default cursor.desktop text/x-c++
xdg-mime default cursor.desktop text/x-java

# Update MIME and icon databases
# echo "Updating system databases..."
# update-mime-database "$HOME/.local/share/mime"
# update-desktop-database "$HOME/.local/share/applications"
# gtk-update-icon-cache -f -t "$HOME/.local/share/icons"

# Set Cursor as default editor for git commit messages
git config --global core.editor "cursor --wait"

echo "Cursor AI IDE installation complete. You can find it in your application menu."

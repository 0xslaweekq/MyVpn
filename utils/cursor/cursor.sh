#!/bin/bash

# Cursor IDE Installation & Integration Script for Linux
# This script sets up Cursor IDE with desktop integration, file associations, and update capability

set -e # Exit on error

echo "🔹 Installing Cursor AI IDE..."
sudo apt update
sudo apt install -y curl

echo "Downloading Cursor AppImage..."
sudo mkdir -p /opt/cursor
CURSOR_DIR=/opt/cursor/cursor.AppImage
sudo rm -rf $CURSOR_DIR
sudo curl -L https://downloads.cursor.com/production/9f33c2e793460d00cf95c06d957e1d1b8135fadd/linux/x64/Cursor-1.3.5-x86_64.AppImage -o $CURSOR_DIR
sudo ln -sf $CURSOR_DIR /usr/local/bin/cursor
sudo chmod +x /usr/local/bin/cursor

    # TMP_DIR=$(mktemp -d)
    # cd $TMP_DIR
    # "/opt/cursor/cursor.AppImage" --appimage-extract >/dev/null 2>&1

BASE_URL=https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor
echo "Downloading Cursor icon..."
sudo curl -L $BASE_URL/cursor.png -o /opt/cursor/cursor.png

echo "🔹 Creating .desktop entry for Cursor..."
mkdir -p "$HOME/.local/share/applications"
rm -f $HOME/.local/share/applications/cursor.desktop
curl -L $BASE_URL/cursor.desktop -o $HOME/.local/share/applications/cursor.desktop
chmod +x $HOME/.local/share/applications/cursor.desktop

mkdir -p ~/.local/share/kio
mkdir -p ~/.local/share/kio/servicemenus
curl -L $BASE_URL/openCursor.desktop -o $HOME/.local/share/kio/servicemenus/openCursor.desktop
chmod +x $HOME/.local/share/kio/servicemenus/openCursor.desktop

xdg-mime default cursor.desktop text/plain
xdg-mime default cursor.desktop application/x-shellscript
xdg-mime default cursor.desktop text/x-script.python
xdg-mime default cursor.desktop text/javascript
xdg-mime default cursor.desktop text/x-c
xdg-mime default cursor.desktop text/x-c++
xdg-mime default cursor.desktop text/x-java

# Update MIME and icon databases
echo "Updating system databases..."
update-mime-database "$HOME/.local/share/mime"
update-desktop-database "$HOME/.local/share/applications"
gtk-update-icon-cache -f -t "$HOME/.local/share/icons"

# Set Cursor as default editor for git commit messages
git config --global core.editor "/opt/cursor/cursor.AppImage --no-sandbox --wait"

echo "Cursor AI IDE installation complete. You can find it in your application menu."

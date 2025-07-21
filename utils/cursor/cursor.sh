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
sudo curl -L https://downloads.cursor.com/production/a8e95743c5268be73767c46944a71f4465d05c90/linux/x64/Cursor-1.2.4-x86_64.AppImage -o $CURSOR_DIR
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
rm $HOME/.local/share/applications/cursor.desktop
curl -L $BASE_URL/cursor.desktop -o $HOME/.local/share/applications/cursor.desktop
chmod +x $HOME/.local/share/applications/cursor.desktop

mkdir -p ~/.local/share/kio
mkdir -p ~/.local/share/kio/servicemenus
curl -L $BASE_URL/openCursor.desktop -o $HOME/.local/share/kio/servicemenus/openCursor.desktop
chmod +x $HOME/.local/share/kio/servicemenus/openCursor.desktop

# echo "🔹 Creating update script for Cursor..."
# sudo curl -L $BASE_URL/update-cursor.sh -o /opt/cursor/update-cursor.sh
# sudo chmod +x /opt/cursor/update-cursor.sh

# echo "🔹 Creating update service for Cursor..."
# sudo curl -L $BASE_URL/update-cursor.service -o /etc/systemd/system/update-cursor.service
# sudo systemctl daemon-reload
# sudo systemctl enable update-cursor
# sudo systemctl start update-cursor
# sudo systemctl status update-cursor
# sudo systemctl stop update-cursor
# sudo systemctl disable update-cursor

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

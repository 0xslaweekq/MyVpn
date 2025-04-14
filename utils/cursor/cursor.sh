#!/bin/bash
set -e

if ! [ -f /opt/cursor/cursor.appimage ]; then
    echo "🔹 Installing Cursor AI IDE..."
    sudo apt update
    sudo apt install -y curl

    echo "Downloading Cursor AppImage..."
    sudo mkdir -p /opt/cursor
    sudo curl -L https://downloads.cursor.com/production/7801a556824585b7f2721900066bc87c4a09b743/linux/x64/Cursor-0.48.8-x86_64.AppImage -o /opt/cursor/cursor.appimage
    sudo chmod +x /opt/cursor/cursor.appimage
    sudo ln -s /opt/cursor/cursor.appimage /usr/local/bin/cursor

    BASE_URL=https://raw.githubusercontent.com/0xSlaweekq/MyVpn/main/utils/cursor
    echo "Downloading Cursor icon..."
    sudo curl -L $BASE_URL/cursor.png -o /opt/cursor/cursor.png

    echo "🔹 Creating .desktop entry for Cursor..."
    mkdir -p "$HOME/.local/share/applications"
    curl -L $BASE_URL/cursor.desktop -o $HOME/.local/share/applications/cursor.desktop

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

    # Set Cursor as default editor for git commit messages
    git config --global core.editor "/opt/cursor/cursor.appimage --wait"

    update-desktop-database "$HOME/.local/share/applications"

    echo "Cursor AI IDE installation complete. You can find it in your application menu."
else
    echo "🔹 Cursor AI IDE is already installed."
fi

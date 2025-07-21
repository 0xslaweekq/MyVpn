#!/bin/bash
set -e

if ! [ -f /opt/cursor.AppImage ]; then
    echo "🔹 Installing Cursor AI IDE..."
    sudo apt update
    sudo apt install -y curl wget

    echo "Downloading Cursor AppImage..."
    sudo curl -L https://downloader.cursor.sh/linux/appImage/x64 -o /opt/cursor.AppImage
    sudo chmod +x /opt/cursor.AppImage

    echo "Downloading Cursor icon..."
    sudo curl -L https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png -o /opt/cursor.png

    echo "Creating .desktop entry for Cursor..."
    mkdir -p "$HOME/.local/share/applications"
    bash -c "cat > $HOME/.local/share/applications/cursor.desktop" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=/opt/cursor.AppImage --no-sandbox
Icon=/opt/cursor.png
Terminal=false
Type=Application
Categories=Development;
MimeType=text/plain;
EOL

    xdg-mime default cursor.desktop text/plain
    xdg-mime default cursor.desktop application/x-shellscript
    xdg-mime default cursor.desktop text/x-script.python
    xdg-mime default cursor.desktop text/javascript
    xdg-mime default cursor.desktop text/x-c
    xdg-mime default cursor.desktop text/x-c++
    xdg-mime default cursor.desktop text/x-java

    # Set Cursor as default editor for git commit messages
    git config --global core.editor "/opt/cursor.AppImage --wait"

    update-desktop-database "$HOME/.local/share/applications"

    echo "Adding alias for Cursor..."
    BASHRC_FILE="$HOME/.bashrc"
    ALIAS_LINE="alias cursor='/opt/cursor.AppImage --no-sandbox'"

    if ! grep -q "alias cursor=" "$BASHRC_FILE"; then
        echo "$ALIAS_LINE" >> "$BASHRC_FILE"
        echo "Alias 'cursor' added to .bashrc"
        echo "You can now run Cursor by typing 'cursor' in terminal after restarting your shell or running 'source ~/.bashrc'"
    else
        echo "Alias 'cursor' already exists in .bashrc"
    fi

    echo "Cursor AI IDE installation complete. You can find it in your application menu."
    source "$BASHRC_FILE"
else
    echo "🔹 Cursor AI IDE is already installed."
fi

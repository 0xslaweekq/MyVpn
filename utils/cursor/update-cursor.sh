#!/bin/bash

sudo curl -L https://downloader.cursor.sh/linux/appImage/x64 -o /opt/cursor/cursor_new.AppImage

if [ -f /opt/cursor/cursor_new.AppImage ]; then
    sudo rm /opt/cursor/cursor.AppImage
    sudo mv /opt/cursor/cursor_new.AppImage /opt/cursor/cursor.AppImage
    sudo chmod +x /opt/cursor/cursor.AppImage
fi

exit 0

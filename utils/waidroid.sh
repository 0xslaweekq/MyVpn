#!/bin/bash

sudo apt install curl ca-certificates -y
curl -s https://repo.waydro.id | sudo bash
sudo apt install waydroid -y
sudo systemctl enable --now waydroid-container

sudo waydroid init
sudo waydroid container start
waydroid session start

# waydroid session stop
# sudo waydroid container stop
# sudo apt remove waydroid
# sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid

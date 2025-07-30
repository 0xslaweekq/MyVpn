#!/bin/bash

set -e

sudo apt update

echo "🔹 Installing xanmod kernel..."
if ! dpkg -l | grep -q "linux-xanmod"; then
    wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-kernel.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/xanmod-kernel.gpg] http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-release.list
    sudo apt update
    # sudo apt install -y \
    #     linux-xanmod-rt-x64v3 \
    #     linux-xanmod-lts-x64v3 \
    #     linux-xanmod-x64v3
    sudo apt install --reinstall -y linux-xanmod-lts-x64v3
    sudo update-initramfs -u
    sudo update-grub2
    sudo update-grub
else
    echo "Xanmod kernel is already installed."
fi

sudo dpkg --configure -a
sudo apt install -y -f
sudo apt install --fix-broken -y
echo "Current kernel version:"
cat /proc/version

# echo "🔹 Configuring swap (32GB)..."
# sudo swapon --show
# free -h
# df -h
# sudo swapoff -a

# # Check if swapfile already exists with correct size
# SWAP_SIZE=$(sudo du -h /swapfile 2>/dev/null | awk '{print $1}' | tr -d 'G')
# if [ "$SWAP_SIZE" != "32" ]; then
#     echo "Creating 32GB swap file..."
#     sudo dd if=/dev/zero of=/swapfile bs=1M count=32768 oflag=append conv=notrunc
#     sudo chmod 600 /swapfile
#     sudo mkswap /swapfile
# fi
# sudo swapon /swapfile

# if ! grep -q "/swapfile" /etc/fstab; then
#     sudo cp /etc/fstab /etc/fstab.bak
#     echo "/swapfile swap swap sw 0 0" | sudo tee -a /etc/fstab
# fi

cat /proc/sys/vm/swappiness
sudo sysctl vm.swappiness=10
cat /proc/sys/vm/vfs_cache_pressure
sudo sysctl vm.vfs_cache_pressure=50
cat /proc/sys/fs/inotify/max_user_watches
sudo sysctl fs.inotify.max_user_watches=524288
sudo tee -a /etc/sysctl.conf <<< \
"
vm.swappiness=10
vm.vfs_cache_pressure=50
fs.inotify.max_user_watches=524288"

echo "🔹 System optimization completed successfully!"
echo "🔹 It is recommended to reboot your system to apply all changes."
read -r -p "Would you like to reboot now? (y/n): " RESTART
if [[ $RESTART == "y" || $RESTART == "Y" ]]; then
    sudo reboot
else
    echo "Please reboot your system manually later to apply all changes."
fi

# Liquorix Kernel:
# curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
# sudo add-apt-repository ppa:liquorix-team/liquorix
# sudo apt update
# sudo apt install linux-image-liquorix-amd64

# Zen Kernel:
# sudo add-apt-repository ppa:teejee2008/ppa
# sudo apt update
# sudo apt install linux-zen

# mainline kernel
# sudo add-apt-repository ppa:teejee2008/ppa
# sudo apt update
# sudo apt install ukuu
# ukuu --install-latest

# echo "🔹 Installing mainline kernel..."
# if ! command_exists mainline; then
#     sudo add-apt-repository -y ppa:cappelikan/ppa
#     sudo apt update
#     sudo apt install -y mainline
# else
#     echo "Mainline is already installed."
# fi

# dpkg -l | grep linux-image
# srp linux-image-6.13.4-x64v3-xanmod1
# sudo update-grub
# supd

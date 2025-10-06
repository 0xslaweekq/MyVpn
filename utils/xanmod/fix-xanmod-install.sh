#!/bin/bash

set -e

echo "Fixing XanMod kernel installation errors..."

# 1. Remove problematic VirtualBox module
echo "Removing problematic VirtualBox module..."
if dkms status | grep -q virtualbox; then
    sudo dkms remove virtualbox/7.0.20 --all || true
    echo "VirtualBox module removed from DKMS"
else
    echo "VirtualBox module not found in DKMS"
fi

# 2. Clean package cache and fix dependencies
echo "Cleaning package cache and fixing dependencies..."
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y

# 3. Fix package configuration
echo "Fixing package configuration..."
sudo dpkg --configure -a
sudo apt install -f -y

# 4. Reinstall XanMod packages
echo "Reinstalling XanMod packages..."
sudo apt install --reinstall -y linux-image-6.16.10-x64v3-xanmod1 || {
    echo "Failed to reinstall kernel image"
    exit 1
}

sudo apt install --reinstall -y linux-headers-6.16.10-x64v3-xanmod1 || {
    echo "Failed to reinstall kernel headers"
    exit 1
}

sudo apt install --reinstall -y linux-xanmod-x64v3 || {
    echo "Failed to reinstall XanMod metapackage"
    exit 1
}

# 5. Update initramfs and GRUB
echo "Updating initramfs and GRUB..."
sudo update-initramfs -u -k 6.16.10-x64v3-xanmod1
sudo update-grub

# 6. Check installation status
echo "Checking installation status..."
if dpkg -l | grep -q "ii.*linux-xanmod-x64v3"; then
    echo "XanMod kernel successfully installed!"
else
    echo "Problems with XanMod kernel installation"
    exit 1
fi

# 7. Show available kernels
echo "Available kernels in system:"
ls -la /boot/vmlinuz-* | grep -E "(xanmod|generic)" | sort

# 8. Check GRUB configuration
echo "GRUB entries for kernels:"
sudo grep "menuentry.*Ubuntu" /boot/grub/grub.cfg | head -5

# 9. Optionally: reinstall VirtualBox (if needed)
read -r -p "Do you want to reinstall VirtualBox? (y/n): " REINSTALL_VBOX
if [[ $REINSTALL_VBOX == "y" || $REINSTALL_VBOX == "Y" ]]; then
    echo "Reinstalling VirtualBox..."
    sudo apt remove --purge -y virtualbox-dkms virtualbox || true
    sudo apt install -y virtualbox virtualbox-dkms
    echo "VirtualBox reinstalled"
fi

echo "Fix completed!"
echo "It is recommended to reboot the system to apply changes."

read -r -p "Reboot now? (y/n): " REBOOT_NOW
if [[ $REBOOT_NOW == "y" || $REBOOT_NOW == "Y" ]]; then
    echo "Rebooting system..."
    sudo reboot
else
    echo "Don't forget to reboot the system later!"
    echo ""
    echo "After reboot execute:"
    echo "  1. Check kernel version: uname -r"
    echo "  2. Set CPU performance mode: echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
fi

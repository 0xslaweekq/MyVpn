#!/bin/bash

set -e

echo "Complete XanMod kernel cleanup and reinstallation..."

echo "WARNING: This script will completely remove all XanMod kernels and reinstall them from scratch!"
read -r -p "Continue? (y/n): " CONTINUE
if [[ $CONTINUE != "y" && $CONTINUE != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# 1. Remove all DKMS modules for problematic kernels
echo "Removing DKMS modules..."
for module in virtualbox nvidia msi_ec; do
    if dkms status | grep -q "$module"; then
        echo "Removing module $module..."
        sudo dkms remove "$module" --all || true
    fi
done

# 2. Remove all XanMod packages
echo "Removing XanMod packages..."
sudo apt remove --purge -y linux-xanmod* || true
sudo apt remove --purge -y linux-image-*xanmod* || true
sudo apt remove --purge -y linux-headers-*xanmod* || true

# 3. Clean up remnants
echo "Cleaning up remnants..."
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

# 4. Remove old kernel files
echo "Removing old XanMod kernel files..."
sudo rm -f /boot/vmlinuz-*xanmod* || true
sudo rm -f /boot/initrd.img-*xanmod* || true
sudo rm -f /boot/System.map-*xanmod* || true
sudo rm -f /boot/config-*xanmod* || true

# 5. Remove kernel modules
echo "Removing XanMod kernel modules..."
sudo rm -rf /lib/modules/*xanmod* || true

# 6. Update GRUB after removal
echo "Updating GRUB after removal..."
sudo update-grub

# 7. Fix any package problems
echo "Fixing package problems..."
sudo dpkg --configure -a
sudo apt install -f -y

# 8. Reinstall XanMod repository
echo "Setting up XanMod repository..."
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/xanmod-release.list

# 9. Update package lists
echo "Updating package lists..."
sudo apt update

# 10. Install XanMod kernel fresh
echo "Installing XanMod kernel..."
sudo apt install -y linux-xanmod-x64v3

# 11. Update initramfs and GRUB
echo "Updating initramfs and GRUB..."
sudo update-initramfs -u
sudo update-grub

# 12. Check installation
echo "Checking installation..."
if dpkg -l | grep -q "ii.*linux-xanmod"; then
    echo "XanMod kernel successfully reinstalled!"
else
    echo "Problems with XanMod kernel reinstallation"
    exit 1
fi

# 13. Show available kernels
echo "Available kernels in system:"
ls -la /boot/vmlinuz-* | sort

# 14. Configure system
echo "Configuring system parameters..."
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50
sudo sysctl fs.inotify.max_user_watches=524288

# Add to sysctl.conf if not already there
if ! grep -q "vm.swappiness=10" /etc/sysctl.conf; then
    sudo tee -a /etc/sysctl.conf <<< "
# XanMod optimizations
vm.swappiness=10
vm.vfs_cache_pressure=50
fs.inotify.max_user_watches=524288"
fi

echo "Reinstallation completed successfully!"
echo "System reboot is required to boot into the new kernel."

read -r -p "Reboot now? (y/n): " REBOOT_NOW
if [[ $REBOOT_NOW == "y" || $REBOOT_NOW == "Y" ]]; then
    echo "Rebooting system..."
    sudo reboot
else
    echo "Don't forget to reboot the system!"
    echo ""
    echo "After reboot:"
    echo "  1. Check kernel version: uname -r"
    echo "  2. Set performance mode: echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
    echo "  3. If needed, reinstall VirtualBox: sudo apt install virtualbox virtualbox-dkms"
fi

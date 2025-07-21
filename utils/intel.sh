#!/bin/bash

# Install the Intel graphics GPG public key
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
  sudo gpg --yes --dearmor --output /usr/share/keyrings/intel-graphics.gpg

# Configure the repositories.intel.com package repository
echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu noble client" | \
  sudo tee /etc/apt/sources.list.d/intel-gpu-noble.list

# Update the package repository meta-data
sudo apt update

# Install the compute-related packages
sudo apt install -y libigdgmm12
sudo apt install -y libze1 intel-level-zero-gpu intel-opencl-icd clinfo
sudo apt install -y libze-dev intel-ocloc

clinfo | grep "Device Name"
sudo gpasswd -a ${USER} render
newgrp render

sudo apt install -y qemu-kvm qemu-utils \
  libvirt-daemon-system libvirt-clients \
  bridge-utils \
  virt-manager ovmf gir1.2-spiceclientgtk-3.0

sudo apt install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero \
  libmfx1 libmfxgen1 libvpl2 va-driver-all vainfo \
  intel-gpu-tools intel-media-va-driver mesa-utils nvtop
sudo update-grub

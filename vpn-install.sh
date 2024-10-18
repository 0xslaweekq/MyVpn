# cd ~ && \
# curl -O https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/vpn-install.sh
# chmod +x vpn-install.sh
# sudo ./vpn-install.sh
# echo "First add new user"
# adduser msi
# sudo usermod -aG sudo msi
# su - msi
# sudo nano ~/.ssh/authorized_keys
# edit config
# sudo nano /etc/ssh/sshd_config
# PermitRootLogin no
# PubkeyAuthentication yes
# AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
# PasswordAuthentication no
# PermitEmptyPasswords no ???
# sudo systemctl restart sshd

echo "Updating system"
echo '#################################################################'
tee -a ~/.bashrc <<< \
'
alias si="sudo apt install -y"
alias srf="sudo rm -rf"
alias srn="sudo reboot now"
alias srp="sudo apt remove --purge -y"
alias sdr="sudo systemctl daemon-reload"
alias supd="sudo apt update && sudo apt upgrade -y && sudo apt install --fix-broken -y && sudo apt autoremove -y && sudo apt autoclean -y"
'
sudo apt update
sudo apt upgrade -y
sudo apt install --fix-broken -y
sudo apt autoclean -y
sudo apt autoremove --purge
sudo apt install -y git nano resolvconf curl wireguard wireguard-tools

echo "Installing 3proxy"
echo '#################################################################'
cd ~
curl -O https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/3proxy-install.sh
curl -O https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/3proxy-uninstall.sh
chmod +x 3proxy-install.sh
chmod +x 3proxy-uninstall.sh
sudo ./3proxy-install.sh

sudo reboot now

echo "Installing Docker"
echo '#################################################################'
curl -sSL https://get.docker.com | sh \
  sudo usermod -aG docker $(whoami) \
  exit

echo "Installing Outline"
echo '#################################################################'
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 22/tcp
sudo ufw allow 39885/tcp
sudo ufw allow 1586/tcp
sudo ufw allow 1586/udp

sudo wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash

# wget https://s3.amazonaws.com/outline-releases/manager/linux/stable/Outline-Manager.AppImage
# wget https://s3.amazonaws.com/outline-releases/client/linux/stable/Outline-Client.AppImage
# chmod +x ./Outline-Manager.AppImage
# chmod +x ./Outline-Client.AppImage
# ./Outline-Manager.AppImage
# ./Outline-Client.AppImage

# echo "Installing wireguard"
# echo '#################################################################'
# cd ~
# wget https://git.io/wireguard -O wireguard-install.sh && sudo bash wireguard-install.sh
# curl -O https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/wireguard-install.sh
# curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
# chmod +x wireguard-install.sh
# sudo ./wireguard-install.sh


# {"apiUrl":"https://164.90.227.142:2389/tKuGyVsoKI7QEMt_X5A5Ew","certSha256":"5496A22D7C2FBD739984115375CB3B2119B61260CD976A33B6DF78E62D6F700D"}

# ssh-keygen -f "/home/msi/.ssh/known_hosts" -R "178.128.17.181"

# curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | \
#   sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
# curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | \
#   sudo tee /etc/apt/sources.list.d/tailscale.list
# sudo apt update
# sudo apt install -y tailscale
# sudo tailscale up
# tailscale ip -4
# 2C-4D-54-E9-02-BD

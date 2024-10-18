echo Updating system
echo '#################################################################'
sudo apt install -y git wget nano resolvconf curl build-essential gcc make
echo "Download and unpack the sources"
cd ~
sudo wget https://github.com/0xSlaweekq/setup/raw/main/vpn/3proxy-0.9.4.tar.gz

tar xzf 3proxy-0.9.4.tar.gz
cd ~/3proxy-0.9.4

echo "Compiling"
sudo make -f Makefile.Linux

echo "Installing"
sudo mkdir /etc/3proxy
cd ~/3proxy-0.9.4/bin
sudo cp 3proxy /usr/bin/
cd /etc/3proxy/

sudo adduser --system --no-create-home --disabled-login --group slaweekq
id slaweekq

echo "Getting config & proxyauth"
sudo wget https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/3proxy.cfg
sudo wget https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/.proxyauth

echo "Setting access rights to proxy server files"
# sudo chmod 600 /etc/3proxy/
sudo chown slaweekq:slaweekq -R /etc/3proxy
sudo chown slaweekq:slaweekq /usr/bin/3proxy
sudo chmod 444 /etc/3proxy/3proxy.cfg
sudo chmod 400 /etc/3proxy/.proxyauth

echo "Setting 3proxy.service"
cd /etc/systemd/system
sudo wget https://raw.githubusercontent.com/0xSlaweekq/setup/main/vpn/3proxy.service
cd ~

echo "Enable & starting 3proxy.service"
sudo systemctl daemon-reload
sudo systemctl enable 3proxy
sudo systemctl start 3proxy
sudo ps -ela | grep "3proxy"
  # && sudo systemctl status 3proxy.service \

echo "Oppening port 3128 & 2525"
sudo iptables -I INPUT -p tcp -m tcp --dport 3128 -j ACCEPT
sudo iptables -I INPUT -p tcp -m tcp --dport 2525 -j ACCEPT

echo "Deleting temporery files"
sudo rm -rf ~/3proxy-0.9.4.tar.gz ~/3proxy-0.9.4
cd ~
sudo systemctl daemon-reload
echo "3proxy installed & running now"
echo '#################################################################'

# echo "settings & example
# sudo nano /etc/3proxy/3proxy.cfg
# nano ~/3proxy-0.9.4/cfg/3proxy.cfg.sample
# nano ~/3proxy-0.9.4/doc/ru/example1.txt
# nano ~/3proxy-0.9.4/scripts/3proxy.service"

# . *.ru;*.github.com;*.google.com;*.youtube.com;*.digitalocean.com;*.telegram.org;*.tg.me;*.binance.com;*.huobi;*.okx;*.bybit;*.htx;*.sbrf;*.gpb;*.metamask

#!/bin/bash

set -e

echo "🔹 Installing MSI EC (Battery Charge Control)..."
if ! dkms status | grep -q "msi_ec"; then
  sudo apt update
  sudo apt install -y git build-essential dkms

  # Clone repository with proper error handling
  if [ -d "/tmp/msi-ec" ]; then
    sudo rm -rf /tmp/msi-ec
  fi

  sudo git clone https://github.com/BeardOverflow/msi-ec.git /tmp/msi-ec
  cd /tmp/msi-ec
  sudo make dkms-install
  sudo make
  sudo make install
  sudo modprobe msi_ec

  cd "$HOME"
else
  echo "...MSI EC module already installed, skipping..."
fi

echo "🔹 Create automatic MSI battery charge control..."
if [ -f "/usr/local/bin/msi_battery_control.sh" ]; then
  sudo rm -f /usr/local/bin/msi_battery_control.sh
fi

sudo tee /usr/local/bin/msi_battery_control.sh > /dev/null <<EOL
#!/bin/bash
while true; do
  charge_level=\$(cat /sys/class/power_supply/BAT1/capacity)
  if [ "\$charge_level" -ge 97 ]; then
    echo "Charge disabled!"
    sudo msi-ec -w 0x2F 0
  elif [ "\$charge_level" -le 30 ]; then
    echo "Charge enabled!"
    sudo msi-ec -w 0x2F 1
  fi
  sleep 60
done
EOL

sudo chmod +x /usr/local/bin/msi_battery_control.sh

echo "🔹 Setting up automatic battery charge control..."
if [ -f "/etc/systemd/system/msi-battery.service" ]; then
  sudo rm -f /etc/systemd/system/msi-battery.service
fi

sudo tee /etc/systemd/system/msi-battery.service > /dev/null <<EOL
[Unit]
Description=MSI Smart Battery Control
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/msi_battery_control.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOL

echo "🔹 Enable and start the service..."
sudo systemctl daemon-reload
sudo systemctl enable msi-battery.service
sudo systemctl start msi-battery.service

echo "🔹 Installing Qt 6.9.0 build dependencies..."
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
sudo apt update
sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-tools-dev

sudo cp /mnt/D/CRYPTO/MyVpn/utils/qt-online.run /tmp/qt-online.run
cd /tmp
chmod +x ./qt-online.run
./qt-online.run
cd ~

# Добавляем пути Qt 6.9.0 в .bashrc
echo 'export PATH=$HOME/Qt/6.9.0/gcc_64/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$HOME/Qt/6.9.0/gcc_64/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export QT_PLUGIN_PATH=$HOME/Qt/6.9.0/gcc_64/plugins:$QT_PLUGIN_PATH' >> ~/.bashrc
echo 'export QML2_IMPORT_PATH=$HOME/Qt/6.9.0/gcc_64/qml:$QML2_IMPORT_PATH' >> ~/.bashrc

# Применяем изменения к текущей сессии
source ~/.bashrc

# Создаем символические ссылки для основных библиотек Qt
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Core.so.6 /usr/lib/libQt6Core.so.6
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Gui.so.6 /usr/lib/libQt6Gui.so.6
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Widgets.so.6 /usr/lib/libQt6Widgets.so.6
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Network.so.6 /usr/lib/libQt6Network.so.6
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Qml.so.6 /usr/lib/libQt6Qml.so.6
sudo ln -sf $HOME/Qt/6.9.0/gcc_64/lib/libQt6Quick.so.6 /usr/lib/libQt6Quick.so.6

# Обновляем кэш библиотек
sudo ldconfig

# Создаем файл конфигурации для ldconfig
sudo bash -c "echo '$HOME/Qt/6.9.0/gcc_64/lib' > /etc/ld.so.conf.d/qt6.conf"
sudo ldconfig

# Создаем альтернативу для qmake6
sudo update-alternatives --install /usr/bin/qmake6 qmake6 $HOME/Qt/6.9.0/gcc_64/bin/qmake6 100
source ~/.bashrc
qmake6 --version

if command -v mcontrolcenter &> /dev/null; then
    echo "MControlCenter already installed, skipping..."
else
    echo "🔹 Installing MControlCenter..."
    if [ ! -f "/tmp/MControlCenter.tar.gz" ]; then
        sudo wget -c "https://github.com/dmitry-s93/MControlCenter/releases/download/0.5.0/MControlCenter-0.5.0-bin.tar.gz" -O /tmp/MControlCenter.tar.gz
    fi
    if [ -d "/tmp/MControlCenter-0.5.0-bin" ]; then
       sudo rm -rf /tmp/MControlCenter-0.5.0-bin
    fi

    sudo tar -xzf /tmp/MControlCenter.tar.gz -C /tmp
    cd /tmp/MControlCenter-0.5.0-bin
    sudo ./install.sh

    cd "$HOME"
fi

echo "🔹 Installation completed successfully!"
echo "🔹 You can now run MControlCenter by typing 'mcontrolcenter' in terminal or finding it in your applications menu."

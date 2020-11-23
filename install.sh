#!/bin/bash

# install required python packages
echo "[INSTALL] Updating..."
sudo apt-get update
sudo apt-get install python-requests

# add crontab to restart twice per day
echo "[INSTALL] Setup crontabs..."
echo "15 4 * * * /sbin/shutdown -r now" > tmp
sudo crontab tmp
rm tmp
echo "15 16 * * * /sbin/shutdown -r now" > tmp
sudo crontab tmp
rm tmp

# create configuration file
echo "[INSTALL] Creating config file..."
touch config.txt
echo $1 > config.txt

# install sensor script as service
echo "[INSTALL] Configuring daemon..."
sudo cp sensor.service /lib/systemd/system/sensor.service

sudo chmod 644 /lib/systemd/system/sensor.service
chmod +x sensor.py
sudo systemctl daemon-reload
sudo systemctl enable sensor.service
sudo systemctl start sensor.service

# add network configuration
echo "[INSTALL] Setup network interfaces..."
sudo cp interfaces /etc/network/interfaces

# set up wifi
echo "[INSTALL] Starting wifi-setup.sh..."
sudo bash wifi-setup.sh
sudo cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

# restart
echo "[INSTALL] Reboot..."
sudo reboot

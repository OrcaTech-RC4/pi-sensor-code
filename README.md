# pi-sensor-code
Code for Raspberry Pi to monitor and transmit laundry machine sensor readout

# Installation
1. Clone repo to `/home/pi`, using `git clone <repo link> .` in that folder.
2. Change the raspi setting to enable ssh and wait for network before startup.
3. Run `bash install.sh` in the UNIX terminal and enter the necessary prompts.
4. The raspberry pi will reboot after the installation is successful, and runs `sensor.py` on startup.

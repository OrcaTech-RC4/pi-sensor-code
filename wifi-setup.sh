#!/bin/bash

countrycode="SG"

echo Enter NUSNET ID to setup
read -p 'NUSNET (e0123456): ' nusnetid

userid="nusstu\\$nusnetid"

passmatch=false

getpass() {
    read -sp 'Password: ' userpass
    echo
    read -sp 'Confirm password: ' userpassconf

    if [[ "$userpass" == "$userpassconf" ]]; then
        passmatch=true
    else
        passmatch=false
    fi
}

getpass
while [[ "$passmatch" == false ]];
do
    echo
    echo Wrong password entered\!
    echo Please re-enter your password.
    getpass
done

# https://eparon.me/2016/09/09/rpi3-enterprise-wifi.html
passhashraw=`echo -n "${userpass}" | iconv -t utf16le | openssl md4`

# https://stackoverflow.com/questions/21906330/remove-stdin-label-in-bash
passhash=${passhashraw#*= }

echo pass is "${userpass}"
echo passhash is $passhash

# https://eparon.me/2016/09/09/rpi3-enterprise-wifi.html
wpasuppconftext="ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$countrycode

network={
    priority=1
    ssid=\"NUS_STU_2-4GHz\"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity=$userid
    password=hash:$passhash
    phase2=\"auth=MSCHAPV2\"
    }"

read -p "WARNING. This will replace the contents of wpa_supplicant.conf file permanently. Continue? [Y]: " userconfirmation

# https://unix.stackexchange.com/questions/47584/in-a-bash-script-using-the-conditional-or-in-an-if-statement
if [[ "$userconfirmation" == "Y" || "$userconfirmation" == "y" ]]; then
    # https://linuxize.com/post/bash-append-to-file/
    echo "$wpasuppconftext" > wpa_supplicant.conf
    echo "It's nice to meet you $userid"
    echo "Wifi setup complete"
else
    echo "Wifi setup cancelled."
fi
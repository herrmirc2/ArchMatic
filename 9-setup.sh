#!/usr/bin/env bash
#-------------------------------------------------------------------------
#      _          _    __  __      _   _    
#     /_\  _ _ __| |_ |  \/  |__ _| |_(_)__ 
#    / _ \| '_/ _| ' \| |\/| / _` |  _| / _|
#   /_/ \_\_| \__|_||_|_|  |_\__,_|\__|_\__| 
#  Arch Linux Post Install Setup and Config
#-------------------------------------------------------------------------

echo
echo "FINAL SETUP AND CONFIGURATION"

# ------------------------------------------------------------------------

echo
echo "Genaerating .xinitrc file"

# Generate the .xinitrc file so we can launch XFCE from the
# terminal using the "startx" command
cat <<EOF > ${HOME}/.xinitrc
#!/bin/bash

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "\$f" ] && . "\$f"
    done
    unset f
fi

source /etc/xdg/xfce4/xinitrc
exit 0
EOF

# ------------------------------------------------------------------------

echo
echo "Updating /bin/startx to use the correct path"

# By default, startx incorrectly looks for the .serverauth file in our HOME folder.
sudo sed -i 's|xserverauthfile=\$HOME/.serverauth.\$\$|xserverauthfile=\$XAUTHORITY|g' /bin/startx

# ------------------------------------------------------------------------



# ------------------------------------------------------------------------

echo
echo "Configuring MAKEPKG to use all 8 cores"

sudo sed -i -e 's|[#]*MAKEFLAGS=.*|MAKEFLAGS="-j$(nproc)"|g' makepkg.conf
sudo sed -i -e 's|[#]*COMPRESSXZ=.*|COMPRESSXZ=(xz -c -T 2 -z -)|g' makepkg.conf

# ------------------------------------------------------------------------

echo
echo "Configuring vconsole.conf to set a larger font for login shell"

sudo cat <<EOF > /etc/vconsole.conf
KEYMAP=us
FONT=ter-v32b
EOF


echo
echo "Disabling Pulse .esd_auth module"

# Pulse audio loads the `esound-protocol` module, which best I can tell is rarely needed.
# That module creates a file called `.esd_auth` in the home directory which I'd prefer to not be there. So...
sudo sed -i 's|load-module module-esound-protocol-unix|#load-module module-esound-protocol-unix|g' /etc/pulse/default.pa

# ------------------------------------------------------------------------

echo
echo "Enabling bluetooth daemon and setting it to auto-start"

sudo sed -i 's|#AutoEnable=false|AutoEnable=true|g' /etc/bluetooth/main.conf
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# ------------------------------------------------------------------------



# ------------------------------------------------------------------------

echo
echo "Enabling Network Time Protocol so clock will be set via the network"

sudo ntpd -qg
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service


echo "Done!"
echo 
echo "Reboot now..."
echo

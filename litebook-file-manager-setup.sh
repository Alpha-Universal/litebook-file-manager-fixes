#!/bin/bash -
#
#   Name    :   litebook-file-manager-setup.sh
#   Author  :   Richard Buchanan II for Alpha Universal, LLC
#   Brief   :   A script that sets up all needed components for
#				desktop icons on Pantheon.
#

set -o errexit      # exits if non-true exit status is returned
set -o nounset      # exits if unset vars are present

PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/sbin

cur_user="$(who | grep ":0" | cut -f 1 -d ' ' | uniq)"

# needed for this external script to call the current display
DISPLAY=:0
export DISPLAY
XAUTHORITY=/home/"${cur_user}"/.Xauthority
export XAUTHORITY

# install needed packages
if [[ ! -x dconf-tools ]] ; then apt update && apt install -y --no-install-recommends nautilus dconf-tools pantheon-files
fi

# create all needed directories
if [[ ! -d /home/"${cur_user}"/Desktop ]] ; then
	sudo -u "${cur_user}" -l mkdir /home/"${cur_user}"/Desktop
fi

if [[ ! -d /home/"${cur_user}"/.local/share/applications ]] ; then
	sudo -u "${cur_user}" -l mkdir /home/"${cur_user}"/.local/share/applications
fi

if [[ ! -d /home/"${cur_user}"/.config/autostart ]] ; then
	sudo -u "${cur_user}" -l mkdir /home/"${cur_user}"/.config/autostart
fi

# set default desktop icons
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop home-icon-visible true 
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop trash-icon-visible true 
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop volumes-visible true 

# set pantheon to monitor nautilus
dbus-launch --sh-syntax gsettings set org.pantheon.desktop.cerbere monitored-processes "['wingpanel', 'plank', 'slingshot-launcher --silent', 'nautilus -n']" 

# define the desktop directory in with xdg
su - "${cur_user}" -c "echo "XDG_DESKTOP_DIR=\"/home/"${cur_user}"/Desktop\"" >> \
/home/"${cur_user}"/.config/user-dirs.dirs"

# ensure that pantheon remains the default file manager, and use the yes
# binary to handle the interactive prompt
yes | sudo -u "${cur_user}" -l xdg-mime default pantheon.desktop inode/directory application/x-gnome-saved-search

# hide nautilus from the start menu
cp /usr/share/applications/nautilus.desktop /home/"${cur_user}"/.local/share/applications
chown "${cur_user}":"${cur_user}" /home/"${cur_user}"/.local/share/applications/nautilus.desktop
cd /home/${cur_user}/.local/share/applications/ ; sed -i '/\[Desktop Entry\]/a NoDisplay=true' ./nautilus.desktop 

# set nautilus to run after boot for the main user
echo "[Desktop Entry]
Name=litebook-desktop-icons
GenericName=Litebook desktop icons starter
Comment=Enables desktop icons for Pantheon on the Litebook v1
Exec=/etc/litebook-scripts/scripts/litebook-desktop-icons-start.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true" > /home/"${cur_user}"/.config/autostart/litebook-desktop-icons.desktop
chown "${cur_user}":"${cur_user}" /home/"${cur_user}"/.config/autostart/litebook-desktop-icons.desktop

# notify the user of all pertinent info
echo 'Hello!

Desktop icons are now enabled for Pantheon by using Nautilus as a backend.  This
info is also saved as /etc/litebook-scripts/info/litebook-desktop-icons.info.

*** STARTING AND RESTARTING ***
The process that enables desktop icons is nautilus -n --force-desktop &.  If you 
see this process in ps, top, htop, etc, please leave it running or desktop icons 
will break.

If the nautilus -n --force-desktop & process ends unexpectedly, simply execute the 
script litebook-desktop-icons-start.sh in /etc/litebook-scripts/scripts.  This script 
is also automatically set to execute on boot.

*** DEFAULT DESKTOP ICONS ***
To change the default desktop icons used (home, trash, etc), you need to use 
dconf Editor and navigate to org > gnome > nautilus > desktop, you can also use 
gsettings if you prefer the cli. 

*** DESKTOP FONT COLOR ***
Font color is handled by creating the file gtk.css in ~/.config/gtk-3.0.  Add the
following css to this file (only change the color hex code):

	.nautilus-desktop.nautilus-canvas-item {color: <your color hex code> ;text-shadow: 1 1 alpha (@fg_color, 0.8);}

After the change, execute the script litebook-desktop-icons-start.sh in 
/etc/litebook-scripts/scripts, and your new font color will take effect (Sorry for 
the hassle.  I also wish it was easier).  

*** NAUTILUS APP MENU ENTRY ***
This service sets Nautilus to be hidden from your applications menu.  If you want 
it to be visible, edit the nautilus.desktop file in ~/.local/share/applications 
to say NoDisplay=false instead of NoDisplay=true.  Programs such as menulibre 
make this very easy, if you want to use a dedicated menu editor.

Enjoy!

Litebook Support' > /home/"${cur_user}"/Desktop/litebook-desktop-icons.info
chown "${cur_user}":"${cur_user}" /home/"${cur_user}"/Desktop/litebook-desktop-icons.info

# nautilus initial start
gksu -u "${cur_user}" -l /etc/litebook-scripts/scripts/litebook-desktop-icons-start.sh

exit 0

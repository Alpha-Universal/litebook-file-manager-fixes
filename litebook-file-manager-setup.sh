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

# needed for this external script to call the current display
DISPLAY=:0
export DISPLAY
XAUTHORITY=/home/$(id -nu 1000)/.Xauthority
export XAUTHORITY

main_user="$(id -nu 1000)"

# install needed packages
apt update && apt install -y --no-install-recommends nautilus dconf-tools pantheon-files

# set default desktop icons
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop home-icon-visible true 
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop trash-icon-visible true 
dbus-launch --sh-syntax gsettings set org.gnome.nautilus.desktop volumes-visible true 

# set pantheon to monitor nautilus
dbus-launch --sh-syntax gsettings set org.pantheon.desktop.cerbere monitored-processes "['wingpanel', 'plank', 'slingshot-launcher --silent', 'nautilus -n']" 

# create desktop directory in ~ and set it as such with xdg
sudo -u "${main_user}" -l mkdir /home/"${main_user}"/Desktop
su - "${main_user}" -c "echo "XDG_DESKTOP_DIR=\"/home/"${main_user}"/Desktop\"" >> \
/home/"${main_user}"/.config/user-dirs.dirs"

# ensure that pantheon remains the default file manager, and use the yes
# binary to handle the interactive prompt
yes | sudo -u "${main_user}" -l xdg-mime default pantheon.desktop inode/directory application/x-gnome-saved-search

# hide nautilus from the start menu
cp /usr/share/applications/nautilus.desktop /home/"${main_user}"/.local/share/applications
chown "${main_user}":"${main_user}" /home/"${main_user}"/.local/share/applications/nautilus.desktop
cd /home/$(id -nu 1000)/.local/share/applications/ ; sed -i '/\[Desktop Entry\]/a NoDisplay=true' ./nautilus.desktop 

# set nautilus to run after boot for the main user
echo "[Desktop Entry]
Name=litebook-desktop-icons
GenericName=Litebook desktop icons starter
Comment=Enables desktop icons for Pantheon on the Litebook v1
Exec=/etc/litebook-scripts/scripts/litebook-desktop-icons-start.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true" > /home/"${main_user}"/.config/autostart/litebook-desktop-icons.desktop
chown "${main_user}":"${main_user}" /home/"${main_user}"/.config/autostart/litebook-desktop-icons.desktop

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

Litebook Support' > /home/"${main_user}"/Desktop/litebook-desktop-icons.info
chown "${main_user}":"${main_user}" /home/"${main_user}"/Desktop/litebook-desktop-icons.info

# nautilus initial start
gksu -u "$(id -nu 1000)" -l /etc/litebook-scripts/scripts/litebook-desktop-icons-start.sh

exit 0

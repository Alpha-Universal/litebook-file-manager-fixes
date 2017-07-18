#!/bin/bash -
#
#   Name    :   litebook-file-manager-fixes.sh
#   Author  :   Richard Buchanan II for Alpha Universal, LLC
#   Brief   :   A script that enables desktop icons for Pantheon
#				at system start.
#

set -o errexit      # exits if non-true exit status is returned
set -o nounset      # exits if unset vars are present

PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/sbin

cur_user="$(who | grep ":0" | cut -f 1 -d ' ' | uniq)"

# exits if this script has already set things up
if [[ -f /home/"${cur_user}"/.config/autostart/litebook-desktop-icons.desktop ]] ; then
	exit 0
else 
	bash /etc/litebook-scripts/scripts/litebook-file-manager-setup.sh 
fi

exit 0

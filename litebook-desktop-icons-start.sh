#!/bin/bash -
#
#   Name    :   litebook-desktop-icons-start.sh
#   Author  :   Richard Buchanan II for Alpha Universal, LLC
#   Brief   :   A script that starts nautilus at login to
#				enable desktop icons for Pantheon.
#

set -o errexit      # exits if non-true exit status is returned
set -o nounset      # exits if unset vars are present

PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:/usr/local/sbin

nautilus -n --force-desktop &

exit 0

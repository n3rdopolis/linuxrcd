#! /bin/bash
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/Grub2_environmentblockfix_launcher.sh  > /dev/null 2>&1

								   


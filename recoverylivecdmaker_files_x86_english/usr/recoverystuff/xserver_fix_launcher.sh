#! /bin/bash
#This file is part of LinuxRCD.
#
#    LinuxRCD is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    LinuxRCD is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with LinuxRCD.  If not, see <http://www.gnu.org/licenses/>.
#
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
#mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
#mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
#mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
cd /

kdialog --yesno "this will open up a terminal window and try help you reconfigure your xserver. Do you want to continue?

Depending on your system config, you may get a terminal screen prompting you for info, or a terminal window that dissapears. 

This is because many distros have begun phasing out the x config file for autodetection of hardware. This tool will only work on Debian like systems."
fixxserver=$?


if [[ $fixxserver -eq 0 ]]
then
#open up the x server reconfigure
lxterminal -e "dpkg-reconfigure xserver-xorg" &
fi
 
 
#wait 5
sleep 2
#unmount the /usr folder, revealing the contents of the users /usr again
_recovery_umount_ -lf /lib
umount -lf /lib32
umount -lf /lib64
umount -lf /usr
umount -lf /bin/_recovery_mount_
umount -lf /bin/_recovery_umount_

#unmount the ldconfigs so that they are seen as they should
#umount -lf /etc/ld.so.cache
#umount -lf /etc/ld.so.conf
#umount -lf /etc/ld.so.conf.d


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
#This file was last modified 08/04/002010 (Gregorian Calendar) 01:43 UTC
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries
#mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
emelfm2 -i  --one=/ --two=/FileSystems -r echo & 
#wait 5 seconds for the app to load the libraries. This may need to change
sleep 5

#unmount the /usr folder, revealing the contents of the users /usr again
_recovery_umount_ -lf /lib
umount -lf /lib32
umount -lf /lib64
umount -lf /usr
umount -lf /bin/_recovery_mount_
umount -lf /bin/_recovery_umount_


#unmount the ldconfigs so that they are seen as they should
umount -lf /etc/ld.so.cache
umount -lf /etc/ld.so.conf
umount -lf /etc/ld.so.conf.d


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

kdialog --yesno "This will attempt to remove the Grub environment block.

You would want to try to remove this file if you get the error 'Invalad environment block' when you try to boot your system, or sometimes if you get the error 'out of disk'

If the environment block is removed, and your system still fails to boot, then you might either have a full disk or file system error, disk hardware problem, or an older BIOS with a 137GB limit, and Grub is trying to write past 137GB on the drive. If this is the case then you will have to create a small partition at the beginning of your drive. Either that, or you already tried to remove the environment block, and was successful.

Do you want to try to delete the environment block?"
fixgrub=$?


if [[ $fixgrub -eq 0 ]]
then
#open up the x server reconfigure

if [ -f  /boot/grub/grubenv ]
then
mv  /boot/grub/grubenv /boot/grub/grubenv$(date +%s).bak

if [ -f  /boot/grub/grubenv ]
then
kdialog --error "Attempted to delete the environment block, but the file still exists. Try running a disk check"
else
kdialog --msgbox "Grub Environment block was removed"
fi

else
kdialog --msgbox "Grub Environment block does not seem to exist"
fi



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


#! /usr/bin/sudo /bin/bash
#    Copyright (c) 2009 2010, nerdopolis <bluescreen_avenger@version.net>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#set -o verbose                                                                                       
#this script must be run as root.
if [[ $UID -ne 0 ]]
then               
  echo "This package creation script must be run as root."
  exit 1                       
fi

CPU_ARCHITECTURE=i386  
Language_Name=en_us

ThIsScriPtSFiLeLoCaTion=$(readlink -f "$0")
ThIsScriPtSFolDerLoCaTion=$(dirname "$ThIsScriPtSFiLeLoCaTion")
#set terminal color to default to keep consistancy
echo -en \\033[00m\\033[8] > $(tty)
#####Tell User what script does
echo "

This message repeated mentions 'chroot'. chroot is a program that allows you to run programs in a mounted Unix like system, as if though that mounted system was root. Chroot is NOT a VM, it just sets programs to think that a given folder is the / folder. Chrooting /media/filesystem opens up bash at /media/filesystem/bin/bash. The bash process though thinks it was launched at /bin/bash. /media/filesystem/usr/share/bin is treated by the bash process as /usr/share/bin, ect.

This script creates packages for LinuxRCD that are recompiled not to use /usr/share as union mounting /usr/share can confuse package managers. 

Be aware that all output in red, is NOT affecting your real system!!!!!!

This script will format an image file that it creates, not your hard drive, which is why as its running, you may see output from mkfs. You might notice it installing some stuff as well, but other then pv and debootstrap, nothing is installed on your real system. This script currently runs unattended once you hit enter twice, meaning once you hit enter twice, the script will go about building the image, without the need for your interaction.

Please note that this script tries not overwrite any files, although the proberbility of it taking over one of your folders is VERY SLIM, meaning there IS A CHANCE, as it uses case sensitive file and folder names you are very unlikey to have on your system, but that doesn't mean that you don't have any file named like these. Just to be sure we'll go over the list of files it touches. Its always a good idea to backup your system reguaurly, as something flukey may happen with this script, or the programs it calls.

It will overwrite or erase (if you have one of these following files and folder, either back them up or do not run this script)

NOTE THAT FOLDERS IN THE MEDIA FOLDER ARE USUALY MOUNTPOINTS FOR OTHER VOLUMES!

NOTE THAT THE FOLDERS LISTED BELOW ARE DELETED OR OVERWRITTEN ALONG WITH THE CONTENTS (file names are case sensitive)

!! VOLUME MOUNTPOINT: /media/PackAgeCreAtionChrootFolDer/   !!!!          
   Folder:            ${HOME}/PackAgeCreAtionCacheFolDer/
   File:              ${HOME}/PackAgeCreAtionWasPVNotInStalled
   File:              ${HOME}/PackAgeCreAtionWasDeBootStrapNotInStalled
   File:              ${HOME}/LinuxRCDPackAgeS
   
NOTE THAT SOME GUI FILE BROWSERS MAY CALL THE FOLDER  ${HOME}/ just plain old 'home' so be careful 

As you can tell its unlikley you have any files named like this, but just check to be sure, because if they exist they will be erased.

Creates Lucid packages for LinuxRCD that are recompiled to not use /usr/share"





echo "PLEASE READ ALL TEXT ABOVE. YOU CAN SCROLL BY USING SHIFT-PGUP or SHIFT-PGDOWN (OR THE SCROLL WHEEL OR SCROLL BAR IF AVALIBLE) AND THEN PRESS ENTER TO CONTINUE..."

read a

echo "press enter again to start the operation. If you started the script in an xterm or equivilent, and you already hit enter once, and you dont want to continue, DO NOT close out the window, if you do it may start to run in the background. If yo wish to close it, press control-c FIRST."

read a

####CLEAN UP IF THIS BASH SCRIPT WAS INTURUPTED
#enter users home directory
cd ~

#unmount the chrooted procfs from the outside 
umount -lf /media/PackAgeCreAtionChrootFolDer/proc

#unmount the chrooted sysfs from the outside
umount -lf /media/PackAgeCreAtionChrootFolDer/sys

#unmount the chrooted sysfs from the outside
umount -lf /media/PackAgeCreAtionChrootFolDer/dev/pts

#unmount the chrooted devfs from the outside 
umount -lf /media/PackAgeCreAtionChrootFolDer/dev

#kill any process accessing the PackAge mountpoint 
fuser /media/PackAgeCreAtionChrootFolDer/ -k

#unmount the chroot fs
umount -lf /media/PackAgeCreAtionChrootFolDer

#delete the mountpoint
rm -rf /media/PackAgeCreAtionChrootFolDer

#remove the PackAgeCreAtionCacheFolDer folder 
rm -rf ~/PackAgeCreAtionCacheFolDer

#was debootstrap installed before the script was first run? if not uninstall it to keep everything clean.
WasDeBootStrapNotInstalledBefore=$(cat PackAgeCreAtionWasDeBootStrapNotInStalled)
if (( 1==WasDeBootStrapNotInstalledBefore ));
then
apt-get purge debootstrap -y
fi

#was pv installed before the script was first run? if not uninstall it to keep everything clean.
WasPVNotInstalledBefore=$(cat PackAgeCreAtionWasPVNotInStalled)
if (( 1==WasPVNotInstalledBefore ));
then
apt-get purge pv -y
fi
#END PAST RUN CLEANUP##################

#ping google to test total network connectivity. Google is usally pingable
ping -c1 google.com > /dev/null
IsGoOgLeAcceSsaBle=$?
if [[ $IsGoOgLeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access Google. There is a high proberbility that your connection to the Internet is disconnected. (or in an extreemly rare case Google may be down) 
"
                     
fi

#detect if the Ubuntu Archive Site is reachable
ping -c1 archive.ubuntu.com > /dev/null
IsUbuNtUArcHiveSiTeAcceSsaBle=$?
if [[ $IsUbuNtUArcHiveSiTeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access the Ubuntu Archive site. Please test your connectivity to the Internet If you belive you are connected, the Ubuntu Archive Site may be down. The script needs Ubuntu's Archive website in order to succede. Exiting."
  exit 1                       
fi



#get the size of the users home file system. 
HomeFileSysTemFSFrEESpaCe=$(df ~ | awk '{print $4}' |  grep -v Av)
#if there is 3gb or less tell the user and quit. If not continue.
if [[ $HomeFileSysTemFSFrEESpaCe -le 3000000 ]]; then               
  echo "You have less then 3gb of free space on the partition that contains your home folder. Please free up some space." 
  echo "The script will now abort."
  echo "free space:"
  df ~ -h | awk '{print $4}' |  grep -v Av
  exit 1                       
fi


#detect if debootstrap is installed
DebootstrapStatus=$(dpkg-query -s debootstrap | grep "install ok installed" -c)

#detect if pv is installed
PVStatus=$(dpkg-query -s pv | grep "install ok installed" -c)

#Cache DeBootstraps Status to a file in case if this batch file gets intrupted
if (( 0==DebootstrapStatus ));
then
echo 1 > ~/PackAgeCreAtionWasDeBootStrapNotInStalled
fi

#Cache pv Status to a file in case if this batch file gets intrupted
if (( 0==PVStatus ));
then
echo 1 > ~/PackAgeCreAtionWasPVNotInStalled
fi

#install bootstrap if not installed
if (( 0==DebootstrapStatus ));
then
apt-get install debootstrap
fi

#installpv if not installed
if (( 0==PVStatus ));
then
apt-get install pv
fi

#make a folder containing the live cd tools in the users local folder
mkdir ~/PackAgeCreAtionCacheFolDer

#switch to that folder
cd ~/PackAgeCreAtionCacheFolDer


echo "creating virtual hard disk image. This could take some time. The target size of the file is 2 GB"
#make the super large image at 2gb and show the progress
dd if=/dev/zero bs=1048576  count=2048 | pv | dd of=livecdfs 


#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
echo "creating a file system on the virtual image. Not on your real file system."
#create a file system on the image 
yes y | mkfs.ext3 ./livecdfs
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#create a media mountpoint in the media folder
mkdir /media/PackAgeCreAtionChrootFolDer

#mount the image created above at the mountpoint as a loop deivce
mount ./livecdfs /media/PackAgeCreAtionChrootFolDer -o loop


#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#install a really basic Ubuntu installation in the new fs  
debootstrap --arch $CPU_ARCHITECTURE lucid /media/PackAgeCreAtionChrootFolDer http://archive.ubuntu.com/ubuntu/
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#mounting devfs on chrooted fs with bind 
mount --bind /dev /media/PackAgeCreAtionChrootFolDer/dev/





#######################################################END RECOVERY CALLER SCRIPT########################################


#copy in the files needed
rsync "$ThIsScriPtSFolDerLoCaTion"/linuxrcd_package_files/* -Cr /media/PackAgeCreAtionChrootFolDer/temp/
rsync "$ThIsScriPtSFolDerLoCaTion"/*                           -Cr /media/PackAgeCreAtionChrootFolDer/build_source


#make the chroot script executable.
#chmod +x /media/PackAgeCreAtionChrootFolDer/temp/chrootscript.sh
#make the imported files executable 
chmod +x -R /media/PackAgeCreAtionChrootFolDer/temp/
chown  root  -R /media/PackAgeCreAtionChrootFolDer/temp/
chgrp  root  -R /media/PackAgeCreAtionChrootFolDer/temp/


#copy the new  executable files to where they belong
rsync /media/PackAgeCreAtionChrootFolDer/temp/* -a /media/PackAgeCreAtionChrootFolDer/
#delete the temp folder
rm -rf /media/PackAgeCreAtionChrootFolDer/temp/





#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#run the chroot script########################################
chroot /media/PackAgeCreAtionChrootFolDer /chrootscript.sh
##############################################################
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#TEMPORARY PAUSE TODO
read a

#go back to the users home folder
cd ~

#unmount the chrooted procfs from the outside 
umount -lf /media/PackAgeCreAtionChrootFolDer/proc

#unmount the chrooted sysfs from the outside
umount -lf /media/PackAgeCreAtionChrootFolDer/sys

#unmount the chrooted dev/pts from the outside 
umount -lf /media/PackAgeCreAtionChrootFolDer/dev/pts

#unmount the chrooted dev/shm from the outside
umount -lf /media/PackAgeCreAtionChrootFolDer/dev/shm

#unmount the chrooted devfs from the outside 
umount -lf /media/PackAgeCreAtionChrootFolDer/dev

#kill any process accessing the PackAge mountpoint TODO MAKE IT KILL THE PROCESSES NOT LIST THEM or not... 
fuser /media/PackAgeCreAtionChrootFolDer/ 

#unmount the chroot fs
umount -lf /media/PackAgeCreAtionChrootFolDer

#delete the mountpoint
rm -rf /media/PackAgeCreAtionChrootFolDer

#remove the PackAgeCreAtionCacheFolDer folder 
rm -rf ~/PackAgeCreAtionCacheFolDer



#uninstall debootstrap if it was uninstalled before
if (( 0==DebootstrapStatus ));
then
apt-get purge debootstrap -y
fi
rm ~/PackAgeCreAtionWasDeBootStrapNotInStalled

#uninstall pv if it was uninstalled before
if (( 0==PVStatus ));
then
apt-get purge pv -y
fi
rm ~/PackAgeCreAtionWasPVNotInStalled


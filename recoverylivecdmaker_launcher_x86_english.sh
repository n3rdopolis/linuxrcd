#! /usr/bin/sudo /bin/bash
#arch=x86
#language=english

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

                                                                                        
#this script must be run as root.
if [[ $UID -ne 0 ]]
then               
  echo "This Live CD creation script must be run as root."
  exit 1                       
fi

ThIsScriPtSFiLeLoCaTion=$(readlink -f $0)
ThIsScriPtSFolDerLoCaTion=$(dirname "$ThIsScriPtSFiLeLoCaTion")
#set terminal color to default to keep consistancy
echo -en \\033[00m\\033[8] > $(tty)
#####Tell User what script does
echo "

































This message repeated mentions 'chroot'. chroot is a program that allows you to run programs in a mounted Unix like system, as if though that mounted system was root. Chroot is NOT a VM, it just sets programs to think that a given folder is the / folder. Chrooting /media/filesystem opens up bash at /media/filesystem/bin/bash. The bash process though thinks it was launched at /bin/bash. /media/filesystem/usr/share/bin is treated by the bash process as /usr/share/bin, ect.

This script creates a live disk using remastersys. It creates a chroot environment and gives you the ability to edit this script to configure the live system. Once the chroot system is configured, it calls remastersys to create a 'backup' of the chrooted system into a live cd ISO and then the script moves the live cd out of the chrooted system, and into your home folder. Besides the iso left on your system, it restores your system back to the way it was, it will detect if you have debootstrap, and pv installed, as this scipt needs debootstrap to build the basic system,  and pv to display the progress of the image creation,  but if it needs to install them, it will uninstall debootstrap and pv when it finished. This script will at most use around 3gb of disk space on your home partion including cache, and end up using at most around 1gb. Please make sure you have enough space as when Linux systems run out of disk space can behave quirky. This script also needs internet connectivity to succede as well. Also if you are using a laptop, plug it in, as this script takes alot of battery power. This script will at points use the CPU, or hard disk heavily at points and may bog down your system.

Be aware that all output in red, is NOT affecting your real system!!!!!!

This script will format an image file that it creates, not your hard drive, which is why as its running, you may see output from mkfs. You might notice it installing some stuff as well, but other then pv and debootstrap, nothing is installed on your real system. This script currently runs unattended once you hit enter twice, meaning once you hit enter twice, the script will go about building the image, without the need for your interaction.

Please note that this script tries not overwrite any files, although the proberbility of it taking over one of your folders is VERY SLIM, meaning there IS A CHANCE, as it uses case sensitive file and folder names you are very unlikey to have on your system, but that doesn't mean that you don't have any file named like these. Just to be sure we'll go over the list of files it touches. Its always a good idea to backup your system reguaurly, as something flukey may happen with this script, or the programs it calls.

It will overwrite or erase (if you have one of these following files and folder, either back them up or do not run this script)

NOTE THAT FOLDERS IN THE MEDIA FOLDER ARE USUALY MOUNTPOINTS FOR OTHER VOLUMES!

NOTE THAT THE FOLDERS LISTED BELOW ARE DELETED OR OVERWRITTEN ALONG WITH THE CONTENTS (file names are case sensitive)

!! VOLUME MOUNTPOINT: /media/LiveDiskCreAtionChrootFolDer/   !!!!          
   Folder:            ${HOME}/LiveDiskCreAtionCacheFolDer/
   File:              ${HOME}/LiveDiskCreAtionWasPVNotInStalled
   File:              ${HOME}/LiveDiskCreAtionWasDeBootStrapNotInStalled
   File:              ${HOME}/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso
   
NOTE THAT SOME GUI FILE BROWSERS MAY CALL THE FOLDER  ${HOME}/ just plain old 'home' so be careful 

As you can tell its unlikley you have any files named like this, but just check to be sure, because if they exist they will be erased.

Creates a recovery oriented live CD based on ubuntu lucid (10.04) packages for x86

last edit: 08/04/2010 AD (Gregorian Calander) 00:17 UTC" 



echo "PLEASE READ ALL TEXT ABOVE. YOU CAN SCROLL BY USING SHIFT-PGUP or SHIFT-PGDOWN (OR THE SCROLL WHEEL OR SCROLL BAR IF AVALIBLE) AND THEN PRESS ENTER TO CONTINUE..."

read a

echo "press enter again to start the operation. If you started the script in an xterm or equivilent, and you already hit enter once, and you dont want to continue, DO NOT close out the window, if you do it may start to run in the background. If yo wish to close it, press control-c FIRST."

read a

####CLEAN UP IF THIS BASH SCRIPT WAS INTURUPTED
#enter users home directory
cd ~

#unmount the chrooted procfs from the outside 
umount -lf /media/LiveDiskCreAtionChrootFolDer/proc

#unmount the chrooted sysfs from the outside
umount -lf /media/LiveDiskCreAtionChrootFolDer/sys

#unmount the chrooted sysfs from the outside
umount -lf /media/LiveDiskCreAtionChrootFolDer/dev/pts

#unmount the chrooted devfs from the outside 
umount -lf /media/LiveDiskCreAtionChrootFolDer/dev

#kill any process accessing the livedisk mountpoint 
fuser /media/LiveDiskCreAtionChrootFolDer/ -k

#unmount the chroot fs
umount -lf /media/LiveDiskCreAtionChrootFolDer

#delete the mountpoint
rm -rf /media/LiveDiskCreAtionChrootFolDer

#remove the LiveDiskCreAtionCacheFolDer folder 
rm -rf ~/LiveDiskCreAtionCacheFolDer

#was debootstrap installed before the script was first run? if not uninstall it to keep everything clean.
WasDeBootStrapNotInstalledBefore=$(cat LiveDiskCreAtionWasDeBootStrapNotInStalled)
if (( 1==WasDeBootStrapNotInstalledBefore ));
then
apt-get purge debootstrap -y
fi

#was pv installed before the script was first run? if not uninstall it to keep everything clean.
WasPVNotInstalledBefore=$(cat LiveDiskCreAtionWasPVNotInStalled)
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

#detect if the Remastersys Archive site is reachable
ping -c1 www.remastersys.com > /dev/null
IsReMastersYsArcHiveSiTeAcceSsaBle=$?
if [[ $IsReMastersYsArcHiveSiTeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access the Remastersys Archive site. Please test your connectivity to the Internet If you belive you are connected, the Remastersys Archive Site may be down. The script needs Remastersys' Archive Site in order to succede. Exiting." 
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
echo 1 > ~/LiveDiskCreAtionWasDeBootStrapNotInStalled
fi

#Cache pv Status to a file in case if this batch file gets intrupted
if (( 0==PVStatus ));
then
echo 1 > ~/LiveDiskCreAtionWasPVNotInStalled
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
mkdir ~/LiveDiskCreAtionCacheFolDer

#switch to that folder
cd ~/LiveDiskCreAtionCacheFolDer


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
mkdir /media/LiveDiskCreAtionChrootFolDer

#mount the image created above at the mountpoint as a loop deivce
mount ./livecdfs /media/LiveDiskCreAtionChrootFolDer -o loop


#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#install a really basic Ubuntu installation in the new fs
debootstrap --arch i386 lucid /media/LiveDiskCreAtionChrootFolDer http://archive.ubuntu.com/ubuntu/
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#mounting devfs on chrooted fs with bind TODO do it without bind, a cleaner sort of fashon
mount --bind /dev /media/LiveDiskCreAtionChrootFolDer/dev/



#configure remastersys PLACEHOLDER! File is now being copied in
#remastersys.conf

#CREATE THE RECOVERY CALLER SCRIPT PLACEHOLDER! File is now being copied in
#recoverylauncher


#create the script that the recovery script will call in recovery chroot PLACEHOLDER! File is now being copied in
#recoverychrootscript

#create the clipboard manager for migration between both displays PLACEHOLDER! File is now being copied in
#clipboardmgr

#######################################################END RECOVERY CALLER SCRIPT########################################


#copy in the files needed
rsync "$ThIsScriPtSFolDerLoCaTion"/recoverylivecdmaker_files_x86_english/* -Cr /media/LiveDiskCreAtionChrootFolDer
rsync "$ThIsScriPtSFolDerLoCaTion"/*                                       -Cr /media/LiveDiskCreAtionChrootFolDer/build_source

#create the script that runs in chroot under the new fs to configure it, and build its live cd PLACEHOLDER! File is now being copied in

#make the script executable
chmod +x /media/LiveDiskCreAtionChrootFolDer/chrootscript.sh 

#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#run the chroot script########################################
chroot /media/LiveDiskCreAtionChrootFolDer /chrootscript.sh
##############################################################
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#delete the old copy of the ISO
rm ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso
#move the iso out of the chroot fs
cp /media/LiveDiskCreAtionChrootFolDer/home/remastersys/remastersys/custombackup.iso ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso

#allow the user to actually read the iso
chown $LOGNAME ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso
chgrp $LOGNAME ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso
chmod 777 ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso


#go back to the users home folder
cd ~

#unmount the chrooted procfs from the outside 
umount -lf /media/LiveDiskCreAtionChrootFolDer/proc

#unmount the chrooted sysfs from the outside
umount -lf /media/LiveDiskCreAtionChrootFolDer/sys

#unmount the chrooted dev/pts from the outside 
umount -lf /media/LiveDiskCreAtionChrootFolDer/dev/pts

#unmount the chrooted dev/shm from the outside
umount -lf /media/LiveDiskCreAtionChrootFolDer/dev/shm

#unmount the chrooted devfs from the outside 
umount -lf /media/LiveDiskCreAtionChrootFolDer/dev

#kill any process accessing the livedisk mountpoint TODO MAKE IT KILL THE PROCESSES NOT LIST THEM or not... 
fuser /media/LiveDiskCreAtionChrootFolDer/ 

#unmount the chroot fs
umount -lf /media/LiveDiskCreAtionChrootFolDer

#delete the mountpoint
rm -rf /media/LiveDiskCreAtionChrootFolDer

#remove the LiveDiskCreAtionCacheFolDer folder 
rm -rf ~/LiveDiskCreAtionCacheFolDer



#uninstall debootstrap if it was uninstalled before
if (( 0==DebootstrapStatus ));
then
apt-get purge debootstrap -y
fi
rm ~/LiveDiskCreAtionWasDeBootStrapNotInStalled

#uninstall pv if it was uninstalled before
if (( 0==PVStatus ));
then
apt-get purge pv -y
fi
rm ~/LiveDiskCreAtionWasPVNotInStalled

#If the live cd did not build then tell user
if [ ! -f ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso ];
then  
echo "The Live CD did not succesfuly build. if you did not edit this script please make sure you are conneced to 'the Internet', and be able to reach the Ubuntu archives, and Remastersys's archives and try agian. if you did edit it, check your syntax"
exit 1
fi 

#If the live cd did  build then tell user
if [  -f ~/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso ];
then  
echo "Live CD image build was successful. It was created at ${HOME}/LiveDiskCreAtedFromLiveDiskCreAtionScript_English_x86.iso"
exit 1
fi
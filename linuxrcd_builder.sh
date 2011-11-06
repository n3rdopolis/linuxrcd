#! /usr/bin/sudo /bin/bash
#    Copyright (c) 2009, 2010, 2011, nerdopolis (or n3rdopolis) <bluescreen_avenger@version.net>
#
#    This file is part of LinuxRCD.
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
#set terminal color to default to keep consistancy
echo -en \\033[00m\\033[8] > $(tty)
CPU_ARCHITECTURE=DEFAULT      


                                                                      
#this script must be run as root.
if [[ $UID -ne 0 ]]
then               
  echo "This Live CD creation script must be run as root."
  exit 1                       
fi

echo "Enter CPU Arch to build this CD under (i386/amd64)"
read CPU_ARCHITECTURE


if [ "$CPU_ARCHITECTURE" != "i386" -a "$CPU_ARCHITECTURE" != "amd64" ]
then
echo "unknown architecture defaulting to i386"
CPU_ARCHITECTURE=i386  
fi




ThIsScriPtSFiLeLoCaTion=$(readlink -f "$0")
ThIsScriPtSFolDerLoCaTion=$(dirname "$ThIsScriPtSFiLeLoCaTion")

#####Tell User what script does
echo "

This message repeated mentions 'chroot'. chroot is a program that allows you to run programs in a mounted Unix like system, as if though that mounted system was root. Chroot is NOT a VM, it just sets programs to think that a given folder is the / folder. Chrooting /media/filesystem opens up bash at /media/filesystem/bin/bash. The bash process though thinks it was launched at /bin/bash. /media/filesystem/usr/share/bin is treated by the bash process as /usr/share/bin, ect.

This script creates a live disk using remastersys. It creates a chroot environment and gives you the ability to edit this script to configure the live system. Once the chroot system is configured, it calls remastersys to create a 'backup' of the chrooted system into a live cd ISO and then the script moves the live cd out of the chrooted system, and into your home folder. Besides the iso left on your system, it restores your system back to the way it was, it will detect if you have debootstrap as this scipt needs debootstrap to build the basic system,  but if it needs to install them, it will uninstall debootstrap when it finished. This script will at most use around 3gb of disk space on your home partion including cache, and end up using at most around 1gb. Please make sure you have enough space as when Linux systems run out of disk space can behave quirky. This script also needs internet connectivity to succede as well. Also if you are using a laptop, plug it in, as this script takes alot of battery power. This script will at points use the CPU, or hard disk heavily at points and may bog down your system.

Be aware that all output in red, is NOT affecting your real system!!!!!!


Please note that this script tries not overwrite any files, although the proberbility of it taking over one of your folders is VERY SLIM, meaning there IS A CHANCE, as it uses case sensitive file and folder names you are very unlikey to have on your system, but that doesn't mean that you don't have any file named like these. Just to be sure we'll go over the list of files it touches. Its always a good idea to backup your system reguaurly, as something flukey may happen with this script, or the programs it calls.

It will overwrite or erase (if you have one of these following files and folder, either back them up or do not run this script)

NOTE THAT FOLDERS IN THE MEDIA FOLDER ARE USUALY MOUNTPOINTS FOR OTHER VOLUMES!

NOTE THAT THE FOLDERS LISTED BELOW ARE DELETED OR OVERWRITTEN ALONG WITH THE CONTENTS (file names are case sensitive)

!! VOLUME MOUNTPOINT: /media/LiveDiskCreAtionChrootFolDer/   !!!!          
   Folder:            ${HOME}/LiveDiskCreAtionCacheFolDer/
   File:              ${HOME}/LiveDiskCreAtionWasDeBootStrapNotInStalled
   File:              ${HOME}/LinuxRCD_${CPU_ARCHITECTURE}.iso
   
NOTE THAT SOME GUI FILE BROWSERS MAY CALL THE FOLDER  ${HOME}/ just plain old 'home' so be careful 

As you can tell its unlikley you have any files named like this, but just check to be sure, because if they exist they will be erased.

Creates a recovery oriented live CD based on ubuntu natty (11.04)"





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
#if there is 4gb or less tell the user and quit. If not continue.
if [[ $HomeFileSysTemFSFrEESpaCe -le 4000000 ]]; then               
  echo "You have less then 4gb of free space on the partition that contains your home folder. Please free up some space." 
  echo "The script will now abort."
  echo "free space:"
  df ~ -h | awk '{print $4}' |  grep -v Av
  exit 1                       
fi


#detect if debootstrap is installed
DebootstrapStatus=$(dpkg-query -s debootstrap | grep "install ok installed" -c)

#Cache DeBootstraps Status to a file in case if this batch file gets intrupted
if (( 0==DebootstrapStatus ));
then
echo 1 > ~/LiveDiskCreAtionWasDeBootStrapNotInStalled
fi

#install bootstrap if not installed
if (( 0==DebootstrapStatus ));
then
apt-get install debootstrap
fi

#make a folder containing the live cd tools in the users local folder
mkdir ~/LiveDiskCreAtionCacheFolDer

#switch to that folder
cd ~/LiveDiskCreAtionCacheFolDer


#create the file that will be the filesystem image
dd if=/dev/zero of=livecdfs bs=1 count=0 seek=4G 


#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
echo "creating a file system on the virtual image. Not on your real file system."
#create a file system on the image 
yes y | mkfs.ext4 ./livecdfs
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#create a media mountpoint in the media folder
mkdir /media/LiveDiskCreAtionChrootFolDer

#mount the image created above at the mountpoint as a loop deivce
mount ./livecdfs /media/LiveDiskCreAtionChrootFolDer -o loop


#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#install a really basic Ubuntu installation in the new fs  
debootstrap --arch $CPU_ARCHITECTURE oneiric /media/LiveDiskCreAtionChrootFolDer http://archive.ubuntu.com/ubuntu/
#change back to default
echo -en \\033[00m\\033[8] > $(tty)


#mounting devfs on chrooted fs with bind 
mount --bind /dev /media/LiveDiskCreAtionChrootFolDer/dev/





#######################################################END RECOVERY CALLER SCRIPT########################################


#copy in the files needed
rsync "$ThIsScriPtSFolDerLoCaTion"/linuxrcd_files/* -Cr /media/LiveDiskCreAtionChrootFolDer/temp/




#make the imported files executable 
chmod +x -R /media/LiveDiskCreAtionChrootFolDer/temp/
chown  root  -R /media/LiveDiskCreAtionChrootFolDer/temp/
chgrp  root  -R /media/LiveDiskCreAtionChrootFolDer/temp/


#copy the new translated executable files to where they belong
rsync /media/LiveDiskCreAtionChrootFolDer/temp/* -a /media/LiveDiskCreAtionChrootFolDer/

#delete the temp folder
rm -rf /media/LiveDiskCreAtionChrootFolDer/temp/





#change text to red to not scare user
echo -en \\033[31m\\033[8] > $(tty)
#Configure the Live system########################################
chroot /media/LiveDiskCreAtionChrootFolDer /tmp/cd_phase_1.sh
##############################################################


#kill any process accessing the livedisk mountpoint 
fuser -k /media/LiveDiskCreAtionChrootFolDer/ 

#make sure the editor is executable
chmod +x "$ThIsScriPtSFolDerLoCaTion"/linuxrcd_edit.sh
#edit some folder path strings
"$ThIsScriPtSFolDerLoCaTion"/linuxrcd_edit.sh usr RCD
"$ThIsScriPtSFolDerLoCaTion"/linuxrcd_edit.sh lib LYB
"$ThIsScriPtSFolDerLoCaTion"/linuxrcd_edit.sh lib64 LYB64
#fix for Xorg, it uses wildcards.
find "/media/LiveDiskCreAtionChrootFolDer/RCD/LYB/xorg" -name "lib*"   | while read FILEPATH
do
echo "Renaming $FILEPATH"
rename "s/lib/\1LYB\2/g" "$FILEPATH"
done


#fix for NetworkManager, it uses wildcards.
find "/media/LiveDiskCreAtionChrootFolDer/RCD/LYB/NetworkManager" -name "lib*"   | while read FILEPATH
do
echo "Renaming $FILEPATH"
rename "s/lib/\1LYB\2/g" "$FILEPATH"
done

#Do this for X
ln -s -f /var/LYB /media/LiveDiskCreAtionChrootFolDer/var/lib

#delete the usr folder in the Live CD
rm -rf /media/LiveDiskCreAtionChrootFolDer/usr

#Do this for OS prober as it works with a normal system with lib. not LYB
sed -i 's/LYB/lib/g' /media/LiveDiskCreAtionChrootFolDer/RCD/LYB/os-probes/mounted/90linux-distro

#Do this for the main library interpreter, so that it does not use the target system's ld.so.cache
sed -i 's@/ld.so.cache@/LD.SO.CACHE@g' /media/LiveDiskCreAtionChrootFolDer/LYB/ld-linux*
mv /media/LiveDiskCreAtionChrootFolDer/etc/ld.so.cache /media/LiveDiskCreAtionChrootFolDer/etc/LD.SO.CACHE

#make the iso using remastersys############################################
chroot /media/LiveDiskCreAtionChrootFolDer /tmp/cd_phase_2.sh
###########################################################################

#change back to default
echo -en \\033[00m\\033[8] > $(tty)

#delete the old copy of the ISO 
rm ~/LinuxRCD_${CPU_ARCHITECTURE}.iso
#move the iso out of the chroot fs    
cp /media/LiveDiskCreAtionChrootFolDer/home/remastersys/remastersys/custombackup.iso ~/LinuxRCD_${CPU_ARCHITECTURE}.iso

#allow the user to actually read the iso   
chown $LOGNAME ~/LinuxRCD_${CPU_ARCHITECTURE}.iso
chgrp $LOGNAME ~/LinuxRCD_${CPU_ARCHITECTURE}.iso
chmod 777 ~/LinuxRCD_${CPU_ARCHITECTURE}.iso


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

#kill any process accessing the livedisk mountpoint 
fuser -k /media/LiveDiskCreAtionChrootFolDer/ 

#unmount the chroot fs
umount -lfd /media/LiveDiskCreAtionChrootFolDer

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




#If the live cd did not build then tell user  
if [ ! -f ~/LinuxRCD_${CPU_ARCHITECTURE}.iso ];
then  
echo "The Live CD did not succesfuly build. if you did not edit this script please make sure you are conneced to 'the Internet', and be able to reach the Ubuntu archives, and Remastersys's archives and try agian. if you did edit it, check your syntax"
exit 1
fi 

#If the live cd did  build then tell user   
if [  -f ~/LinuxRCD_${CPU_ARCHITECTURE}.iso ];
then  
echo "Live CD image build was successful. It was created at ${HOME}/LinuxRCD_${CPU_ARCHITECTURE}.iso"
exit 1
fi

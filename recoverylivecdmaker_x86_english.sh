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

ThIsScriPtSLoCaTion=$(readlink -f $0)

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

last edit: 07/14/2010 AD (Gregorian Calander) 14:45 UTC" 



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

#create the script that runs in chroot under the new fs to configure it, and build its live cd
#NOTICE TO TWEAKERS OF THIS SCRIPT FILE. THIS COMMAND MUST NOT HAVE THE ' CHARACHTER. IF IT DOES, IT THINKS THAT THAT IT IS THE END OF THE ECHO COMMAND, AND THE FOLLOWING TEXT WILL BE EXECUTED IN YOUR MAIN SYSYEM.! IF YOU NEED THE ' SYMBOL IN AN ECHO COMMAND (WITHIN THIS ECHO COMMAND) USE /047 AS IT WILL BECOME A ' CHARACHTER IN THE NEW SCRIPT. 
echo -e '#! /bin/bash

#mount the procfs
mount -t proc none /proc


#mount sysfs
mount -t sysfs none /sys

#TODO Mount the devfs here WITHOUT mount --bind!

#mount /dev/pts
mount -t devpts none /dev/pts

#add remastersys and ubuntu packages to the repository file in the chrooted system
echo " deb http://archive.ubuntu.com/ubuntu/ lucid main restricted
deb http://archive.ubuntu.com/ubuntu/ lucid-updates main restricted
deb http://archive.ubuntu.com/ubuntu/ lucid universe
deb http://archive.ubuntu.com/ubuntu/ lucid-updates universe
deb http://archive.ubuntu.com/ubuntu/ lucid multiverse
deb http://archive.ubuntu.com/ubuntu/ lucid-updates multiverse
deb http://archive.ubuntu.com/ubuntu/ lucid-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu lucid partner
deb-src http://archive.canonical.com/ubuntu lucid partner
deb http://archive.ubuntu.com/ubuntu/ lucid-security main restricted
deb http://archive.ubuntu.com/ubuntu/ lucid-security universe
deb http://archive.ubuntu.com/ubuntu/ lucid-security multiverse
deb http://archive.ubuntu.com/ubuntu/ lucid-proposed restricted main multiverse universe
deb http://www.geekconnection.org/remastersys/repository remastersys/
" >> /etc/apt/sources.list

#update the apt cache
apt-get update


#install wget and binutils
aptitude install binutils wget --without-recommends -y


#install a language pack
aptitude install language-pack-en --without-recommends -y

#install a kernel for the Live disk
aptitude install linux-generic  --without-recommends -y

#install an xserver
aptitude install xserver-xorg  --without-recommends -y

#install remastersys 
yes Yes | aptitude install remastersys  --without-recommends -y

#install xinit 
yes Yes | aptitude install xinit  --without-recommends -y


#install minmimal desktop GUI LXDE and related dependancies, and minimal display manager for some reason it wants xrdb which is in x11-xserver-utils, and screenshot handler and text editor. 
sudo aptitude install lxde-common lxde-core lxde-icon-theme lxde-settings-daemon lxinput lxmenu-data lxpanel lxrandr lxsession-lite lxsession-edit lxterminal x11-xserver-utils xsel gedit emelfm2   kdebase-bin fspanel ksnapshot --without-recommends -y

#install lxdes utilities
yes Yes | aptitude install lxde  --without-recommends -y

#install X11 display nester Xephyr
yes Yes | aptitude install xserver-xephyr  --without-recommends -y

#install gnome network manager tor provide networking and it needs the icon theme 
yes Yes | aptitude install network-manager-gnome hicolor-icon-theme -y

#install web browser 
sudo aptitude install chromium-browser --without-recommends -y

#install recovery utilities
sudo aptitude install  kuser --without-recommends -y


#filter out Remastersys installing Ubiquity by filtering between 2 decisive comments in the file
sed -e \047 /popularity-contest as/,/Step 3 - Create the/ d \047 /usr/bin/remastersys > /remastersys


#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys

#move remastersys configuration file into /etc/
mv /remastersys.conf /etc/remastersys.conf

#edit the remastersys script file so that it updates the initramfs instead of making a new one with uname -r as it doesnt work in chroot
sed -e \047 /# Step 6 - Make filesystem.squashfs/ a update-initramfs -u  \047 /usr/bin/remastersys > /remastersys

#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys

#copy the initramfs to the correct location
sed -e \047 /update-initramfs/ a cp /initrd.img \$WORKDIR/ISOTMP/casper/initrd.gz \047 /usr/bin/remastersys > /remastersys

#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys


#move in the clipboard manager
mv /clipboardmgr /usr/bin

#make it executable
chmod +x /usr/bin/clipboardmgr
#############################################CONFIGURE STARTUP OF LIVE CD################################

#####################BEGIN OLD STYLE INIT SCRIPT EDITS###################

###REMOVE GDM FROM STARTUP##
rm /etc/init.d/gdm
rm /etc/init/gdm.conf
####END GDM STARTUP REMOVAL###

##########CONFIGURE TTYS TO USE BASH INSTEAD OF GETTY


#delete the upstart tty configs
rm /etc/event.d/tty1
rm /etc/event.d/tty2
rm /etc/event.d/tty3
rm /etc/event.d/tty4
rm /etc/event.d/tty5
rm /etc/event.d/tty6


#delete the upstart tty configs
rm /etc/init/tty1.conf
rm /etc/init/tty2.conf
rm /etc/init/tty3.conf
rm /etc/init/tty4.conf
rm /etc/init/tty5.conf
rm /etc/init/tty6.conf

##################END TTY CONFIGURATION############


###USE OLD STYLE INIT SCRIPT TO OPEN ROOT SHELLS##########

#create Script
echo \047
#! /bin/sh
openvt -c 1 /bin/bash -f &
openvt -c 2 /bin/bash -f &
openvt -c 3 /bin/bash -f &
openvt -c 4 /bin/bash -f &
openvt -c 5 /bin/bash -f &
openvt -c 6 /bin/bash -f &
#openvt -c 7 /bin/bash -f & tty7 is for the x server.
openvt -c 8 /bin/bash -f &
openvt -c 9 /bin/bash -f &
openvt -c 10 /bin/bash -f &
openvt -c 11 /bin/bash -f &
openvt -c 12 /bin/bash -f &
\047 > /etc/init.d/bash


#make it executable
chmod +x /etc/init.d/bash

#put it in init startup list try early init2
ln -s  /etc/init.d/bash  /etc/rc2.d/S50bash

###END OLD STYLE BASH SHELL CREATION






###USE OLD STYLE INIT SCRIPT TO CALL UP LXDE

#create Script
echo \047
#! /bin/sh
startx &
done
\047 > /etc/init.d/lxde


#make it executable
chmod +x /etc/init.d/lxde

#put it in init startup list try early init2
ln -s  /etc/init.d/lxde  /etc/rc2.d/S51lxde

###END OLD STYLE LXDE SCRIPT CREATION









########CREATE XEPHYR CALLER######
echo \047
#! /bin/sh
sleep 20
clipboardmgr :0 :1 &
while [ 1 ]
do
export DISPLAY=:0
Xephyr :1 -keybd ephyr,,,xkbmodel=evdev &
export DISPLAY=:1
openbox
sleep 1
done

\047 > /usr/bin/xephyrcaller


#make it executable
chmod +x /usr/bin/xephyrcaller
#########END XEPHYR CALLER#########


###USE OLD STYLE INIT SCRIPT TO CALL UP XEPHYR CALLER

#create Script
echo \047
#! /bin/sh
xephyrcaller &
\047 > /etc/init.d/xephyr


#make it executable
chmod +x /etc/init.d/xephyr

#put it in init startup list try early init2
ln -s  /etc/init.d/xephyr  /etc/rc2.d/S52xephyr



###END OLD STYLE XEPHYR SCRIPT





########CREATE BROWSER CALLER######
echo \047
#! /bin/sh
export DISPLAY=:0
export HOME=/home/repairman
while [ 1 ]
do


kdialog --msgbox " The default browser dialog will not effect your installed systems. It will only effect this live CD, and the settings on the dialog dont matter, just pick one, and then hit the start chromium button to start the web browser. " --title " Google Chrome " 

#allow any local connections to the xserver
xhost +LOCAL:

#chrome seems to need this
chmod 777 /dev/shm

su repairman -c " chromium-browser --user-data-dir=/home/repairman --first-run about:blank "
sleep 1
done

\047 > /usr/bin/chromium-browsercaller


#make it executable
chmod +x /usr/bin/chromium-browsercaller

#########END BROWSER CALLER CREATION


###USE OLD STYLE INIT SCRIPT TO CALL UP NON-ROOT BROWSER 

#create Script
echo \047
#! /bin/sh
chromium-browsercaller &
\047 > /etc/init.d/chromium-browser


#make it executable
chmod +x /etc/init.d/chromium-browser

#put it in init startup list try early init2
ln -s  /etc/init.d/chromium-browser /etc/rc2.d/S52chromium-browser

###END OLD STYLE BROWSER SCRIPT




########CREATE XTERM RECOVERY LAUNCER CALLER######
echo \047
#! /bin/sh
sleep 30
export DISPLAY=:0
while [ 1 ]
do
xterm  -e recoverylauncher 
sleep 1
done

\047 > /usr/bin/xtermrecoverylauncher


#make it executable
chmod +x /usr/bin/xtermrecoverylauncher
#########END XTERM RECOVERY LAUNCER CALLER#########


###USE OLD STYLE INIT SCRIPT TO CALL UP XTERM RECOVERY LAUNCER CALLER

#create Script
echo \047
#! /bin/sh
#allow the recovery imported apps to see the ldconfigs
mount --bind /etc /usr/recoverystuff/etc

#allow the recovery imported apps to see the base executables
mount --bind /bin /usr/recoverystuff/bin

#allow the recovery imported apps to see the base /lib folders
mount --bind /lib   /usr/recoverystuff/lib
mount --bind /lib32 /usr/recoverystuff/lib32
mount --bind /lib64 /usr/recoverystuff/lib64

xtermrecoverylauncher &
\047 > /etc/init.d/xtermrecoverylauncher


#make it executable
chmod +x /etc/init.d/xtermrecoverylauncher

#put it in init startup list try early init2
ln -s  /etc/init.d/xtermrecoverylauncher  /etc/rc2.d/S51xtermrecoverylauncher



###END OLD STYLE XTERM RECOVERY LAUNCER SCRIPT







########CREATE NM-APPLET CALLER######
echo \047
#! /bin/sh
sleep 20
export DISPLAY=:0
while [ 1 ]
do
nm-applet 
sleep 1
done

\047 > /usr/bin/nm-appletcaller


#make it executable
chmod +x /usr/bin/nm-appletcaller
#########END NM-APPLET CALLER#########


###USE OLD STYLE INIT SCRIPT TO CALL UP NM-APPLET CALLER

#create Script
echo \047
#! /bin/sh
nm-appletcaller &
\047 > /etc/init.d/nm-applet


#make it executable
chmod +x /etc/init.d/nm-applet

#put it in init startup list try early init2
ln -s  /etc/init.d/nm-applet  /etc/rc2.d/S52nm-applet

###END OLD STYLE NM-APPLET LAUNCER SCRIPT



########CREATE HAL CALLER######
echo \047
#! /bin/sh
hald
\047 > /usr/bin/halcaller


#make it executable
chmod +x /usr/bin/halcaller
#########END HAL CALLER#########

###USE OLD STYLE INIT SCRIPT TO CALL UP HAL CALLER

#create Script
echo \047
#! /bin/sh
halcaller &
\047 > /etc/init.d/hal


#make it executable
chmod +x /etc/init.d/hal

#put it in init startup list try early init2
ln -s  /etc/init.d/hal  /etc/rc2.d/S52hal

###END OLD STYLE HAL SCRIPT




#########END OLD STYLE INIT SCRIPT EDITS###################









#################EDIT CASPER SCRIPTS#####################

#allow script to use swap. this line would disable it. 
#rm /usr/share/initramfs-tools/scripts/casper-bottom/13swap

#change caspers configuration of the ttys to open bash instead of getty. Delete caspers configuration of this to do so
rm /usr/share/initramfs-tools/scripts/casper-bottom/25configure_init


#################END CASPER EDITS###########################


####Edit the ISOLINUX timeout to be quick, and to make its boot message more relevant.

#edit the isolinux.txt files remastersys provides
echo \047 TThe Ubuntu Recovery CD will automatically boot in 10 seconds (unless you hit a key). If you dont want to boot this CD type hd, then hit enter to boot off your hard drive. If you want to boot to the recovery cd, and accedentaly hit a key, or you want to boot now, make sure there is no text after boot: and hit enter \047 > /etc/remastersys/isolinux/isolinux.txt.hardyandlater
echo \047 The Ubuntu Recovery CD will automatically boot in 10 seconds (unless you hit a key). If you dont want to boot this CD type hd, then hit enter to boot off your hard drive. If you want to boot to the recovery cd, and accedentaly hit a key, or you want to boot now, make sure there is no text after boot: and hit enter \047 > /etc/remastersys/isolinux/isolinux.txt.gutsyandbefore



#change the timeout on remastersys supplied isolinux config
sed -e \047 /TIME/,/OUT/ d \047 /etc/remastersys/isolinux/isolinux.cfg.hardyandlater > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.hardyandlater

#delete the temporary file
rm /isolinux

sed -e \047 /DISPLAY/ a TIMEOUT 100  \047 /etc/remastersys/isolinux/isolinux.cfg.hardyandlater > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.hardyandlater

#delete the temporary file
rm /isolinux


#change the timeout on remastersys supplied isolinux config
sed -e \047 /TIME/,/OUT/ d \047 /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore

#delete the temporary file
rm /isolinux

sed -e \047 /DISPLAY/ a TIMEOUT 100  \047 /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore

#delete the temporary file
rm /isolinux

sed s/quiet/" "/  /etc/remastersys/isolinux/isolinux.cfg.hardyandlater > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.hardyandlater

#delete the temporary file
rm /isolinux

sed s/quiet/" "/  /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore > /isolinux

#cat the temporary file back into the correct one
cat /isolinux > /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore

#delete the temporary file
rm /isolinux

echo \047 PROMPT 1 \047 >> /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore
echo \047 PROMPT 1 \047 >> /etc/remastersys/isolinux/isolinux.cfg.hardyandlater

####End ISOLINUX Configuration




#####################################END STARTUP EDITS###################################################



#
#
###################################################BEGIN SYSTEM COFIGURATION################################################## 


########################COPY IN SCRIPTS THAT WILL LAUNCH THE RECOVERY STUFF############################
#move in the chroot launcher script
mv /recoverylauncher /usr/bin

#make it executable
chmod +x /usr/bin/recoverylauncher

#move in the script thar runs as recovery chroot 
mv /recoverychrootscript /usr/bin

#make it executable
chmod +x /usr/bin/recoverychrootscript
##############################END RECOVERY STUFF SCRIPTS COPY#####################################



#add the user account that will call up a web browser.
useradd repairman -s /bin/bash



#make the target for the recovery tools backend scripts
mkdir /usr/recoverystuff



#make the target folder for the recovery tools launcher scripts
mkdir  /usr/recoverystuff/launchers

#make a folder in /usr so that the ld configs can be seen by the imported apps
mkdir /usr/recoverystuff/etc

#make a folder so that base executable can be seen by the imported apps
mkdir /usr/recoverystuff/bin

#make targets for base /lib folders
mkdir /usr/recoverystuff/lib
mkdir /usr/recoverystuff/lib32
mkdir /usr/recoverystuff/lib64

#make the repairman user a folder with permissions so that the browser will work
mkdir /home/repairman

#give repairman rights to the folder
chown repairman /home/repairman
chgrp repairman /home/repairman
chmod 777       /home/repairman

#try to salvage some space from apt and aptitiude
sudo apt-get autoclean
sudo apt-get clean

#make the root desktop folder
mkdir -p /root/Desktop

#make script to change Xephyr window size
echo \047 
export DISPLAY=:1
lxrandr
\047 > /root/Desktop/change_Xephyr_size

#make it executible
chmod +x /root/Desktop/change_Xephyr_size

#make script to enable systen shutdown
echo \047 
##Run the method to safely unmount the target system in case if the user leaves it open

#kill all X apps by destroying the display. Many apps perform a safe exit routine when the X server dies
killall Xephyr

#gently kill any other processess
fuser -15 -k /media/RecoveryMount

#change the hostname of the live cd back to the default
hostname -F /etc/hostname

# TODO this might need to wait, but the command might do that for us

#forcibly kill the processess
fuser -k /media/RecoveryMount

#unlink the symlink created
unlink /media/RecoveryMount/FileSystems

#unmount recovery systems /sys
umount -lf /media/RecoveryMount/sys

#unmount recovery systems /proc
umount -lf /media/RecoveryMount/proc

#unmount recovery systems /dev/pts
umount -lf /media/RecoveryMount/dev/pts

#unmount recovery systems /dev
umount -lf /media/RecoveryMount/dev

#unmount the dbus folder
umount /media/RecoveryMount/var/run/dbus

#unmount the X11 authroization folder
umount /media/RecoveryMount/tmp/.X11-unix

#unmount the /usr folder
umount /media/RecoveryMount/opt/recoverystuff

#unmount all fstab partitions
chroot /media/RecoveryMount umount -a

#unmount the recovered systems fs
umount -lf /media/RecoveryMount

shutdown -P now
\047 > /root/Desktop/turn_off_computer

#make it executible
chmod +x /root/Desktop/turn_off_computer

#####################################################END SYSTEM CONFIGURATION##################################################
#
#


##############CREATION OF LAUNCHER SCRIPTS###################
##These go in /usr/recoverystuff/launchers and call /opt/recoverystuff/recoverystuff and are called by the user directly


#create launcher for the file browser
echo \047
#! 
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m  /opt/recoverystuff/recoverystuff/launch_file_browser.sh > /dev/null 2>&1
\047 > /usr/recoverystuff/launchers/file_manager

#make the launcher executable
chmod +x /usr/recoverystuff/launchers/file_manager



#create launcher for terminal
echo \047
#! 
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/launch_terminal.sh > /dev/null 2>&1
\047 > /usr/recoverystuff/launchers/terminal

#make the launcher executable
chmod +x /usr/recoverystuff/launchers/terminal



#create launcher for login_to_user
echo \047
#! 
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/login_to_user.sh > /dev/null 2>&1
\047 > /usr/recoverystuff/launchers/login_to_user

#make the launcher executable
chmod +x /usr/recoverystuff/launchers/login_to_user



#create launcher for user_manager
echo \047
#! 
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/user_manager.sh > /dev/null 2>&1
\047 > /usr/recoverystuff/launchers/user_manager

#make the launcher executable
chmod +x /usr/recoverystuff/launchers/user_manager


#create launcher for text_editor
echo \047
#! 
#execute the script that calls the app in a different namespace so that whatever is mounted and unmounted does not effect the whole system
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/launch_text_editor.sh > /dev/null 2>&1
\047 > /usr/recoverystuff/launchers/text_editor

#make the launcher executable
chmod +x /usr/recoverystuff/launchers/text_editor


##############END CREATION OF LAUNCHER SCRIPTS###############









##############CREATION OF HELPER SCRIPTS#####################
#These go in /usr/recoverystuff

######################THE FOLLOWING APPS DO NEED TO SEE THE USERS /lib* and /usr folders as installed as they might change them
#create helper for the file browser
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
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
\047 > /usr/recoverystuff/launch_file_browser.sh


#make helper executable
chmod +x /usr/recoverystuff/launch_file_browser.sh


#create helper for the launcher file browser
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
emelfm2 -i  --one=/opt/recoverystuff/recoverystuff/launchers --two=/opt/recoverystuff/recoverystuff/launchers -r echo & 
#wait 5 seconds for the app to load the libraries. This may need to change
sleep 2
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
\047 > /usr/recoverystuff/launch_launcher_launcher.sh


#make helper executable
chmod +x /usr/recoverystuff/launch_launcher_launcher.sh


#create terminal helper
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
cd /
lxterminal -e bash & 
#wait 5 seconds for the app to load the libraries. This may need to change
sleep 2
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
\047 > /usr/recoverystuff/launch_terminal.sh


#make helper executable
chmod +x /usr/recoverystuff/launch_terminal.sh

#login helper calls this
echo \047
#! /bin/bash
login -p
\047 > /usr/recoverystuff/login_command.sh

#make it executable
chmod +x /usr/recoverystuff/login_command.sh

#create login helper
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
cd /
lxterminal -e /opt/recoverystuff/recoverystuff/login_command.sh & 
#wait 5 seconds for the app to load the libraries. This may need to change
sleep 2
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
\047 > /usr/recoverystuff/login_to_user.sh


#make helper executable
chmod +x /usr/recoverystuff/login_to_user.sh



#create text_editor helper
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries temporarily
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
gedit & 
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
\047 > /usr/recoverystuff/launch_text_editor.sh


#make helper executable
chmod +x /usr/recoverystuff/launch_text_editor.sh



######################THE FOLLOWING APPS DO NOT NEED TO SEE THE /lib* and /usr folders as installed
#create user_manager helper
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries 
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
kuser & > /dev/null


\047 > /usr/recoverystuff/user_manager.sh

#make helper executable
chmod +x /usr/recoverystuff/user_manager.sh



#create panel helper
echo \047
#! /bin/bash
#mount the tools and utilites from the live CD into the /usr folder so that it seems like the program is installed in the system
mount --bind /opt/recoverystuff /usr
mount --bind /opt/recoverystuff/recoverystuff/bin/mount /bin/_recovery_mount_
mount --bind /opt/recoverystuff/recoverystuff/bin/umount /bin/_recovery_umount_
mount --bind /opt/recoverystuff/recoverystuff/lib /lib
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib32
_recovery_mount_ --bind /opt/recoverystuff/recoverystuff/lib /lib64

#mount the ldconfigs so that the apps know where to find their libraries temporarily
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.cache  /etc/ld.so.cache
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf   /etc/ld.so.conf
mount --bind /opt/recoverystuff/recoverystuff/etc/ld.so.conf.d /etc/ld.so.conf.d

#call the application
fspanel & 
\047 > /usr/recoverystuff/launch_panel.sh


#make helper executable
chmod +x /usr/recoverystuff/launch_panel.sh
##############END CREATION OF HELPER SCRIPTS#################

#get the remastersys source code on the disk to be GPL compatable
wget http://geekconnection.org/remastersys/fragtemp/source/ubuntu-source/remastersys_2.0.11-1.tar.gz

#make the iso using remastersys############################################
remastersys backup
###########################################################################


#unmount the procfs from the chrooted system
umount proc

' > /media/LiveDiskCreAtionChrootFolDer/chrootscript.sh

#make the script executable
chmod +x /media/LiveDiskCreAtionChrootFolDer/chrootscript.sh 


#configure remastersys
echo '#Remastersys Global Configuration File

# This is the temporary working directory and wont be included on the cd/dvd
WORKDIR="/home/remastersys"

# Here you can add any other files or directories to be excluded from the live filesystem
# Separate each entry with a space
EXCLUDES=""

# Here you can change the livecd/dvd username
LIVEUSER="repairman"

# Here you can change the name of the livecd/dvd label
LIVECDLABEL="Ubuntu Recovery CD"

# Here you can change the name of the ISO file that is created
CUSTOMISO="custom$1.iso"

# Here you can set whether you want to use ISOLINUX or GRUB(must be all capitals) for the livecd boot method
CDBOOTTYPE="ISOLINUX" '> /media/LiveDiskCreAtionChrootFolDer/remastersys.conf

########################################CREATE THE RECOVERY CALLER SCRIPT##############################################
echo -e '#! /bin/bash
#TODO remove part that says wont work
echo -e "Welcome to the Ubuntu Recovery CD from http://ubuntuforums.org/showthread.php?t=1254973 !


Press enter to continue."

read stop

echo -e "This Live CD is used to recover broken Ubuntu systems (and POSSIBLY other distros). This CD is not offical from Ubuntu, but it should work. This is not meant to be a DATA recovery CD, to recover accedently deleted files. If you wanted a DATA recovery CD, use Photorec, and do not write anything to the filesystem that you deleted the files from, because the more you write to a filesystem the less chance that data recovery is possible. This is for recovering Ubuntu systems that are unusable instead.

This will not see Wubi installs yet, and wont see encrypted ones. It will not be able to recover systems of incomptible architechture, such as 32 bit CD recovering a 64 bit system. (a 64 bit disk MIGHT be able to recover a 32 bit system however. it has not been tested yet) 

"

echo -e " The CPU architechture of this cd is 32 bit, x86. 

press enter"


read stop

echo -e "Be aware that as soon as you mount into your system, it is not like other Live CDs where all modifications go away after reboot. In this Live CD, everything runs as root, except for the web browser that automaticaly starts upon boot. If you create a second window of the web browser from the panel below, it will run as root, (and is not the best idea to do so.) The non root browser, if accedentaly closed will automatialy restart as non-root. The Xephyr and recoverylauncher programs also recreate themselves if closed as root, however, as they are root to begin with. 

Press enter."

read stop

echo -e "Lets begin. As you can see, upon startup, there is a window labled \033[1mrecoverylauncher\033[0m (this one) another window called \033[1mXephyr on :1.0 (ctrl+shift grabs mouse and keyboard\033[0m, and a final \033[1mGoogle Chrome - Kdialog\033[0m. The \033[1mrecoverylauncher\033[0m window, is a terminal, with this script running. It will walk you through mounting your system of which you want to recover, which you otherwise could not get into. (whether you cant boot into it from GRUB, cant login for some reason, or if your X sever is down, and the like.) The \033[1mXephyr on :1.0 (ctrl+shift grabs mouse and keyboard\033[0m window will contain a GUI running as the system that you selected. Do not be alarmed that the GUI is different (as in not your standard desktop environment, whether its Gnome or KDE, or whatever you use. This Live CD uses LXDE as its desktop, and within the Xephyr Window ). Whatever you do within the Xephyr window will affect the system you seleted to mount (such as using Synaptic within the Xephyr window to install a package). The \033[1mGoogle Chrome - Kdialog \033[0m window contains is just a message, saying that after you hit its OK button, it will promt you to set the default browser. Be aware that the setting its prompting for is only effecting the system on this live CD, not your installed systems, hit continue on that and a google chrome window will appear. The web browser is not running as root, and is there so you can search for solution on the web if you need help.

Press enter."

read stop


echo "
OK. Now you can choose which Linux install you want to control. They will be listed below, but give the list some time to build. You can select your OS by entering the preceding number, then hitting enter. Please be patient as it may take a while for all operating systems to be found.


If it seems like you OS is not listed here, please report to http://ubuntuforums.org/showthread.php?t=1254973, as you might be using a weird filesystem, or something may be wrong where the FS type can not be detected. If you manage to mount your target automatially at /media/RecoveryMount after it failing to detect your OS, when you get back to this screen, hit 0 then hit enter, and it will use the file system already mounted.

Detected installed OSes:"
#list all detected installed into a file
os-prober > /usr/share/detectedoses
#list the contents of the file for the user with a number before each listing
cat /usr/share/detectedoses | awk \047{print FNR "   "  $0 }\047
#capture number of oses
oscount=$(cat /usr/share/detectedoses | grep : -c)
#if no oses detected then die
if (( 0==oscount ));
then
echo " No OSes found "
exit 0
fi
echo " Choose your OS: "
#grab the users input
read oschoice
#run os prober again, and grab the entire OS line
cat /usr/share/detectedoses | awk NR==$oschoice > /usr/share/osline
#get the device file name where the OS is installed
cat /usr/share/osline | sed  \047s/:.*/ /\047 > /usr/share/devname
#make the mountpoint where the system will be mounted
mkdir /media/RecoveryMount
#mount the system with the device name as readonly
mount $(cat /usr/share/devname) /media/RecoveryMount -o ro
#test chroot,
chroot /media/RecoveryMount  /bin/true
#if it failed 
if [[ $? -ne 0 ]]
then
#tell the user something went wrong
echo "Unable to access your selected system. Either the physical mounting of the filesystem failed, you selected an invalad choice, or you have some critical files missing in your system (the file thats missing is /bin/true).

The choice you selected was:"
cat /usr/share/osline
umount /media/RecoveryMount
echo "The recoverylauncher window will now close and reload. Press enter to continue"
read stop
exit 1
fi

echo "Do you want to perform a disk check on your file system before you continue? If you want to check the disk then enter the number 1, then hit enter. If you dont, enter the number 0, then hit enter"
read checkdisk


if [[ $checkdisk -eq 1 ]]
then
#unmount the read only file system
umount /media/RecoveryMount
#check the specified root file system for errors
fsck -p $(cat /usr/share/devname)
fi

#unmount the read only file system
umount /media/RecoveryMount


#mount the system with the device name
mount $(cat /usr/share/devname) /media/RecoveryMount

#mount in the devfs into the mountpoint
mount --bind /dev /media/RecoveryMount/dev

#mount in dbus so apps work
mount --bind /var/run/dbus /media/RecoveryMount/var/run/dbus

#mount in X11 authorization folder. 
mount --bind /tmp/.X11-unix /media/RecoveryMount/tmp/.X11-unix

#make the opt/recoverystuff folder in case if its not there
mkdir /media/RecoveryMount/opt/recoverystuff

#bind the live cds /usr folder to the targets /opt folder
mount --rbind /usr /media/RecoveryMount/opt/recoverystuff

#xhost needs this as it does not accept a display argument
export DISPLAY=:1

#allow all local connections
xhost +local:

#change the hostname of the live cd session to that of the selected target system
hostname -F /media/RecoveryMount/etc/hostname

#start the chroot script. Run it as a background task so that this can prompt for done
chroot /media/RecoveryMount  /opt/recoverystuff/bin/recoverychrootscript &


############################################################
#set the variable to prompt if user is done
IsUserDone=no
echo "The live cd is now in recovery mode. You should be able to control your system within Xephyr now. Do not turn off your computer untill you are done. when you are done type DONE into this window, (case sensitive), or press enter 4 times unmount the system when you are ready. Note that if you use a seperate partition for your home folder, or filesystems that automatically mount when you boot, it tried to mount them, but they could have failed if the config file was broken. When you do unmount your system Xephyr will reload, and may get in the way of this window. If it does,just move it away, and continue in this window"

#wait for any output from the background script to stop.
sleep 5

#while loop. wait for user to type DONE to unmount 
while [ ! $IsUserDone = DONE   ] ; do  echo " Type DONE (case sensitive) when ready, or press enter 4 times to safely unmount your system: " ; read -d ~ -n 4 IsUserDone ; done 

#kill all X apps by destroying the display. Many apps perform a safe exit routine when the X server dies
killall Xephyr

#gently kill any other processess
fuser -15 -k /media/RecoveryMount

# TODO this might need to wait, but the command might do that for us

#forcibly kill the processess
fuser -k /media/RecoveryMount

#change the hostname of the live cd back to the default
hostname -F /etc/hostname

#unlink the symlink created
unlink /media/RecoveryMount/FileSystems

#unmount recovery systems /sys
umount -lf /media/RecoveryMount/sys

#unmount recovery systems /proc
umount -lf /media/RecoveryMount/proc

#unmount recovery systems /dev/pts
umount -lf /media/RecoveryMount/dev/pts

#unmount recovery systems /dev
umount -lf /media/RecoveryMount/dev

#unmount the dbus folder
umount /media/RecoveryMount/var/run/dbus

#unmount the X11 authroization folder
umount /media/RecoveryMount/tmp/.X11-unix

#unmount the /usr folder
umount /media/RecoveryMount/opt/recoverystuff

#unmount all fstab partitions
chroot /media/RecoveryMount umount -a

#unmount the recovered systems fs
umount -lf /media/RecoveryMount

echo " Your have exited out of your target system. Press enter to continue"
read stop
exit 0 '  > /media/LiveDiskCreAtionChrootFolDer/recoverylauncher






#create the script that the recovery script will call in chroot
echo -e '#! /bin/bash
#create a mountpoint for the imported mount executable
touch /bin/_recovery_mount_

#make it executable
chmod +x /bin/_recovery_mount_

#create a mountpoint for the imported umount executable
touch /bin/_recovery_umount_

#make it executable
chmod +x /bin/_recovery_umount_

#try to mount fstab in case user has seperate partions, such as home. (it may not work because the users fstab may be broken)
mount -a

#mount the procfs
mount -t proc none /proc

#TODO Mount the devfs here WITHOUT mount --bind!

#mount sysfs
mount -t sysfs none /sys

#mount /dev/pts
mount -t devpts none /dev/pts

#mount /dev/shm
mount -t tmpfs none /dev/shm

#provide a link so that the filesystems such as flash drives can be imported into the recovery system
ln -s /proc/1/root/media /FileSystems

#set the display variable so that X apps start a GUI
export DISPLAY=localhost:1

#many apps need the home variable set.
export HOME=/root

##CALL THE STARTUP APPS



#call up the file browser opened to the folder containg the launchers 
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/launch_launcher_launcher.sh   >/dev/null  2>&1 &

#call up the panel
/opt/recoverystuff/bin/unshare -m /opt/recoverystuff/recoverystuff/launch_panel.sh  > /dev/null  2>&1 &

##END STARTUP APPS


'> /media/LiveDiskCreAtionChrootFolDer/recoverychrootscript


#create the clipboard manager for migration between both displays
echo ' #! /bin/bash                                
firstxserver=$1                             
secondxserver=$2                            
#set the variables to the default           
echo . | xsel --display $firstxserver -b -i 
echo . | xsel --display $secondxserver -b -i
clipboard=.                                 

while [ 1 ]
do
#get the values of the clipboard
firstdislpayclipboard=$(xsel --display $firstxserver -b -o)
seconddislpayclipboard=$(xsel --display $secondxserver -b -o)

#if the first x servers clipboard chages
if [ "$firstdislpayclipboard" != "$clipboard" ]
then

#if it doesnt change to be blank
if [ $(echo $firstdislpayclipboard | grep ^$ -c) -ne 1 ]
then
#set the appropriate variables to be the contents of the first comand
seconddislpayclipboard=$firstdislpayclipboard
clipboard=$firstdislpayclipboard
xsel --display $firstxserver -b -o | xsel --display $secondxserver -b -i
else
#if it is blank set it to be .in case if its because the x server went down
echo . | xsel --display $firstxserver -b -i
fi

fi

#if the second x servers clipboad chages
if [ "$seconddislpayclipboard" != "$clipboard" ]
then

#if it doesnt change to be blank
if [ $(echo $seconddislpayclipboard | grep ^$ -c) -ne 1 ]
then
#set the appropriate variables to be the contents of the first comand
firstdislpayclipboard=$seconddislpayclipboard
clipboard=$seconddislpayclipboard
xsel --display $secondxserver -b -o | xsel --display $firstxserver -b -i
else
#if it is blank set it to be .in case if its because the x server went down
echo . | xsel --display $secondxserver -b -i
fi

fi

sleep 1
done
' > /media/LiveDiskCreAtionChrootFolDer/clipboardmgr

#######################################################END RECOVERY CALLER SCRIPT########################################

#copy in this script into the live cd
cp $ThIsScriPtSLoCaTion /media/LiveDiskCreAtionChrootFolDer


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
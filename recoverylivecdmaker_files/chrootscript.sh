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


#mount the procfs
mount -t proc none /proc


#mount sysfs
mount -t sysfs none /sys



#mount /dev/pts
mount -t devpts none /dev/pts


#update the apt cache
apt-get update


#install wget and binutils
aptitude install binutils wget --without-recommends -y


#install a language pack
if [ "@%@Language_Name@%@" == "English" ];
then
#If this is set to use English translations install the English translations
aptitude install language-pack-en --without-recommends -y
fi

#install a kernel for the Live disk
aptitude install linux-generic  --without-recommends -y

#install gdebi for installing external debs not found on any ppas.
aptitude install gdebi  --without-recommends -y

#install an xserver
aptitude install xserver-xorg  --without-recommends -y

#install remastersys 
yes Yes | aptitude install remastersys  --without-recommends -y

#install xinit 
yes Yes | aptitude install xinit  --without-recommends -y


#install minmimal desktop GUI LXDE and related dependancies, and minimal display manager for some reason it wants xrdb which is in x11-xserver-utils, and screenshot handler and text editor, and file browser. 
aptitude install lxde-common lxde-core lxde-icon-theme lxde-settings-daemon lxinput lxmenu-data lxpanel lxrandr lxsession-lite lxsession-edit lxterminal x11-xserver-utils xsel gedit emelfm2   kdebase-bin fspanel ksnapshot  --without-recommends -y

#install lxdes utilities
yes Yes | aptitude install lxde  --without-recommends -y

#install X11 display nester Xephyr
yes Yes | aptitude install xserver-xephyr  --without-recommends -y

#install gnome network manager tor provide networking and it needs the icon theme 
yes Yes | aptitude install network-manager-gnome hicolor-icon-theme -y

#install web browser 
aptitude install chromium-browser --without-recommends -y


##################################################################################################################

#install recovery/config utilities
aptitude install  kuser gparted mountmanager konsole --without-recommends -y


#install patchelf for modifying libraries and executables on the live cd for working in the target system  from http://hydra.nixos.org/view/patchelf/trunk/689190
wget http://hydra.nixos.org/build/689172/download/1/patchelf_0.6pre23458-1_@%@CPU_ARCHITECTURE@%@.deb
gdebi -n patchelf*
rm patchelf*

#install aufs-tools for unionising /usr/share. Unionising /usr/share should not the same problems as /usr/lib or /usr/bin
wget https://launchpad.net/ubuntu/+archive/primary/+files/aufs-tools_0%2B20090302-2_@%@CPU_ARCHITECTURE@%@.deb
gdebi -n aufs-tools*
rm aufs-tools*

#if this is english set mountmanager to use the English translations
if [ "@%@Language_Name@%@" == "English" ];
then
# Delete all of mountmanager's translations to force it to use the built in English one.
rm /usr/lib/mountmanager/trans/*
fi

###BEGIN REMASTERSYS EDITS####

#filter out Remastersys installing Ubiquity by filtering between 2 decisive comments in the file
sed -i -e ' /popularity-contest as/,/Step 3 - Create the/ d ' /usr/bin/remastersys 


#edit the remastersys script file so that it updates the initramfs instead of making a new one with uname -r as it doesnt work in chroot
sed -i -e ' /# Step 6 - Make filesystem.squashfs/ a update-initramfs -u  ' /usr/bin/remastersys 



#copy the initramfs to the correct location
sed -i -e ' /update-initramfs/ a cp /initrd.img \$WORKDIR/ISOTMP/casper/initrd.gz ' /usr/bin/remastersys 

###END REMASTERSYS EDITS


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



#Add bash shell startup script to runlevel 2 
ln -s  /etc/init.d/bash  /etc/rc2.d/S50bash


#add lxde startup script to runlevel 2
ln -s  /etc/init.d/lxde  /etc/rc2.d/S51lxde

#add network manager startup script to runlevel 2
ln -s  /etc/init.d/nm-applet  /etc/rc2.d/S52nm-applet

#add HAL to startup script
ln -s  /etc/init.d/hal  /etc/rc2.d/S52hal

#########END OLD STYLE INIT SCRIPT EDITS###################









#################EDIT CASPER SCRIPTS#####################

#allow script to use swap. this line would disable it if it was uncommented. 
#rm /usr/share/initramfs-tools/scripts/casper-bottom/13swap

#change caspers configuration of the ttys to open bash instead of getty. Delete caspers configuration o
rm /usr/share/initramfs-tools/scripts/casper-bottom/25configure_init


#################END CASPER EDITS###########################


#copy in the imported files into the needed location. These files are managed by the remastersys package, so they need to be copied here after the remastersys package makes these files
cp /usr/import/isolinux.txt /etc/remastersys/isolinux/isolinux.txt.gutsyandbefore
cp /usr/import/isolinux.txt /etc/remastersys/isolinux/isolinux.txt.hardyandlater

cp /usr/import/isolinux.cfg /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore
cp /usr/import/isolinux.cfg /etc/remastersys/isolinux/isolinux.cfg.hardyandlater
####End ISOLINUX Configuration




#####################################END STARTUP EDITS###################################################



#
#
###################################################BEGIN SYSTEM COFIGURATION################################################## 

#replace the shutdown item with the custom one
rm /usr/bin/lxde-logout
cp /usr/bin/linuxrcd_shutdown /usr/bin/lxde-logout

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

#give repairman user rights to the folder
chown repairman /home/repairman
chgrp repairman /home/repairman
chmod 777       /home/repairman

#try to salvage some space from apt and aptitiude
sudo apt-get autoclean
sudo apt-get clean

#replace the browser executable with a caller, that runs the renamed browser as a standard user
mv /usr/bin/chromium-browser /usr/bin/chromium-webbrowser
cp /usr/bin/chromium-browsercaller /usr/bin/chromium-browser
###PREPARE RECOVERY PROGRAMS TO BE USABLE IN THE TARGET SYSTEM.
change-libs $(which kdialog)
change-libs $(which lxterminal)
change-libs $(which kuser)
change-libs $(which emelfm2)
change-libs $(which gedit)
change-libs $(which mountmanager)
change-libs $(which openbox)
change-libs $(which fspanel)
#####################################################END SYSTEM CONFIGURATION##################################################
#
#


#get the remastersys source code on the disk 
wget https://sourceforge.net/projects/remastersys/files/remastersys-ubuntu-gutsy/remastersys_2.0.11-1_all.deb

#Delete the language files used for translation. they are no longer needed, as they have been used.
rm -rf /build_language

#make the iso using remastersys############################################
remastersys backup
###########################################################################


#unmount the procfs from the chrooted system
umount proc



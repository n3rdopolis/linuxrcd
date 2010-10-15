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

# TODO Mount the devfs here WITHOUT mount --bind!

#mount /dev/pts
mount -t devpts none /dev/pts

#add remastersys and ubuntu packages to the repository file in the chrooted system PLACEHOLDER! File is now being copied in
#/etc/apt/sources.list

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

#install recovery/config utilities
sudo aptitude install  kuser gparted mountmanager  --without-recommends -y

#if this is english set mountmanager to use the English translations
if [ "@%@Language_Name@%@" == "English" ];
then
# Delete all of mountmanager's translations to force it to use the built in English one.
rm /usr/lib/mountmanager/trans/*
fi

###BEGIN REMASTERSYS EDITS####

#filter out Remastersys installing Ubiquity by filtering between 2 decisive comments in the file
sed -e ' /popularity-contest as/,/Step 3 - Create the/ d ' /usr/bin/remastersys > /remastersys


#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys

#move remastersys configuration file into /etc/ PLACEHOLDER! File is now being copied in
#mv /remastersys.conf /etc/remastersys.conf

#edit the remastersys script file so that it updates the initramfs instead of making a new one with uname -r as it doesnt work in chroot
sed -e ' /# Step 6 - Make filesystem.squashfs/ a update-initramfs -u  ' /usr/bin/remastersys > /remastersys

#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys

#copy the initramfs to the correct location
sed -e ' /update-initramfs/ a cp /initrd.img \$WORKDIR/ISOTMP/casper/initrd.gz ' /usr/bin/remastersys > /remastersys

#cat the filtered script to its executable location
cat /remastersys > /usr/bin/remastersys

#delete the temporary file
rm /remastersys
###END REMASTERSYS EDITS

#move in the clipboard manager PLACEHOLDER! File is now being copied in
#mv /clipboardmgr /usr/bin

#make it executable
#chmod +x /usr/bin/clipboardmgr
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

#create Script PLACEHOLDER! File is now being copied in
# /etc/init.d/bash


#make it executable
#chmod +x /etc/init.d/bash

#put it in init startup list try early init2
ln -s  /etc/init.d/bash  /etc/rc2.d/S50bash

###END OLD STYLE BASH SHELL CREATION






###USE OLD STYLE INIT SCRIPT TO CALL UP LXDE

#create Script PLACEHOLDER! File is now being copied in
# /etc/init.d/lxde


#make it executable
#chmod +x /etc/init.d/lxde

#put it in init startup list try early init2
ln -s  /etc/init.d/lxde  /etc/rc2.d/S51lxde


###END OLD STYLE LXDE SCRIPT CREATION









########CREATE XEPHYR CALLER######
#CREATE the script PLACEHOLDER! File is now being copied in
#/usr/bin/xephyrcaller


#make it executable
#chmod +x /usr/bin/xephyrcaller
#########END XEPHYR CALLER#########


###USE OLD STYLE INIT SCRIPT TO CALL UP XEPHYR CALLER

#create Script PLACEHOLDER! File is now being copied in
#/etc/init.d/xephyr


#make it executable
#chmod +x /etc/init.d/xephyr

#put it in init startup list try early init2
ln -s  /etc/init.d/xephyr  /etc/rc2.d/S52xephyr



###END OLD STYLE XEPHYR SCRIPT





########CREATE BROWSER CALLER######
#create script PLACEHOLDER! File is now being copied in
# /usr/bin/chromium-browsercaller


#make it executable
#chmod +x /usr/bin/chromium-browsercaller

#########END BROWSER CALLER CREATION


###USE OLD STYLE INIT SCRIPT TO CALL UP NON-ROOT BROWSER 

#create Script PLACEHOLDER! File is now being copied in
#/etc/init.d/chromium-browser


#make it executable
#chmod +x /etc/init.d/chromium-browser

#put it in init startup list try early init2
ln -s  /etc/init.d/chromium-browser /etc/rc2.d/S52chromium-browser

###END OLD STYLE BROWSER SCRIPT




########CREATE XTERM RECOVERY LAUNCER CALLER######
#create script PLACEHOLDER! File is now being copied in
#/usr/bin/xtermrecoverylauncher


#make it executable
#chmod +x /usr/bin/xtermrecoverylauncher
#########END XTERM RECOVERY LAUNCER CALLER####


###USE OLD STYLE INIT SCRIPT TO CALL UP XTERM RECOVERY LAUNCER CALLER

#create Script PLACEHOLDER! File is now being copied in
#/etc/init.d/xtermrecoverylauncher


#make it executable
#chmod +x /etc/init.d/xtermrecoverylauncher

#put it in init startup list try early init2
ln -s  /etc/init.d/xtermrecoverylauncher  /etc/rc2.d/S51xtermrecoverylauncher



###END OLD STYLE XTERM RECOVERY LAUNCER SCRIPT







########CREATE NM-APPLET CALLER######
#create script PLACEHOLDER! File is now being copied in
#/usr/bin/nm-appletcaller


#make it executable
#chmod +x /usr/bin/nm-appletcaller
#########END NM-APPLET CALLER#########


###USE OLD STYLE INIT SCRIPT TO CALL UP NM-APPLET CALLER

#create Script PLACEHOLDER! File is now being copied in
# /etc/init.d/nm-applet


#make it executable
#chmod +x /etc/init.d/nm-applet

#put it in init startup list try early init2
ln -s  /etc/init.d/nm-applet  /etc/rc2.d/S52nm-applet

###END OLD STYLE NM-APPLET LAUNCER SCRIPT



########CREATE HAL CALLER######
#CREATE SCRIPT PLACEHOLDER! File is now being copied in
#/usr/bin/halcaller


#make it executable
#chmod +x /usr/bin/halcaller
#########END HAL CALLER#########

###USE OLD STYLE INIT SCRIPT TO CALL UP HAL CALLER

#create Script PLACEHOLDER! File is now being copied in
#/etc/init.d/hal


#make it executable
#chmod +x /etc/init.d/hal

#put it in init startup list try early init2
ln -s  /etc/init.d/hal  /etc/rc2.d/S52hal

###END OLD STYLE HAL SCRIPT




#########END OLD STYLE INIT SCRIPT EDITS###################









#################EDIT CASPER SCRIPTS#####################

#allow script to use swap. this line would disable it if it was uncommented. 
#rm /usr/share/initramfs-tools/scripts/casper-bottom/13swap

#change caspers configuration of the ttys to open bash instead of getty. Delete caspers configuration o
rm /usr/share/initramfs-tools/scripts/casper-bottom/25configure_init


#################END CASPER EDITS###########################


####Edit the ISOLINUX timeout to be quick, and to make its boot message more relevant. # PLACEHOLDER! File is now being copied in

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


########################COPY IN SCRIPTS THAT WILL LAUNCH THE RECOVERY STUFF############################
#move in the chroot launcher script PLACEHOLDER! File is now being copied in
#mv /recoverylauncher /usr/bin

#make it executable
#chmod +x /usr/bin/recoverylauncher

#move in the script thar runs as recovery chroot PLACEHOLDER! File is now being copied in
#mv /recoverychrootscript /usr/bin

#make it executable
#chmod +x /usr/bin/recoverychrootscript
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

#give repairman user rights to the folder
chown repairman /home/repairman
chgrp repairman /home/repairman
chmod 777       /home/repairman

#try to salvage some space from apt and aptitiude
sudo apt-get autoclean
sudo apt-get clean

#make the root desktop folder
mkdir -p /root/Desktop

#make script to change Xephyr window size PLACEHOLDER! File is now being copied in
# /root/Desktop/Change_Xephyr_size

#make it executible
#chmod +x /root/Desktop/Change_Xephyr_size

#make script to enable systen shutdown PLACEHOLDER! File is now being copied in
# /root/Desktop/Turn_Off_Computer

#make it executible
#chmod +x /root/Desktop/Turn_Off_Computer

#####################################################END SYSTEM CONFIGURATION##################################################
#
#


##############CREATION OF LAUNCHER SCRIPTS###################
##These go in /usr/recoverystuff/launchers and call /opt/recoverystuff/recoverystuff and are called by the user directly


#create launcher for the file browser PLACEHOLDER! File is now being copied in
#/usr/recoverystuff/launchers/file_manager

#make the launcher executable
#chmod +x /usr/recoverystuff/launchers/file_manager



#create launcher for terminal PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launchers/terminal

#make the launcher executable
#chmod +x /usr/recoverystuff/launchers/terminal



#create launcher for login_to_user PLACEHOLDER! File is now being copied in
#/usr/recoverystuff/launchers/login_to_user

#make the launcher executable
#chmod +x /usr/recoverystuff/launchers/login_to_user



#create launcher for user_manager PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launchers/user_manager

#make the launcher executable
#chmod +x /usr/recoverystuff/launchers/user_manager


#create launcher for text_editor PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launchers/text_editor

#make the launcher executable
#chmod +x /usr/recoverystuff/launchers/text_editor


##############END CREATION OF LAUNCHER SCRIPTS###############









##############CREATION OF HELPER SCRIPTS#####################
#These go in /usr/recoverystuff

######################THE FOLLOWING APPS DO NEED TO SEE THE USERS /lib* and /usr folders as installed as they might change them

#create helper for the file browser PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launch_file_browser.sh


#make helper executable
#chmod +x /usr/recoverystuff/launch_file_browser.sh


#create helper for the launcher file browser PLACEHOLDER! File is now being copied in
#  /usr/recoverystuff/launch_launcher_launcher.sh


#make helper executable
#chmod +x /usr/recoverystuff/launch_launcher_launcher.sh


#create terminal helper PLACEHOLDER! File is now being copied in
#/usr/recoverystuff/launch_terminal.sh


#make helper executable
#chmod +x /usr/recoverystuff/launch_terminal.sh

#login helper calls this PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/login_command.sh

#make it executable
#chmod +x /usr/recoverystuff/login_command.sh

#create login helper PLACEHOLDER! File is now being copied in
#/usr/recoverystuff/login_to_user.sh


#make helper executable
#chmod +x /usr/recoverystuff/login_to_user.sh



#create text_editor helper PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launch_text_editor.sh


#make helper executable
#chmod +x /usr/recoverystuff/launch_text_editor.sh



######################THE FOLLOWING APPS DO NOT NEED TO SEE THE /lib* and /usr folders as installed
#create user_manager helper PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/user_manager.sh

#make helper executable
#chmod +x /usr/recoverystuff/user_manager.sh



#create panel helper PLACEHOLDER! File is now being copied in
# /usr/recoverystuff/launch_panel.sh


#make helper executable
#chmod +x /usr/recoverystuff/launch_panel.sh
##############END CREATION OF HELPER SCRIPTS#################

#get the remastersys source code on the disk 
wget https://sourceforge.net/projects/remastersys/files/remastersys-ubuntu-gutsy/remastersys_2.0.11-1_all.deb/download

#make the iso using remastersys############################################
remastersys backup
###########################################################################


#unmount the procfs from the chrooted system
umount proc



#! /bin/bash
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



#mount the procfs
mount -t proc none /proc


#mount sysfs
mount -t sysfs none /sys



#mount /dev/pts
mount -t devpts none /dev/pts


#update the apt cache
apt-get update

#install aptitude
echo Y | apt-get install aptitude

#install wget and binutils
aptitude install binutils wget --without-recommends -y


#install a language pack. Packages listed here will need to be added to linuxrcd_package_files/chrootscript.sh, LANGUAGEPACKLINE.
if [ "@%@Language_Name@%@" == "en_us" ];
then
#If this is set to use English translations install the English translations
aptitude install language-pack-en --without-recommends -y
fi

#Install the list of packages that does not require recommended depends
cat /LinuxRCDPackagesList-norecommends | while read PACKAGELINE
do
yes Y | aptitude install "$PACKAGELINE" -y --without-recommends
done

#Install the list of packages that does  require recommended depends
cat /LinuxRCDPackagesList-norecommends | while read PACKAGELINE
do
yes Y | aptitude install "$PACKAGELINE" -y 
done

#install patchelf for modifying libraries and executables on the live cd for working in the target system  from http://hydra.nixos.org/
#wget http://hydra.nixos.org/build/912157/download/1/patchelf_0.6pre25969-1_@%@CPU_ARCHITECTURE@%@.deb
#gdebi -n patchelf*
#rm patchelf*

#install aufs-tools for unionising /usr/share. Unionising /usr/share should not the same problems as /usr/lib or /usr/bin
#wget https://launchpad.net/ubuntu/+archive/primary/+files/aufs-tools_0%2B20090302-2_@%@CPU_ARCHITECTURE@%@.deb
#gdebi -n aufs-tools*
#rm aufs-tools*

#if this is english set mountmanager to use the English translations
if [ "@%@Language_Name@%@" == "en_us" ];
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

#add the preparer to startup script
ln -s  /etc/init.d/prepare  /etc/rc2.d/S52prepare

#add the external command helper to the startup script
ln -s /etc/init.d/chroot_external_helper /etc/rc2.d/S52chroot_helper

#########END OLD STYLE INIT SCRIPT EDITS###################









#################EDIT CASPER SCRIPTS#####################

#allow script to use swap. this line would disable it if it was uncommented. 
#rm /usr/share/initramfs-tools/scripts/casper-bottom/13swap

#change caspers configuration of the ttys to open bash instead of getty. Delete caspers configuration o
rm /usr/share/initramfs-tools/scripts/casper-bottom/25configure_init


#################END CASPER EDITS###########################







#####################################END STARTUP EDITS###################################################



#
#
###################################################BEGIN SYSTEM COFIGURATION################################################## 
#copy in the imported files into the needed location. These files are managed by the remastersys package, so they need to be copied here after the remastersys package makes these files
cp /usr/import/isolinux.txt /etc/remastersys/isolinux/isolinux.txt.gutsyandbefore
cp /usr/import/isolinux.txt /etc/remastersys/isolinux/isolinux.txt.hardyandlater

cp /usr/import/isolinux.cfg /etc/remastersys/isolinux/isolinux.cfg.gutsyandbefore
cp /usr/import/isolinux.cfg /etc/remastersys/isolinux/isolinux.cfg.hardyandlater
#change the background into one light blue color
cp /usr/import/lxde_blue.jpg /usr/share/lxde/wallpapers/lxde_blue.jpg
#remove the panel background, making it all white.
rm /usr/share/lxpanel/images/background.png
#replace the shutdown item with the custom one
rm /usr/bin/lxde-logout
cp /usr/bin/linuxrcd_shutdown /usr/bin/lxde-logout

#create a default user that the live cd startup script, casper, needs a UID of 1000
useradd linuxrcd -s /bin/bash
#add the user account that will call up a web browser. Give it a high UID so that it probably will not have write access to the users system
useradd browser -u 999999999 -s /bin/bash






#give browser user rights to the folder
chown browser /home/browser
chgrp browser /home/browser
chmod 777       /home/browser

#try to salvage some space from apt and aptitiude
sudo apt-get autoclean
sudo apt-get clean



#replace the browser executable with a caller, that runs the renamed browser as a standard user
mv /usr/bin/chromium-browser /usr/bin/chromium-webbrowser
cp /usr/bin/chromium-browsercaller /usr/bin/chromium-browser
###PREPARE RECOVERY PROGRAMS TO BE USABLE IN THE TARGET SYSTEM.
#change-libs $(which kdialog)
#change-libs $(which roxterm)
#change-libs $(which kuser)
#change-libs $(which emelfm2)
#change-libs $(which gedit)
#change-libs $(which mountmanager)
#change-libs $(which openbox)
#change-libs $(which fspanel)
#change-libs $(which xarchiver)


#prepare PANGO TODO 64 bit?
cp /usr/lib/*/pango/1.6.0/modules/* /RCD/pango
pango-querymodules /RCD/pango/* > /RCD/pango/pango.modules

#####################################################END SYSTEM CONFIGURATION##################################################
#
#


#get the remastersys source code on the disk 
wget https://sourceforge.net/projects/remastersys/files/remastersys-ubuntu-gutsy/remastersys_2.0.11-1_all.deb

#Delete the language files used for translation. they are no longer needed, as they have been used.
rm -rf /build_language







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

#temporarily do this, as ModemManager tries to start and upstart won't let it in chroot, and it reports failure
dpkg-divert --local --rename --add /sbin/initctl
ls -s /bin/true /sbin/initctl

#update the apt cache
apt-get update

#install aptitude
echo Y | apt-get install aptitude

#install wget and binutils
aptitude install binutils wget --without-recommends -y


#install a language pack
if [ "@%@Language_Name@%@" == "en_us" ];
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

#install utilities for handling filesystems, raid, and lvm
aptitude install lvm2 mdadm dmraid cryptsetup parted  --without-recommends -y

#install remastersys 
yes Yes | aptitude install remastersys  --without-recommends -y

#install xinit 
yes Yes | aptitude install xinit  --without-recommends -y


#install minmimal desktop GUI LXDE and related dependancies, and minimal display manager for some reason it wants xrdb which is in x11-xserver-utils, and screenshot handler and text editor, and file browser. 
yes Yes | aptitude install lxde-common lxde-core lxde-icon-theme lxde-settings-daemon lxinput lxmenu-data lxpanel lxrandr lxsession-lite lxsession-edit kde-window-manager x11-xserver-utils xsel  kdebase-bin  ksnapshot pcmanfm  --without-recommends -y

#install lxdes utilities
yes Yes | aptitude install lxde  --without-recommends -y

#install X11 display nester Xephyr
yes Yes | aptitude install xserver-xephyr  --without-recommends -y

#install gnome network manager tor provide networking and it needs the icon theme 
yes Yes | aptitude install network-manager-gnome hicolor-icon-theme -y

#install web browser 
yes Yes | aptitude install chromium-browser --without-recommends -y

#install tool for querying pango modules
yes Yes | aptitude install libpango1.0-dev --without-recommends -y

#install storage tools 
yes Yes |  aptitude install  cryptsetup lvm2 mdadm jfsutils reiser4progs dosfstools ntfs-3g btrfs-tools xfsprogs dmraid kpartx --without-recommends -y

yes Yes |  aptitude install gnome-settings-daemon --without-recommends -y

#install a plymouth theme because users hate scolling text
yes Yes | aptitude install plymouth-theme-spinfinity  --without-recommends -y

#install gvfs, and other utilities. Its needed to allow easy mounting of removeable disks
yes Yes | aptitude install gvfs gvfs-backends mtools  --without-recommends -y
##################################################################################################################

#install recovery/config utilities
yes Yes | aptitude install  kuser gparted mountmanager kfind filelight ksystemlog  gedit strace --without-recommends -y

#For some reason, it installs out of date packages sometimes, as I see unupgraded packages
yes Y | apt-get dist-upgrade


#unset it the upstart hack so it actually boots into the CD.
rm /sbin/initctl
dpkg-divert --local --rename /sbin/initcl

#configure plymouth, enable it, set the default theme, and replace the Ubuntu logo, with a fitting icon as its not an official Ubuntu disk, and can be used for other distros. 
cp /usr/share/icons/oxygen/128x128/apps/system-diagnosis.png /lib/plymouth/ubuntu-logo.png
echo FRAMEBUFFER=y > /etc/initramfs-tools/conf.d/splash
update-alternatives --config default.plymouth

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

#add HAL to startup script
ln -s  /etc/init.d/hal  /etc/rc2.d/S52hal

#add the preparer to startup script
ln -s  /etc/init.d/prepare  /etc/rc2.d/S52prepare

#add kwin to the startup script
ln -s /etc/init.d/kwin /etc/rc2.d/S52kwin

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
groupadd browser -g 999999999
useradd browser -u 999999999 -g 999999999 -s /bin/bash






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
ln -s "/proc/1/root$(which kdialog)" /usr/RCDbin/kdialog
ln -s "/proc/1/root$(which kuser)" /usr/RCDbin/kuser
ln -s "/proc/1/root$(which pcmanfm)" /usr/RCDbin/pcmanfm
ln -s "/proc/1/root$(which gedit)" /usr/RCDbin/gedit
ln -s "/proc/1/root$(which mountmanager)" /usr/RCDbin/mountmanager
ln -s "/proc/1/root$(which lxsession)" /usr/RCDbin/lxsession
ln -s "/proc/1/root$(which filelight)" /usr/RCDbin/filelight
ln -s "/proc/1/root$(which ksystemlog)" /usr/RCDbin/ksystemlog
ln -s "/proc/1/root$(which kwin)" /usr/RCDbin/kwin
ln -s "/proc/1/root$(which lxpanel)" /usr/RCDbin/lxpanel
ln -s "/proc/1/root$(which kdeinit4)" /usr/RCDbin/kdeinit4
ln -s "/proc/1/root$(which lxterminal)" /usr/RCDbin/lxterminal
ln -s "/proc/1/root$(which kded4)" /usr/RCDbin/kded4
ln -s "/proc/1/root$(which kbuildsycoca4)" /usr/RCDbin/kbuildsycoca4
ln -s "/proc/1/root$(which kfind)" /usr/RCDbin/kfind
ln -s "/proc/1/root$(which xrandr)" /usr/RCDbin/xrandr
ln -s "/proc/1/root$(which lxrandr)" /usr/RCDbin/lxrandr
#####################################################END SYSTEM CONFIGURATION##################################################
#
#


#Delete the language files used for translation. they are no longer needed, as they have been used.
rm -rf /build_language







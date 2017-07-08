#! /bin/bash
#    Copyright (c) 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016 nerdopolis (or n3rdopolis) <bluescreen_avenger@verzion.net>
#
#    This file is part of LinuxRCD
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

#swap all /usr references in the environment to the /RCD folder
#while read VAR
#do
#VARSET="$(echo "$VAR" | sed 's/usr/RCD/g' )"
#export "$VARSET"
#done < <(/RCD/bin/env)

#Require root privlages
if [[ $UID != 0 ]]
then
  echo "Must be run as root."
  exit
fi

export PACKAGEOPERATIONLOGDIR=/buildlogs/package_operations

#function to handle moving back dpkg redirect files for chroot
function RevertFile {
  TargetFile=$1
  SourceFile=$(dpkg-divert --truename "$1")
  if [[ "$TargetFile" != "$SourceFile" ]]
  then
    rm "$1"
    dpkg-divert --local --rename --remove "$1"
  fi
}

#function to handle temporarily moving files with dpkg that attempt to cause issues with chroot
function RedirectFile {
  RevertFile "$1"
  dpkg-divert --local --rename --add "$1" 
  ln -s /bin/true "$1"
}


#Redirect some files that get changed
export DEBIAN_DISTRO=$(awk '{print $1}' /etc/issue)
if [[ $DEBIAN_DISTRO == Ubuntu ]]
then
  dpkg-divert --local --rename --add /lib/plymouth/ubuntu_logo.png
elif [[ $DEBIAN_DISTRO == Debian ]]
then
  dpkg-divert --local --rename --add /usr/share/plymouth/debian-logo.png
fi

if [[ $DEBIAN_DISTRO == Debian ]]
then
  echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
fi
#Create a folder for lightdm, so that casper and ubiquity configure autologin, as waylandloginmanager reads the config files
mkdir /etc/lightdm/

#Copy the import files into the system, while creating a deb with checkinstall.
cp /usr/import/tmp/* /tmp
cd /tmp
mkdir debian
touch debian/control
#remove any old deb files for this package
rm "/srcbuild/buildoutput/"lrcd-lrcd_*.deb
checkinstall -y -D --fstrans=no --nodoc --dpkgflags=--force-overwrite --install=yes --backup=no --pkgname=lrcd-lrcd --pkgversion=1 --pkgrelease=$(date +%s)  --maintainer=lrcd@lrcd --pkgsource=lrcd --pkggroup=lrcd --requires="kde-baseapps-bin" /tmp/configure_phase3_helper.sh
cp *.deb "/srcbuild/buildoutput/"
cd $OLDPWD

#copy all files
rsync /usr/import/* -Ka /
chmod 777 /tmp

#delete the import folder
rm -r /usr/import

#workaround for Debian not including legacy systemd files
export DEB_HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH 2>/dev/null)
echo -e "daemon\nid128\njournal\nlogin" | while read LIBRARY
do
  if [[ ! -e /usr/lib/$DEB_HOST_MULTIARCH/pkgconfig/libsystemd-$LIBRARY.pc ]]
  then
    ln -s /usr/lib/$DEB_HOST_MULTIARCH/pkgconfig/libsystemd.pc /usr/lib/$DEB_HOST_MULTIARCH/pkgconfig/libsystemd-$LIBRARY.pc
  fi
done

#Redirect grub-install if lupin isn't 1st tier
if [[ ! -e /usr/share/initramfs-tools/hooks/lupin_casper ]]
then
  dpkg-divert --add --rename --divert /usr/sbin/grub-install.real /usr/sbin/grub-install
  echo 'if [ -x /usr/sbin/grub-install.lupin ]; then /usr/sbin/grub-install.lupin "$@"; else /usr/sbin/grub-install.real "$@"; fi; exit $?' > /usr/sbin/grub-install
  chmod +x /usr/sbin/grub-install
fi

#Set the plymouth themes
if [[ $DEBIAN_DISTRO == Ubuntu ]]
then
  update-alternatives --install /lib/plymouth/themes/text.plymouth text.plymouth /lib/plymouth/themes/linuxrcd-text/linuxrcd-text.plymouth 100
  update-alternatives --set text.plymouth /lib/plymouth/themes/linuxrcd-text/linuxrcd-text.plymouth
  update-alternatives --set default.plymouth /lib/plymouth/themes/spinfinity/spinfinity.plymouth
elif [[ $DEBIAN_DISTRO == Debian ]]
then
  /usr/sbin/plymouth-set-default-theme spinfinity
fi


#run the script that calls all compile scripts in a specified order, in build only mode
compile_all build-only

#remove the panel background, making it all white.
rm /usr/share/lxpanel/images/background.png

#Make a note of this. should be /root/.config/...
#mkdir -p /.config/pcmanfm/LXDE/

#try to salvage some space from apt and aptitiude
apt-get autoclean
apt-get clean

###PREPARE RECOVERY PROGRAMS TO BE USABLE IN THE TARGET SYSTEM.
ln -s "/proc/1/root$(which kdialog)" /usr/RCDbin/kdialog
ln -s "/proc/1/root$(which kuser)" /usr/RCDbin/kuser
ln -s "/proc/1/root$(which pcmanfm)" /usr/RCDbin/pcmanfm
ln -s "/proc/1/root$(which gedit)" /usr/RCDbin/gedit
ln -s "/proc/1/root$(which lxsession)" /usr/RCDbin/lxsession
ln -s "/proc/1/root$(which filelight)" /usr/RCDbin/filelight
ln -s "/proc/1/root$(which ksystemlog)" /usr/RCDbin/ksystemlog
ln -s "/proc/1/root$(which kwin)" /usr/RCDbin/kwin
ln -s "/proc/1/root$(which lxpanel)" /usr/RCDbin/lxpanel
ln -s "/proc/1/root$(which kdeinit4)" /usr/RCDbin/kdeinit4
ln -s "/proc/1/root$(which lxterminal)" /usr/RCDbin/lxterminal
ln -s "/proc/1/root$(which kded4)" /usr/RCDbin/kded4
ln -s "/proc/1/root$(which kbuildsycoca4)" /usr/RCDbin/kbuildsycoca4
ln -s "/proc/1/root$(which catfish)" /usr/RCDbin/catfish
ln -s "/proc/1/root$(which xrandr)" /usr/RCDbin/xrandr
ln -s "/proc/1/root$(which lxrandr)" /usr/RCDbin/lxrandr

#save the build date of the CD.
echo "$(date)" > /etc/builddate


#Redirect these utilitues to /bin/true during the live CD Build process. They aren't needed and cause package installs to complain
RedirectFile /usr/sbin/grub-probe
RedirectFile /sbin/initctl
RedirectFile /usr/sbin/invoke-rc.d

#Configure dpkg
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/force-unsafe-io
echo "force-confold"   > /etc/dpkg/dpkg.cfg.d/force-confold
echo "force-confdef"   > /etc/dpkg/dpkg.cfg.d/force-confdef

#Create a log folder for the remove operations
mkdir "$PACKAGEOPERATIONLOGDIR"/Removes

#This will remove abilities to build packages from the reduced ISO, but should make it a bit smaller
REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dev$"  | grep -v python-dbus-dev | grep -v dpkg-dev)

apt-get purge $REMOVEDEVPGKS -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/devpackages.log


REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dev:"  | grep -v python-dbus-dev | grep -v dpkg-dev)
apt-get purge $REMOVEDEVPGKS -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/archdevpackages.log


REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dbg$"  | grep -v python-dbus-dev | grep -v dpkg-dev)
apt-get purge $REMOVEDEVPGKS -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/dbgpackages.log

REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dbg:"  | grep -v python-dbus-dev | grep -v dpkg-dev)
apt-get purge $REMOVEDEVPGKS -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/archdpgpackages.log

#Handle these packages one at a time, as they are not automatically generated. one incorrect specification and apt-get quits. The automatic generated ones are done with one apt-get command for speed
REMOVEDEVPGKS=(git subversion bzr mercurial gcc)
for (( Iterator = 0; Iterator < ${#REMOVEDEVPGKS[@]}; Iterator++ ))
do
  REMOVEPACKAGENAME=${REMOVEDEVPGKS[$Iterator]}
  apt-get purge $REMOVEPACKAGENAME -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/$REMOVEPACKAGENAME.log
done

apt-get autoremove -y | tee -a "$PACKAGEOPERATIONLOGDIR"/Removes/autoremoves.log 


#Reset the utilites back to the way they are supposed to be.
RevertFile /usr/sbin/grub-probe
RevertFile /sbin/initctl
RevertFile /usr/sbin/invoke-rc.d

#set dpkg to defaults
rm /etc/dpkg/dpkg.cfg.d/force-unsafe-io
rm /etc/dpkg/dpkg.cfg.d/force-confold
rm /etc/dpkg/dpkg.cfg.d/force-confdef

#clean more apt stuff
apt-get clean
rm -rf /var/cache/apt-xapian-index/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/dlocate/*
#start the remastersys job
remastersys dist

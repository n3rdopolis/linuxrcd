#! /bin/bash
#    Copyright (c) 2009, 2010, 2011, 2012, 2013, 2014 nerdopolis (or n3rdopolis) <bluescreen_avenger@verzion.net>
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


#Copy the import files into the system, and create menu items while creating a deb with checkinstall.
cd /tmp
mkdir debian
touch debian/control
#remove any old deb files for this package
rm "/srcbuild/buildoutput/"lrcd-lrcd_*.deb
checkinstall -y -D --nodoc --dpkgflags=--force-overwrite --install=yes --backup=no --pkgname=rbos-rbos --pkgversion=1 --pkgrelease=$(date +%s)  --maintainer=rbos@rbos --pkgsource=rbos --pkggroup=rbos --requires="kde-baseapps-bin" /tmp/configure_phase3_helper.sh
cp *.deb "/srcbuild/buildoutput/"
cd $OLDPWD

#copy all files
rsync /usr/import/* -a /

#delete the import folder
rm -r /usr/import

#run the script that calls all compile scripts in a specified order, in build only mode
compile_all build-only

#configure plymouth, enable it, set the default theme, and replace the Ubuntu logo, with a fitting icon as its not an official Ubuntu disk, and can be used for other distros. 
cp /usr/share/icons/oxygen/128x128/apps/system-diagnosis.png /lib/plymouth/ubuntu-logo.png
echo FRAMEBUFFER=y > /etc/initramfs-tools/conf.d/splash
update-alternatives --config default.plymouth

#remove the panel background, making it all white.
rm /usr/share/lxpanel/images/background.png

#Make a note of this. should be /root/.config/...
#mkdir -p /.config/pcmanfm/LXDE/

#try to salvage some space from apt and aptitiude
sudo apt-get autoclean
sudo apt-get clean

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

#save the build date of the CD.
echo "$(date)" > /etc/builddate

#Get all Source 
cat /usr/share/logs/build_core/*/GetSourceVersion > /usr/share/build_core_revisions.txt

#hide buildlogs in tmp from remastersys
mv /usr/share/logs	/tmp

# #start the remastersys job
# remastersys dist
# 
# mv /home/remastersys/remastersys/custom.iso /home/remastersys/remastersys/custom-full.iso
# 
# 
# 
# #Redirect these utilitues to /bin/true during the live CD Build process. They aren't needed and cause package installs to complain
# RedirectFile /usr/sbin/grub-probe
# RedirectFile /sbin/initctl
# RedirectFile /usr/sbin/invoke-rc.d
# 
# #This will remove my abilities to build packages from the ISO, but should make it a bit smaller
# REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dev$"  | grep -v python-dbus-dev | grep -v dpkg-dev)
# 
# apt-get purge $REMOVEDEVPGKS -y --force-yes | tee /tmp/logs/package_operations/removes.txt
# 
# 
# REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dev:"  | grep -v python-dbus-dev | grep -v dpkg-dev)
# apt-get purge $REMOVEDEVPGKS -y --force-yes | tee -a /tmp/logs/package_operations/removes.txt
# 
# 
# REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dbg$"  | grep -v python-dbus-dev | grep -v dpkg-dev)
# apt-get purge $REMOVEDEVPGKS -y --force-yes | tee -a /tmp/logs/package_operations/removes.txt
# 
# REMOVEDEVPGKS=$(dpkg --get-selections | awk '{print $1}' | grep "\-dbg:"  | grep -v python-dbus-dev | grep -v dpkg-dev)
# apt-get purge $REMOVEDEVPGKS -y --force-yes | tee -a /tmp/logs/package_operations/removes.txt
# 
# REMOVEDEVPGKS="texlive-base ubuntu-docs gnome-user-guide cmake libgl1-mesa-dri-dbg libglib2.0-doc valgrind cmake-rbos smbclient freepats libc6-dbg doxygen git subversion bzr mercurial checkinstall texinfo"
# apt-get purge $REMOVEDEVPGKS -y --force-yes | tee -a /tmp/logs/package_operations/removes.txt
# 
# 
# apt-get autoremove -y --force-yes >> /tmp/logs/package_operations/removes.txt
# 
# #Reset the utilites back to the way they are supposed to be.
# RevertFile /usr/sbin/grub-probe
# RevertFile /sbin/initctl
# RevertFile /usr/sbin/invoke-rc.d

# #Reduce binary sizes
# echo "Reducing binary file sizes"
# find /opt/bin /opt/lib /opt/sbin | while read FILE
# do
#   strip $FILE 2>/dev/null
# done

#clean more apt stuff
apt-get clean
rm -rf /var/cache/apt-xapian-index/*
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/dlocate/*
#start the remastersys job
remastersys dist

#move logs back
mv /tmp/logs /usr/share

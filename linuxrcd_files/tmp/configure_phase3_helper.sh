#! /bin/bash
#    Copyright (c) 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017 nerdopolis (or n3rdopolis) <bluescreen_avenger@verzion.net>
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

#Require root privlages
if [[ $UID != 0 ]]
then
  echo "Must be run as root."
  exit
fi

#This file is used by checkinstall for creating the lrcd-lrcd package that has all of the installed SVN files

#Copy select files into place, that are suitable for distribution.
mkdir -p /usr/bin
cp -a /usr/import/usr/bin/* /usr/bin

#mkdir -p /usr/libexec
#cp -a /usr/import/usr/libexec/* /usr/libexec

mkdir -p /usr/share/
cp -a /usr/import/usr/share/* /usr/share

mkdir -p /etc/skel/.config
cp -a /usr/import/etc/skel/* /etc/skel

mkdir -p /lib
cp -a /usr/import/lib/* /lib

if [[ $DEBIAN_DISTRO == Debian ]]
then
  cp /usr/share/icons/oxygen/128x128/apps/system-diagnosis.png /usr/share/plymouth/debian-logo.png
  cp -a /lib/plymouth/themes/linuxrcd-text/ /usr/share/plymouth/themes
  echo FRAMEBUFFER=y >> /etc/initramfs-tools/conf.d/splash
fi


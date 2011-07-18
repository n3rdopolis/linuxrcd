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

#install aptitude
echo Y | apt-get install aptitude 

#install utilites that will help the rebuild of packages
aptitude install binutils devscripts bzr build-essential fakeroot debian-builder  -y --without-recommends

#make the folder that the source files will be downloaded and built
mkdir /builddir



cd builddir

#build the packages using the packagebuild script.


#Prepare the folder for being a local repo
cd /usr/packageoutput
dpkg-scanpackages . /dev/null | gzip -c9 > Packages.gz


#unmount the procfs from the chrooted system
umount proc



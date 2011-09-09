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

#Capture the list of all the default installed packages
dpkg --get-selections > /usr/packages_in_minimal

#install the CD's packages here

#capture the list of all installed packages. They are the ones that will be built.
dpkg --get-selections | grep -v deinstall | awk '{print $1}' > /usr/packages_to_build

#Put the contents of /usr into /usr/LinuxRCD-Recovery-Tools-And-Data as packages that are being built will have ALL references to /usr changed to /usr/LinuxRCD-Recovery-Tools-And-Data
ln -s /usr /usr/LinuxRCD-Recovery-Tools-And-Data


#Capture the list of all the default installed packages
dpkg --set-selections < /usr/packages_in_minimal

#install utilites that will help the rebuild of packages
aptitude install binutils devscripts bzr build-essential fakeroot debian-builder  -y --without-recommends

#Capture the list of all the installed packages for building
dpkg --get-selections > /usr/packages_for_building

#change into the packagebuild folder
cd /usr/packagebuild

#build the packages using the packagebuild script.
cat /usr/packages_to_build | while read PACKAGE
do
packagebuild $PACKAGE
done

#Prepare the folder for being a local repo
cd /usr/packageoutput
dpkg-scanpackages . /dev/null | gzip -c9 > Packages.gz


#unmount the procfs from the chrooted system
umount proc



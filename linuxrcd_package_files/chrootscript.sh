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



#install aptitude and locales and a language pack 
echo Y | apt-get install aptitude locales language-pack-en 

#Capture the list of all the default installed packages
dpkg --get-selections > /usr/packages_in_minimal

#install the CD's packages here TODO


#capture the list of all installed packages. They are the ones that will be built.
dpkg --get-selections | grep -v deinstall | awk '{print $1}' > /usr/packages_to_build

#Capture the list of all the default installed packages
dpkg --set-selections < /usr/packages_in_minimal

#revert to minimal install
echo y | apt-get -u dselect-upgrade

#install utilites that will help the rebuild of packages
aptitude install binutils devscripts bzr build-essential fakeroot debian-builder  -y --without-recommends

#Capture the list of all the installed packages for building
dpkg --get-selections > /usr/packages_for_building


#make /usr and /usr/local the same thing
cp -R /usr/local/* /usr/
mount --bind /usr/ /usr/local

#Put the contents of /usr into /LinuxRCD-Recovery-Tools-And-Data as packages that are being built will have ALL references to /usr changed to /LinuxRCD-Recovery-Tools-And-Data and will be looking for the files here
mount --rbind /usr /LinuxRCD-Recovery-Tools-And-Data





#get the number of packages to build
numberofpackages=$(cat /usr/packages_to_build | grep -c ^)

#change into the /usr/share/debhelper folder
cd /usr/share/debhelper

#change into the usr folder
#Change all references to /usr to /LinuxRCD-Recovery-Tools-And-Data
find . -name "*" |while read FILE
do
#sed -i 's/usr/LinuxRCD-Recovery-Tools-And-Data/g' $FILE  
sed -i 's/\/usr\//USR_FOLDER_NAME_WITH_DUAL_SLASHES/g' $FILE
sed -i 's/\/usr/USR_FOLDER_NAME_WITH_START_SLASH/g' $FILE
sed -i 's/usr\//USR_FOLDER_NAME_WITH_END_SLASH/g' $FILE
sed -i 's/\<usr\>/USR_FOLDER_NAME_ISOLATED/g' $FILE

sed -i 's/USR_FOLDER_NAME_WITH_DUAL_SLASHES/\/LinuxRCD-Recovery-Tools-And-Data\//g' $FILE
sed -i 's/USR_FOLDER_NAME_WITH_START_SLASH/\/LinuxRCD-Recovery-Tools-And-Data/g' $FILE
sed -i 's/USR_FOLDER_NAME_WITH_END_SLASH/LinuxRCD-Recovery-Tools-And-Data\//g' $FILE
sed -i 's/USR_FOLDER_NAME_ISOLATED/LinuxRCD-Recovery-Tools-And-Data/g' $FILE
done

find . -name usr | while read FILEPATH
do
#FILEPATH=$(readlink -f $FILEPATH) 
oldfilepath=$(echo $FILEPATH | rev | cut -f2- -d '/' | rev)
newfilepath=$(echo $oldfilepath |sed 's/usr/LinuxRCD-Recovery-Tools-And-Data/g')
filename=$(echo $FILEPATH | rev | awk -F / '{print $1}' | rev)
mkdir -p $newfilepath/LinuxRCD-Recovery-Tools-And-Data
cp -R $oldfilepath/usr/* $newfilepath/LinuxRCD-Recovery-Tools-And-Data
done

#change into the packagebuild folder
cd /usr/packagebuild

packagenumber=1
failedpackages=0
successfulpackages=0
#build the packages using the packagebuild script.
while read PACKAGE
do
echo "Building package "$PACKAGE": "$packagenumber" of "$numberofpackages""
#build the package
packagebuild "$PACKAGE" &> "$PACKAGE".log 
buildstatus=$?

if [ "$buildstatus" -eq 0 ]
then
echo "Build of "$PACKAGE" Successful"
successfulpackages=$(( $successfulpackages+1 ))
else
echo "build of "$PACKAGE" Failed"
failedpackages=$(( $failedpackages+1 ))
fi

packagenumber=$(( $packagenumber+1 ))
done < <(cat /usr/packages_to_build)

echo "$successfulpackages packages where built, $failedpackages failed to build"



#Prepare the folder for being a local repo
cd /usr/packageoutput
dpkg-scanpackages . /dev/null | gzip -c9 > Packages.gz




#unmount the procfs from the chrooted system
umount proc

#unmount the /usr/local bind mount
umount /usr/local
#unmount the /usr bind mount
umount /usr/LinuxRCD-Recovery-Tools-And-Data

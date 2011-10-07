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


export PATH="$PATH:/builders"

#mount the procfs
mount -t proc none /proc
#mount sysfs
mount -t sysfs none /sys
#mount /dev/pts
mount -t devpts none /dev/pts

#create a user that will run debuild
useradd builder -M -d "/usr/packagebuild"


#update the apt cache
apt-get update



#install aptitude and locales and a language pack 
echo Y | apt-get install aptitude locales language-pack-en 

#Capture the list of all the default installed packages
dpkg --get-selections > /usr/packages_in_minimal

# TODO uncomment this when builds work
# #LANGUAGEPACKLINE add language packs here, anywhere between install and the --without-recommends
# aptitude install language-pack-en --without-recommends -y

# #Install the list of packages that does not require recommended depends
# cat /tmp/LinuxRCDPackagesList-norecommends | while read PACKAGELINE
# do
# yes Y | aptitude install "$PACKAGELINE" -y --without-recommends
# done
# 
# #Install the list of packages that does  require recommended depends
# cat /tmp/LinuxRCDPackagesList-norecommends | while read PACKAGELINE
# do
# yes Y | aptitude install "$PACKAGELINE" -y 
# done
# TODO END OF WHAT SHOULD BE UNCOMMENTED

#capture the list of all installed packages. They are the ones that will be built.
dpkg --get-selections | grep -v deinstall | awk '{print $1}' > /usr/packages_to_build


#install utilites that will help the rebuild of packages
aptitude install binutils devscripts bzr build-essential fakeroot debian-builder  -y --without-recommends



#change into the build folder
cd "/usr/packagebuild"

#predownload the source and dependancies for all packages.
while read PACKAGE
do
#download the build dependancies and the source for the packages
sourceget "$PACKAGE"
done < <(cat /usr/packages_to_build)

#delete the temporary packages
apt-get clean

#get the number of packages to build
numberofpackages=$(cat /usr/packages_to_build | grep -c ^)


#modify the references to usr 
/builders/sourceedit / SYSTEMROOT


#make /usr and /usr/local the same thing
cp -R /usr/local/* /usr/
mount --rbind /usr/ /usr/local

#Put the contents of /usr into /LinuxRCDRecoveryToolsAndData as packages that are being built will have ALL references to /usr changed to /LinuxRCDRecoveryToolsAndData and will be looking for the files here
mount --rbind /usr /LinuxRCDRecoveryToolsAndData


#change into the packagebuild folder
cd "/usr/packagebuild"

#allow the build user to write to the build dir
chown builder:builder "/usr/packagebuild"
chmod -R 777          "/usr/packagebuild"

#allow the build user to write to the output dir
chown builder:builder "/usr/packageoutput"
chmod -R 777          "/usr/packageoutput"


#swap all /usr references in the environment to the linuxrcd folder
while read VAR
do
VARSET="$(echo "$VAR" | sed 's/usr/LinuxRCDRecoveryToolsAndData/g' )"
export "$VARSET"
done < <(env)
#build the packages

#Set variables that will be used for the counters
packagenumber=1
failedpackages=0
successfulpackages=0
#build the packages using the packagebuild script.
while read PACKAGE
do
echo "Building package "$PACKAGE": "$packagenumber" of "$numberofpackages"" | tee -a "/usr/packagebuild/builtpackages.log"
#build the package
su  builder -c "/builders/packagebuild "$PACKAGE"" 2>&1 | tee "$PACKAGE".log 
buildstatus=1
buildstatus="$(cat "/tmp/$PACKAGE.status")"

if [[  -n $buildstatus ]]
then

if [[ "$buildstatus" == 0 ]]
then 
echo "Build of "$PACKAGE" Successful"        | tee -a builtpackages.log
successfulpackages=$(( $successfulpackages+1 )) | tee -a builtpackages.log
else
echo "build of "$PACKAGE" Failed with error code $buildstatus" | tee -a builtpackages.log
failedpackages=$(( $failedpackages+1 ))
fi
else

echo "build of "$PACKAGE" was stopped." | tee -a builtpackages.log
failedpackages=$(( $failedpackages+1 ))
fi

echo "waiting 3 seconds to build next package"
sleep 3
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
umount /usr/LinuxRCDRecoveryToolsAndData

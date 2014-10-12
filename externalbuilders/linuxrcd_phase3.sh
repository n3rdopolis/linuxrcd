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

function linuxrcdedit () 
{
  export OriginalText=$1
  export TargetText=$2

  #Change all references to /$OriginalText to /$TargetText in the folder containg the LiveCD system
  find ""$BUILDLOCATION"/build/$BUILDARCH/workdir" -type f   -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/tmp/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/bin/recoverylauncher" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/RCDbin/recoverychrootscript" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/launchers/Apps" | sort -r | while read FILE
  do
    echo "editing file $FILE"
    #replace all instances of $OriginalText with the new folder name only if its not near a-z A-Z or 0-9. Thanks to @ofnuts on Ubuntu Fourms for helping me with the sed expression
    sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g" "$FILE" > "$FILE.tmp"
    cat "$FILE.tmp" > "$FILE"
    rm "$FILE.tmp"
  done

  #change all symbolic links that point to $OriginalText to point to $TargetText
  find ""$BUILDLOCATION"/build/$BUILDARCH/workdir" -type l   -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/tmp/*" | sort -r  |while read FILE
  do
    echo "relinking $FILE"
    newlink=$(readlink $FILE | sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g")
    ln -s -f "$newlink" "$FILE"
  done

  #find all items contianing $OriginalText in the name
  find ""$BUILDLOCATION"/build/$BUILDARCH/workdir"  -type d  -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/$BUILDARCH/workdir/tmp/*" | sort -r | while read FILEPATH
  do
    cd "$FILEPATH"
    rename -v "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g" * 2> /dev/null
  done
}

function RenameFiles() 
{
  linuxrcdedit usr RCD
  linuxrcdedit lib LYB
  linuxrcdedit lib64 LYB64
  #fix for Xorg, it uses wildcards.
  find "$BUILDLOCATION"/build/$BUILDARCH/workdir/RCD/LYB/xorg -name "lib*"   | while read FILEPATH
  do
    echo "Renaming $FILEPATH"
    rename "s/lib/\1LYB\2/g" "$FILEPATH"
  done


  #fix for NetworkManager, it uses wildcards.
  find "$BUILDLOCATION"/build/$BUILDARCH/workdir/RCD/LYB/NetworkManager -name "lib*"   | while read FILEPATH
  do
    echo "Renaming $FILEPATH"
    rename "s/lib/\1LYB\2/g" "$FILEPATH"
  done

  #Do this for X
  ln -s -f /var/LYB "$BUILDLOCATION"/build/$BUILDARCH/workdir/var/lib

  #delete the usr folder in the Live CD
  rm -rf "$BUILDLOCATION"/build/$BUILDARCH/workdir/usr

  #Do this for OS prober as it works with a normal system with lib. not LYB
  sed -i 's/LYB/lib/g' "$BUILDLOCATION"/build/$BUILDARCH/workdir/RCD/LYB/os-probes/mounted/90linux-distro

  #Do this for the main library interpreter, so that it does not use the target system's ld.so.cache
  sed -i 's@/ld.so.cache@/LD.SO.CACHE@g' "$BUILDLOCATION"/build/$BUILDARCH/workdir/LYB/ld-linux*
  mv "$BUILDLOCATION"/etc/ld.so.cache "$BUILDLOCATION"/build/$BUILDARCH/workdir/etc/LD.SO.CACHE


}

echo "PHASE 3"  
SCRIPTFILEPATH=$(readlink -f "$0")
SCRIPTFOLDERPATH=$(dirname "$SCRIPTFILEPATH")

HOMELOCATION=~
unset HOME

if [[ -z $BUILDARCH || -z $BUILDLOCATION || $UID != 0 ]]
then
  echo "BUILDARCH variable not set, or BUILDLOCATION not set, or not run as root. This external build script should be called by the main build script."
  exit
fi

#create a folder for the media mountpoints in the media folder
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/phase_1
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/phase_2
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/phase_3
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/srcbuild/buildoutput
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/buildoutput
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/workdir
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/archives
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/remastersys
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/vartmp

#Clean up Phase 3 data.
rm -rf "$BUILDLOCATION"/build/$BUILDARCH/phase_3/*

#Copy phase3 from phase2, and bind mount phase3 at the workdir
echo "Duplicating Phase 2 for usage in Phase 3. This may take some time..."
cp --reflink=auto -a "$BUILDLOCATION"/build/$BUILDARCH/phase_2/. "$BUILDLOCATION"/build/$BUILDARCH/phase_3
mount --rbind "$BUILDLOCATION"/build/$BUILDARCH/phase_3 "$BUILDLOCATION"/build/$BUILDARCH/workdir

#mounting critical fses on chrooted fs with bind 
mount --rbind /dev "$BUILDLOCATION"/build/$BUILDARCH/workdir/dev/
mount --rbind /proc "$BUILDLOCATION"/build/$BUILDARCH/workdir/proc/
mount --rbind /sys "$BUILDLOCATION"/build/$BUILDARCH/workdir/sys/

#Mount in the folder with previously built debs
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/workdir/srcbuild/buildoutput
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/workdir/home/remastersys
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/workdir/var/tmp
mount --rbind "$BUILDLOCATION"/build/$BUILDARCH/srcbuild "$BUILDLOCATION"/build/$BUILDARCH/workdir/srcbuild
mount --rbind "$BUILDLOCATION"/build/$BUILDARCH/buildoutput "$BUILDLOCATION"/build/$BUILDARCH/workdir/srcbuild/buildoutput
mount --rbind  "$BUILDLOCATION"/build/$BUILDARCH/remastersys "$BUILDLOCATION"/build/$BUILDARCH/workdir/home/remastersys
mount --rbind  "$BUILDLOCATION"/build/$BUILDARCH/vartmp "$BUILDLOCATION"/build/$BUILDARCH/workdir/var/tmp

#copy the files to where they belong
rsync "$BUILDLOCATION"/build/$BUILDARCH/importdata/* -Cr "$BUILDLOCATION"/build/$BUILDARCH/workdir/

#Handle /usr/import for the creation of the deb file that contains this systems files
mkdir -p "$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/import
rsync "$BUILDLOCATION"/build/$BUILDARCH/importdata/* -Cr "$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/import
rm -rf "$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/import/usr/import

#delete the temp folder
rm -rf "$BUILDLOCATION"/build/$BUILDARCH/workdir/temp/


#Configure the Live system########################################
if [[ $BUILDARCH == i386 ]]
then
  linux32 chroot "$BUILDLOCATION"/build/$BUILDARCH/workdir /tmp/configure_phase3.sh
else
  chroot "$BUILDLOCATION"/build/$BUILDARCH/workdir /tmp/configure_phase3.sh
fi


#Create a date string for unique log folder names
ENDDATE=$(date +"%Y-%m-%d %H-%M-%S")

#Create a folder for the log files with the date string
mkdir -p ""$BUILDLOCATION"/logs/$ENDDATE $BUILDARCH"

#Export the log files to the location
cp -a ""$BUILDLOCATION"/build/$BUILDARCH/phase_1/usr/share/logs/"* ""$BUILDLOCATION"/logs/$ENDDATE $BUILDARCH"
cp -a ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/share/logs/"* ""$BUILDLOCATION"/logs/$ENDDATE $BUILDARCH"
rm ""$BUILDLOCATION"/logs/latest"
ln -s ""$BUILDLOCATION"/logs/$ENDDATE $BUILDARCH" ""$BUILDLOCATION"/logs/latest"
cp -a ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/share/build_core_revisions.txt" ""$BUILDLOCATION"/logs/$ENDDATE $BUILDARCH" 
cp -a ""$BUILDLOCATION"/build/$BUILDARCH/workdir/usr/share/build_core_revisions.txt" ""$HOMELOCATION"/LinuxRCD_Revisions_$BUILDARCH.txt" 
if [[ ! -f "$BUILDLOCATION"/build/$BUILDARCH/workdir/home/remastersys/remastersys/custom.iso ]]
then  
  ISOFAILED=1
else
    mv "$BUILDLOCATION"/build/$BUILDARCH/remastersys/remastersys/custom.iso "$HOMELOCATION"/LinuxRCD_$BUILDARCH.iso
fi 


#allow the user to actually read the iso   
chown $SUDO_USER "$HOMELOCATION"/LinuxRCD*.iso "$HOMELOCATION"/LinuxRCD*.txt
chgrp $SUDO_USER "$HOMELOCATION"/LinuxRCD*.iso "$HOMELOCATION"/LinuxRCD*.txt
chmod 777 "$HOMELOCATION"/LinuxRCD*.iso "$HOMELOCATION"/LinuxRCD*.txt

#If the live cd did  build then tell user   
if [[ $ISOFAILED != 1  ]];
then  
  echo "Live CD image build was successful."
else
  echo "The Live CD did not succesfuly build. The script could have been modified, or a network connection could have failed to one of the servers preventing the installation packages for Ubuntu, or Remstersys from installing. There could also be a problem with the selected architecture for the build, such as an incompatible kernel or CPU, or a misconfigured qemu-system bin_fmt"
fi


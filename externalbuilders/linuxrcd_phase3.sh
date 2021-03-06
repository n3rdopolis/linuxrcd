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

function linuxrcdedit () 
{
  export OriginalText=$1
  export TargetText=$2

  #Change all references to /$OriginalText to /$TargetText in the folder containg the LiveCD system
  find ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir" -type f   -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/bin/recoverylauncher" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/RCDbin/recoverychrootscript" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/launchers/Apps" | sort -r | while read FILE
  do
    echo "editing file $FILE"
    #replace all instances of $OriginalText with the new folder name only if its not near a-z A-Z or 0-9. Thanks to @ofnuts on Ubuntu Fourms for helping me with the sed expression
    sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g" "$FILE" > "$FILE.tmp"
    cat "$FILE.tmp" > "$FILE"
    rm "$FILE.tmp"
  done

  #change all symbolic links that point to $OriginalText to point to $TargetText
  find ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir" -type l   -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/*" | sort -r  |while read FILE
  do
    echo "relinking $FILE"
    newlink=$(readlink $FILE | sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g")
    ln -s -f "$newlink" "$FILE"
  done

  #find all items contianing $OriginalText in the name
  find ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir"  -type d  -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/proc/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/sys/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/dev/*" -not -path ""$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/*" | sort -r | while read FILEPATH
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
  find "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/RCD/LYB/xorg -name "lib*"   | while read FILEPATH
  do
    echo "Renaming $FILEPATH"
    rename "s/lib/\1LYB\2/g" "$FILEPATH"
  done


  #fix for NetworkManager, it uses wildcards.
  find "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/RCD/LYB/NetworkManager -name "lib*"   | while read FILEPATH
  do
    echo "Renaming $FILEPATH"
    rename "s/lib/\1LYB\2/g" "$FILEPATH"
  done

  #Do this for X
  ln -s -f /var/LYB "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/var/lib

  #delete the usr folder in the Live CD
  rm -rf "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr

  #Do this for OS prober as it works with a normal system with lib. not LYB
  sed -i 's/LYB/lib/g' "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/RCD/LYB/os-probes/mounted/90linux-distro

  #Do this for the main library interpreter, so that it does not use the target system's ld.so.cache
  sed -i 's@/ld.so.cache@/LD.SO.CACHE@g' "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/LYB/ld-linux*
  mv "$BUILDLOCATION"/etc/ld.so.cache "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/etc/LD.SO.CACHE


}

echo "PHASE 3"  
SCRIPTFILEPATH=$(readlink -f "$0")
SCRIPTFOLDERPATH=$(dirname "$SCRIPTFILEPATH")

unset HOME

if [[ -z "$BUILDARCH" || -z $BUILDLOCATION || $UID != 0 ]]
then
  echo "BUILDARCH variable not set, or BUILDLOCATION not set, or not run as root. This external build script should be called by the main build script."
  exit
fi

#Ensure that all the mountpoints in the namespace are private, and won't be shared to the main system
mount --make-rprivate /

#Union mount phase2 and phase3
if [[ -d "$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/phase_3 ]]
then
  mount -t overlay overlay -o lowerdir="$BUILDLOCATION"/build/"$BUILDARCH"/$PHASE2_PATHNAME,upperdir="$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/phase_3,workdir="$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/unionwork "$BUILDLOCATION"/build/"$BUILDARCH"/workdir
else
  mount -t overlay overlay -o lowerdir="$BUILDLOCATION"/build/"$BUILDARCH"/$PHASE2_PATHNAME,upperdir="$BUILDLOCATION"/build/"$BUILDARCH"/phase_3,workdir="$BUILDLOCATION"/build/"$BUILDARCH"/unionwork "$BUILDLOCATION"/build/"$BUILDARCH"/workdir
fi

#mounting critical fses on chrooted fs with bind 
mount --rbind "$BUILDLOCATION"/build/"$BUILDARCH"/minidev/ "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/dev
mount --rbind /proc "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/proc
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/run/shm
mount --bind "$BUILDLOCATION"/build/"$BUILDARCH"/minidev/shm "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/run/shm

#Bind mount shared directories
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/srcbuild/buildoutput
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/home/remastersys
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/var/tmp
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/buildlogs
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/srcbuild_overlay

#Hide /proc/modules as some debian packages call lsmod during install, which could lead to different results
mount --bind /dev/null "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/proc/modules

#if there is enough ram, use the ramdisk as the upperdir, if not, use a path on the same filesystem as the upperdir
if [[ -d "$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/srcbuild_overlay ]]
then
  mount -t overlay overlay -o  lowerdir="$BUILDLOCATION"/build/"$BUILDARCH"/srcbuild,upperdir="$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/srcbuild_overlay,workdir="$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/unionwork_srcbuild "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/srcbuild/
    mount --bind "$BUILDLOCATION"/build/"$BUILDARCH"/ramdisk/srcbuild_overlay "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/srcbuild_overlay
else
  mount -t overlay overlay -o  lowerdir="$BUILDLOCATION"/build/"$BUILDARCH"/srcbuild,upperdir="$BUILDLOCATION"/build/"$BUILDARCH"/srcbuild_overlay,workdir="$BUILDLOCATION"/build/"$BUILDARCH"/unionwork_srcbuild "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/srcbuild/
  mount --bind "$BUILDLOCATION"/build/"$BUILDARCH"/srcbuild_overlay "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/tmp/srcbuild_overlay
fi

mount --bind "$BUILDLOCATION"/build/"$BUILDARCH"/buildoutput "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/srcbuild/buildoutput
mount --bind  "$BUILDLOCATION"/build/"$BUILDARCH"/remastersys "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/home/remastersys
mount --bind  "$BUILDLOCATION"/build/"$BUILDARCH"/vartmp "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/var/tmp
mount --bind "$BUILDLOCATION"/build/"$BUILDARCH"/buildlogs "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/buildlogs

#copy the files to where they belong
rsync "$BUILDLOCATION"/build/"$BUILDARCH"/importdata/* -CKr "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/

#Handle /usr/import for the creation of the deb file that contains this systems files
mkdir -p "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/import
rsync "$BUILDLOCATION"/build/"$BUILDARCH"/importdata/* -CKr "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/import
rm -rf "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/usr/import/usr/import

#delete the temp folder
rm -rf "$BUILDLOCATION"/build/"$BUILDARCH"/workdir/temp/


#Configure the Live system########################################
TARGETBITSIZE=$(chroot "$BUILDLOCATION"/build/"$BUILDARCH"/workdir /usr/bin/getconf LONG_BIT)
if [[ $TARGETBITSIZE == 32 ]]
then
  linux32 chroot "$BUILDLOCATION"/build/"$BUILDARCH"/workdir /tmp/configure_phase3.sh
elif [[ $TARGETBITSIZE == 64 ]]
then
  linux64 chroot "$BUILDLOCATION"/build/"$BUILDARCH"/workdir /tmp/configure_phase3.sh
else
  echo "chroot execution failed. Please ensure your processor can handle the "$BUILDARCH" architecture, or that the target system isn't corrupt."
fi


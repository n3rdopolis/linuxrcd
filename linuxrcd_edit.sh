#!  /bin/bash
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


export OriginalText=$1
export TargetText=$2

#Change all references to /$OriginalText to /$TargetText in the folder containg the LiveCD system
find "/media/LiveDiskCreAtionChrootFolDer" -type f   -not -path "/media/LiveDiskCreAtionChrootFolDer/proc/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/sys/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/dev/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/tmp/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/usr/bin/recoverylauncher" | sort -r | while read FILE
do
echo "editing file $FILE"
#replace all instances of $OriginalText with the new folder name only if its not near a-z A-Z or 0-9. Thanks to @ofnuts on Ubuntu Fourms for helping me with the sed expression
sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g" "$FILE" > "$FILE.tmp"
cat "$FILE.tmp" > "$FILE"
rm "$FILE.tmp"
done

#change all symbolic links that point to $OriginalText to point to $TargetText
find "/media/LiveDiskCreAtionChrootFolDer" -type l   -not -path "/media/LiveDiskCreAtionChrootFolDer/proc/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/sys/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/dev/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/tmp/*" | sort -r  |while read FILE
do
echo "relinking $FILE"
newlink=$(readlink $FILE | sed -re "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g")
ln -s -f "$newlink" "$FILE"
done

#find all items contianing $OriginalText in the name
find "/media/LiveDiskCreAtionChrootFolDer" -name "*$OriginalText*"  -not -path "/media/LiveDiskCreAtionChrootFolDer/proc/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/sys/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/dev/*" -not -path "/media/LiveDiskCreAtionChrootFolDer/tmp/*" | sort -r | while read FILEPATH
do
cd "$FILEPATH"
rename -v "s/(\W|^)$OriginalText(\W|$)/\1$TargetText\2/g" * 2> /dev/null
done
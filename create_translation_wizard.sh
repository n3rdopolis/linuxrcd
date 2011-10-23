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
 

#get the location of the directory that this script is in
folderlocation="$( dirname $(readlink -f "$0" ) )"
linuxrcdfolderlocaton="$(echo $folderlocation/linuxrcd_files)"

#program dialog is needed to prompt user
which dialog > /dev/null
dialoginstalled=$?
if [ $dialoginstalled = 1 ]
then
echo "package 'dialog' not installed. please install the package 'dialog' by using your package manager, as it is needed."
exit 1
fi

#files needed for the translation
mkdir "${HOME}/LiveDiskTranSlAtionCacheFolDer"


#introduce the translator to this script
echo "This is the translation wizard for LinuxRCD. It scans the files for translatable strings and thier descriptions so that you can add a language translation for LinuxRCD."
echo "This script must be in the root of the LinuxRCD build script folder. (you should see a folder called linuxrcd_files in the same folder as this script)"
echo "This script will make changes to the following folders and files.
File:              ${HOME}/LiveDiskTranSlAtionCacheFolDer/TRANSLATION_DATA
Folder:            $linuxrcdfolderlocaton

MAKE SURE this script will not overwrite anything before pressing enter to continue!!!!..."
read a
echo "searching for translatable files in  $linuxrcdfolderlocaton"

#if there is no linuxrcd_files folder in the same folder as this script, exit.
if [  ! -d "$linuxrcdfolderlocaton" ]
then 
echo "No 'linuxrcd_files' folder found in the same folder as this script. exiting..."
exit 1
fi

#ask the name of the language the user is making
echo "Enter the name of the language you are making a translation for, and hit enter" 
languagename=$(dialog  --no-cancel --stdout --inputbox "Enter Language Name" 20 999 )
#if no language was entered, exit
if [ -z $languagename ]
then
echo "no language entered. exiting..."
exit 1 
fi
#make the language folder.
mkdir -p "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename"
#make the language file for the universal string. There is only one universal string in LinuxRCD, and thats the language name
echo "$languagename~~~~~~~~~~~" > "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/@%@Language_Name@%@"

#find all files in the linux_rcd files that have the string in them to show themselves as translatable.
find "$linuxrcdfolderlocaton" \( -name .svn \) -prune -o -print | while read FILE
do
#find if it is translatable by counting the number of the @@@TRANSLATABLE_FILE@@@ string in the file
if [ `grep -c "@@@TRANSLATABLE_FILE@@@" "$FILE"` -eq 0 ]
then
#if none, don't do anything, but it seems that "if" needs to run a command here, otherwise it returns an error...
sleep 0
else


#grab the file name of the file being translated
filename="$(echo "$FILE" | rev | awk -F / '{print $1}' | rev )"
#get the linuxrcd relitive path location.
foldername="$(echo "$FILE" | awk -F "$filename" '{print $1}' | awk -F "$linuxrcdfolderlocaton/" '{print $2}' )" 

#search the file for if the file name is translatable
cat  "$FILE" | grep @@@TRANSLATABLE_FILENAME@@@ | while read LINE
do
#get the name of the translation string In file string translation loop, its the file name
translationname="$( echo $filename )"
#get the translation descrition in the file, to aid the translator
translationdescription="$( echo $LINE | awk -F"~~~~~~~~~~~" '{ print $2 }' )"
#get the current contents of the translation
oldtranslationtext=$(cat "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/FILEFOLDERNAME" | awk -F"~~~~~~~~~~~" '{ print $1 }'   )
#prompt for the new translation, with the old translation in the line.
newtranslationtext="$(dialog  --no-cancel --stdout --inputbox "Translating LinuxRCD's $foldername$filename

translation description for string $translationname: $translationdescription" 20 999 "$oldtranslationtext" )"
#make the folder for the translation
mkdir -p "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/"
#create the translation file for the file name
echo "$newtranslationtext~~~~~~~~~~~" > "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/FILEFOLDERNAME"
done


#grab translatable strings from the file
cat  "$FILE" | grep @@@TRANSLATABLE_STRING@@@ | while read LINE
do
#get the name of the translation string. This is embeded in the file.
translationname="$( echo $LINE | awk -F"~~~~~~~~~~~" '{ print $2 }' )"
#get the translation description to aid the translator.
translationdescription="$( echo $LINE | awk -F"~~~~~~~~~~~" '{ print $3 }' )"
#get the internal translation options for the LinuxRCD build script
translationoptions="$( echo $LINE | awk -F"~~~~~~~~~~~" '{ print $4 }' )"
#get the current contents of the translation
oldtranslationtext=$(cat "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/TRANSLATION_DATA" | grep "$translationname"  | awk -F"~~~~~~~~~~~" '{ print $2 }' )
#prompt for the new translation, with the old translation in the line.
newtranslationtext="$(dialog  --no-cancel --stdout --inputbox "Translating LinuxRCD's $foldername$filename

translation description for string $translationname: $translationdescription" 20 999 "$oldtranslationtext" )"
#copy the current translation in a cached location, without the old translation for this string
cat "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/TRANSLATION_DATA" | grep -v "$translationname" > "${HOME}/LiveDiskTranSlAtionCacheFolDer/TRANSLATION_DATA"
#put the new translation in the cached file
echo "$translationname~~~~~~~~~~~$newtranslationtext~~~~~~~~~~~$translationoptions" >> "${HOME}/LiveDiskTranSlAtionCacheFolDer/TRANSLATION_DATA"
#create the folder for the new translation
mkdir -p "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/"

#move the edited cached file into the correct location so the new translation is applied
mv "${HOME}/LiveDiskTranSlAtionCacheFolDer/TRANSLATION_DATA" "$linuxrcdfolderlocaton/usr/share/linuxrcd/translations/$languagename/file_translations/$foldername$filename/TRANSLATION_DATA"
done

fi

done
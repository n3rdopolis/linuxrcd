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


#@@@TRANSLATABLE_FILE@@@

#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block dialog name%@~~~~~~~~~~~Title should just say "Grub Environment Block Recovery"~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block welcome@%@~~~~~~~~~~~Tell user that this will try to remove the Grub Environment Block~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block description@%@~~~~~~~~~~~Tell user that this will try to fix grub Invalad Environment Block and sometimes Out Of Disk errors~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block disclaimer@%@~~~~~~~~~~~Tell the user that if the environment block is successfuly deleted, and they still can't boot that they must have a disk issue, or older bios that can't see above 137GB, and they might have to create a small boot partition at the beginning of the drive, which is a non trival task, could be risky.~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block prompt@%@~~~~~~~~~~~Ask user if they want to try deleting the environment block~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block failed to remove file@%@~~~~~~~~~~~Say that the deletion of the environment block was tried, and not successful~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block success@%@~~~~~~~~~~~Say that the removal of the environment block was successful~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@Grub environment block file not found@%@~~~~~~~~~~~Say that the grub environemt block was already removed, and if the user is still having issues with GRUB then it might be a BIOS, or disk issue~~~~~~~~~~~DELIM_FOR_KDIALOG
cd /

kdialog --caption LinuxRCD --title "@%@Grub environment block dialog name%@" --yesno "@%@Grub environment block welcome@%@

@%@Grub environment block description@%@

@%@Grub environment block disclaimer@%@

@%@Grub environment block prompt@%@"
fixgrub=$?


if [[ $fixgrub -eq 0 ]]
then
#open up the x server reconfigure

if [ -f  /boot/grub/grubenv ]
then
mv  /boot/grub/grubenv /boot/grub/grubenv$(date +%s).bak

if [ -f  /boot/grub/grubenv ]
then
kdialog --caption LinuxRCD --title "@%@Grub environment block dialog name%@" --error "@%@Grub environment block failed to remove file@%@"
else
kdialog --caption LinuxRCD --title "@%@Grub environment block dialog name%@" --msgbox "@%@Grub environment block success@%@"
fi

else
kdialog --caption LinuxRCD --title "@%@Grub environment block dialog name%@" --msgbox "@%@Grub environment block file not found@%@"
fi



fi


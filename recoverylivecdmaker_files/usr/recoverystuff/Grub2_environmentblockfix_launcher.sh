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


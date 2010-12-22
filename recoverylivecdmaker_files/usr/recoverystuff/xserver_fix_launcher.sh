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

kdialog --caption LinuxRCD --yesno "@%@X server fixer greeting@%@" --title "@%@X server fixer dialog name@%@"

@%@X server fixer disclaimer@%@

@%@X server fixer prompt@%@
fixxserver=$?


if [[ $fixxserver -eq 0 ]]
then
#open up the x server reconfigure
lxterminal -e "dpkg-reconfigure xserver-xorg" &
fi

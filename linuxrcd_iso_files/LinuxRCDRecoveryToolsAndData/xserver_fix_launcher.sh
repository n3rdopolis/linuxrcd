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


#this scriipt attempts to give Ubuntu/Debain users a reconfigured X server in case if they messed up the xorg.conf. It only works on ubuntu/debian because of dpkg
#xorg.conf is also starting to become irrelevant, as KMS and autodetection are working on more systems

#@@@TRANSLATABLE_FILE@@@

#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@X server fixer dialog name@%@~~~~~~~~~~~Title should say "Fixing the X server"~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@X server fixer prompt@%@~~~~~~~~~~~Ask user if they want to continue~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@X server fixer disclaimer@%@~~~~~~~~~~~Tell user that depending on the system configuration, they might get a terminal window prompting for information, or a terminal window that appears for a short while, and that this only works on Debain like systems.~~~~~~~~~~~DELIM_FOR_KDIALOG
#@@@TRANSLATABLE_STRING@@@~~~~~~~~~~~@%@X server fixer greeting@%@~~~~~~~~~~~Tell user that a terminal window will be opened to allow them to fix the X server.~~~~~~~~~~~DELIM_FOR_KDIALOG


cd /

kdialog --caption LinuxRCD --title "@%@X server fixer dialog name@%@"  --yesno "@%@X server fixer greeting@%@

@%@X server fixer disclaimer@%@

@%@X server fixer prompt@%@"

fixxserver=$?


if [[ $fixxserver -eq 0 ]]
then
#open up the x server reconfigure
lxterminal -e "dpkg-reconfigure xserver-xorg" &
fi

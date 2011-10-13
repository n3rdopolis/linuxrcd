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

#swap all /usr references in the environment to the /RCD folder
while read VAR
do
VARSET="$(echo "$VAR" | sed 's/usr/RCD/g' )"
export "$VARSET"
done < <(/RCD/bin/env)

#start the remastersys job
remastersys backup
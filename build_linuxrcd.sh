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


ThIsScriPtSFiLeLoCaTion=$(readlink -f "$0")
ThIsScriPtSFolDerLoCaTion=$(dirname "$ThIsScriPtSFiLeLoCaTion")

echo "enter desired CPU arch to build the live CD. (32 bit systems can not build 64 bit systems)"
read CPU_ARCHITECTURE

echo "enter desired language"
read Language_Name




echo "
This will build LinuxRCD.

The following folders subfolders and files are cleared by this script:

   Folder:            /media/LiveDiskCreAtionChrootFolDer/            
   Folder:            /media/PackAgeCreAtionChrootFolDer/   
   Folder:            ${HOME}/LiveDiskCreAtionCacheFolDer/         
   Folder:            ${HOME}/PackAgeCreAtionCacheFolDer/
   Folder:            ${HOME}/LinuxRCDPackAgeS
   File:              ${HOME}/PackAgeCreAtionWasPVNotInStalled
   File:              ${HOME}/PackAgeCreAtionWasDeBootStrapNotInStalled
   File:              ${HOME}/LiveDiskCreAtionWasPVNotInStalled
   File:              ${HOME}/LiveDiskCreAtionWasDeBootStrapNotInStalled
   File:              ${HOME}/LinuxRCD_${Language_Name}_${CPU_ARCHITECTURE}.iso

Some GUI file managers call the ${HOME}/ folder just 'home'. consider this while checking for these files
"
read a




#was debootstrap installed before the script was first run? if not uninstall it to keep everything clean.
WasDeBootStrapNotInstalledBefore=$(cat LiveDiskCreAtionWasDeBootStrapNotInStalled)
if (( 1 == WasDeBootStrapNotInstalledBefore ));
then
apt-get purge debootstrap -y
fi

#was pv installed before the script was first run? if not uninstall it to keep everything clean.
WasPVNotInstalledBefore=$(cat LiveDiskCreAtionWasPVNotInStalled)
if (( 1 == WasPVNotInstalledBefore ));
then
apt-get purge pv -y
fi
#END PAST RUN CLEANUP##################

#ping google to test total network connectivity. Google is usally pingable
ping -c1 google.com > /dev/null
IsGoOgLeAcceSsaBle=$?
if [[ $IsGoOgLeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access Google. There is a high proberbility that your connection to the Internet is disconnected. (or in an extreemly rare case Google may be down) 
"
                     
fi

#detect if the Ubuntu Archive Site is reachable
ping -c1 archive.ubuntu.com > /dev/null
IsUbuNtUArcHiveSiTeAcceSsaBle=$?
if [[ $IsUbuNtUArcHiveSiTeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access the Ubuntu Archive site. Please test your connectivity to the Internet If you belive you are connected, the Ubuntu Archive Site may be down. The script needs Ubuntu's Archive website in order to succede. Exiting."
  exit 1                       
fi

#detect if the Remastersys Archive site is reachable
ping -c1 www.remastersys.com > /dev/null
IsReMastersYsArcHiveSiTeAcceSsaBle=$?
if [[ $IsReMastersYsArcHiveSiTeAcceSsaBle -ne 0 ]]
then               
  echo "Unable to access the Remastersys Archive site. Please test your connectivity to the Internet If you belive you are connected, the Remastersys Archive Site may be down. The script needs Remastersys' Archive Site in order to succede. Exiting." 
  exit 1                       
fi

#get the size of the users home file system. 
HomeFileSysTemFSFrEESpaCe=$(df ~ | awk '{print $4}' |  grep -v Av)
#if there is 5gb or less tell the user and quit. If not continue.
if [[ $HomeFileSysTemFSFrEESpaCe -le 4000000 ]]; then               
  echo "You have less then 4gb of free space on the partition that contains your home folder. Please free up some space." 
  echo "The script will now abort."
  echo "free space:"
  df ~ -h | awk '{print $4}' |  grep -v Av
  exit 1                       
fi


#detect if debootstrap is installed
DebootstrapStatus=$(dpkg-query -s debootstrap | grep "install ok installed" -c)

#detect if pv is installed
PVStatus=$(dpkg-query -s pv | grep "install ok installed" -c)

#Cache DeBootstraps Status to a file in case if this batch file gets intrupted
if (( 0==DebootstrapStatus ));
then
echo 1 > ~/LiveDiskCreAtionWasDeBootStrapNotInStalled
fi

#Cache pv Status to a file in case if this batch file gets intrupted
if (( 0==PVStatus ));
then
echo 1 > ~/LiveDiskCreAtionWasPVNotInStalled
fi

#install bootstrap if not installed
if (( 0==DebootstrapStatus ));
then
apt-get install debootstrap
fi

#installpv if not installed
if (( 0==PVStatus ));
then
apt-get install pv
fi

"$ThIsScriPtSFolDerLoCaTion"/linuxrcd_package_builder.sh $CPU_ARCHITECTURE  $Language_Name
"$ThIsScriPtSFolDerLoCaTion"/linuxrcd_iso_builder.sh     $CPU_ARCHITECTURE  $Language_Name



#uninstall debootstrap if it was uninstalled before
if (( 0==DebootstrapStatus ));
then
apt-get purge debootstrap -y
fi
rm ~/PackAgeCreAtionWasDeBootStrapNotInStalled

#uninstall pv if it was uninstalled before
if (( 0==PVStatus ));
then
apt-get purge pv -y
fi
rm ~/PackAgeCreAtionWasPVNotInStalled

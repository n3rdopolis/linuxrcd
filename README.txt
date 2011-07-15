To build, just run the included script. This script only works on Ubuntu/Debain (I think it would work on Debian) based systems. 

Problems:
  It has only been semi-thoroughly tested on Ubuntu.

  The host name setting does not work on all systems it seems.

  I have had some instances where Ubuntu's disk checker would come up when I reboot back into it.
As far as I can remember, most of these times, though I played with it a little more. the live is set to unmount 
the file system upon shutdown. 

  Its still in development, and may cause unknown breakage...

  Some packages might fail to install, due to runtime differences in the runtimes like kernel versions and init systems not working in chroot, and the AUFS union in /usr/share.

TODO:
  add more programs/scripts for recovery

  Document more things

  Fix the issues with data in /usr/share messing with package managers

  Find solutiion for packages that start Upstart/systemd jobs after starting, are going to fail in the chroot, and cause the package to report failure and bomb out the package manager. This needs a fix

How to use the ISO:
  burn it, (or put it in a VM), reboot, set the BIOS to boot from the CD if it does not already, 
  boot from the CD. Once it boots it brings up an easy to follow prompt to connect to your system. 
  

 

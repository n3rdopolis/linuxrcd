To build, just run the included script. This script only works on Ubuntu/Debain (I think it would work on Debian) based systems. 

Problems:
  It has only been semi-thoroughly tested on Ubuntu.

  The host name setting does not work on all systems it seems.

  I have had some instances where Ubuntu's disk checker would come up when I reboot back into it.
As far as I can remember, most of these times, though I played with it a little more. the live is set to unmount 
the file system upon shutdown. 

  Its still in development, and may cause unknown breakage...

  Some packages might fail to install when in chroot, due to runtime differences in the runtimes like kernel versions and init systems not working in chroot.

TODO:
  add more programs/scripts for recovery

  Document more things

  Upstart might be fixed as far as package managers starting jobs (might), but systemd is not yet.

  More testing

  Perhaps problems can occur with recovery programs that work directly with /usr instead of running from /usr. 

How to use the ISO:
  burn it, (or put it in a VM), reboot, set the BIOS to boot from the CD if it does not already, 
  boot from the CD. Once it boots it brings up an easy to follow prompt to connect to your system. 
  

 

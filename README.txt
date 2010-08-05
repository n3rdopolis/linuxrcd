To build, just run the included script. This script only works on Ubuntu/Debain (I think it would work on Debian) based systems. 

Problems:
  It has only been thoroughly tested on Ubuntu.

  It requires not slow hardware/CD writer right now because some files/libraries that are required for some of
  the imported programs to run, are only available for a set time limit, so they may fail.

  The host name setting does not work on all systems it seems.

  I have had some instances where Ubuntu's disk checker would come up when I reboot back into it.
As far as I can remember, most of these times, though I played with it a little more. the live is set to unmount 
the file system upon shutdown. 

  Its pre-alpha. its not mature, and may cause unknown breakage...

TODO:
  add more programs/scripts for recovery

  find a better solution then bind mounting in the libraries for the programs. It works OK for programs that don't
  write to /lib and /usr (like a user manager) but for ones that do require a new solution

How to use the ISO:
  burn it, (or put it in a VM), reboot, set the BIOS to boot from the CD if it does not already, 
  boot from the CD. Once it boots it brings up an easy to follow prompt to connect to your system. 
  

 

#! /bin/bash 

#swap all /usr references in the environment to the /RCD folder
while read VAR
do
VARSET="$(echo "$VAR" | sed 's/usr/RCD/g' )"
export "$VARSET"
done < <(/RCD/bin/env)

#start the remastersys job
remastersys backup
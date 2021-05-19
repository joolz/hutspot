#!/bin/bash

# run javap on all classes under target dirs to get method signatures

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

echo `date` >> /home/jal/Desktop/javaptargets.log

doJavaP() {
	echo "----- Have directory ${1}" >> /home/jal/Desktop/javaptargets.log
 	find ${1} -type f -name "*.class" -exec javap {} \; >> /home/jal/Desktop/javaptargets.log
}

# https://stackoverflow.com/questions/4321456/find-exec-a-shell-function-in-linux#4321522
export -f doJavaP

find . -type d -name target -exec bash -c 'doJavaP "$0"' {} \;

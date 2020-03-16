#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

for I in `grep "^Host " ~/.ssh/config | awk '{print $2}' | grep -v '*'`
do
	echo ----------------------------------------------------
	ssh -o "BatchMode=yes" $I "echo 2>&1"
	echo server $I returns $?
done

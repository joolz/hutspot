#!/bin/bash

source ~/bin/common.sh || exit 1

GAAR=$1

if [ -z "$GAAR" ]; then
	echo Usage $0 gaar-in-minuten
	exit 1
fi

START=`date`
echo "Started at ${START}"

for ((I = 1; I <= ${GAAR}; I++)); do
	sleep 1m
	echo -n "$I "
done

beep

END=`date`

zenity --info \
	--title="All done" \
	--text="It's now ${END}. ${GAAR} minutes have passed since ${START}"

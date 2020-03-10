#!/bin/bash

source ~/bin/common.sh || exit 1

GAAR=$1

if [ -z "$GAAR" ]; then
	echo Usage $0 gaar-in-minuten
	exit 1
fi

NOW=`date`
echo "Started at ${NOW}"

for ((I = 1; I <= ${GAAR}; I++)); do
	sleep 1m
	echo -n "$I "
done

beep
NOW=`date`
echo "Finished at ${NOW}"

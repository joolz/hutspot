#!/bin/bash

source ~/bin/common.sh || exit 1

GAAR=$1
MESSAGE=$2

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

zenity --info \
	--title="All done" \
	--text="${GAAR} minutes have passed. ${MESSAGE}"

beep

#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

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

MESSAGETEXT="${GAAR} minutes have passed. ${MESSAGE}"

beep

echo "${MESSAGETEXT}"

zenity --info \
	--title="It is finished." \
	--text="${MESSAGETEXT}"

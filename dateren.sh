#!/bin/bash

for FILE in *.txt
do
	NAME=${FILE%.*}
	YEAR="${NAME:0:4}"
	WEEK=`date --date="$NAME" +"%V"`
	NEWNAME=${YEAR}_week_${WEEK}.md
	
	read -r -p "Will rename $FILE to $NEWNAME Continue? [y/N] " response
	case "$response" in
		[yY])
					cp -v $FILE ${FILE}.bak
					mv -v ${FILE} ${NEWNAME}
					;;
			*)
					echo Skipping file $FILE
					;;
	esac
done

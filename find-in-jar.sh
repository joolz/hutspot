#!/bin/bash

LOGFILE=./findjar.log

if [ "$1" = "" ]; then
  echo usage $0, argument
  exit 1
fi

echo "==========================" >> $LOGFILE
echo ${DATEFORMATTED} >> $LOGFILE
echo "Find $1 in jarfiles" >> $LOGFILE
echo >> $LOGFILE

find . -name "*.jar" | while read -r FILE
do
	FOUND=`jar -tvf "$FILE" | grep "$1"`
  if [ "$FOUND" != "" ]; then
		echo $FILE >> $LOGFILE
	fi
done

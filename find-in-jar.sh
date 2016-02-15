#!/bin/bash

LOGFILE=./findjar.log

if [[ "$1" -eq "" ]]; then
  echo usage $0, argument
  exit 1
fi

echo "==========================" >> $LOGFILE
echo `date` >> $LOGFILE
echo "Find $1 in jarfiles" >> $LOGFILE
echo >> $LOGFILE

find . -name "*.jar" | while read -r FILE
do
  echo $FILE >> $LOGFILE
  jar -tvf "$FILE" | grep "$1" >> $LOGFILE
done

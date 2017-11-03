#!/bin/bash

FIXDIR=/home/jal/Desktop/liferay-hotfix-26180-6210/
SRCDIR=/opt/liferay/src/

# this is the cleaned up stackdump file. Delete all non-interesting
# line. From the remaining ones, only keep the class file + line
# number, in this format class.java:111

FILE=/home/jal/Desktop/checken.txt

while read LINE; do
	JAVA=`echo $LINE | cut -d : -f1`
	NR=`echo $LINE | cut -d : -f2`

	SRC=`find $SRCDIR -name $JAVA`
	FIX=`find $FIXDIR -name $JAVA`

	echo "Exception occured at $JAVA:$NR"
	read

	meld $SRC $FIX
done < "$FILE"


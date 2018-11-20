#!/bin/bash

# cd ~/tmp/alles

FILES=rebel.xml

for FILE in ${FILES//,/ }
do
	echo "-------------------------------------"
	echo Find file $FILE
	find . -type f -name $FILE | grep -v .hg
done

DIRECTORIES=target,bin,liferay

for DIRECTORY in ${DIRECTORIES//,/ }
do
	echo "-------------------------------------"
	echo Find directory $DIRECTORY
	find . -type d -name $DIRECTORY | grep -v .hg
done

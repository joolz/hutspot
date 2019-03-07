#!/bin/bash

UTF="UTF-8"
declare ERRORS
ERRORS=""

find . -name '*.properties' -print0 | while IFS= read -r -d $'\0' FILE; do
	ENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`

	FULLPATH=`readlink -f ${FILE}`
	echo ${FULLPATH} has encoding ${ENCODING}

	if [ "${ENCODING}" != "${UTF}" ]; then
		false
		exit
	fi
done

if [ $? -ne 0 ]; then
	echo "ERROR: not all properties files are ${UTF-8}"
	exit 1
fi

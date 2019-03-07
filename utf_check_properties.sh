#!/bin/bash

UTF="UTF-8"

shopt -s globstar
for FILE in **/*.properties; do
	ENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`

	FULLPATH=`readlink -f ${FILE}`
	echo ${FULLPATH} has encoding ${ENCODING}

	if [ "${ENCODING}" != "${UTF}" ]; then
		ERRORS="true"
	fi
done

if [ "${ERRORS}" == "true" ]; then
	echo "ERROR: not all properties files are ${UTF-8}"
	exit 1
fi

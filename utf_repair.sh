#!/bin/bash

UTF="UTF-8"
FILE=${1}
NOW=`date +%s`
BACKUPEXTENSION="backup_${NOW}"

if [ ! -f "${FILE}" ]; then
	echo "Usage $0 filename"
	exit 1
fi

CURRENTENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`

if [ "${CURRENTENCODING}" != "${UTF-8}" ]; then
	echo Make backup to ${FILE}.${BACKUPEXTENSION} and convert
	mv ${FILE} ${FILE}.${BACKUPEXTENSION}
	iconv -f ISO-8859-1 -t ${UTF}//TRANSLIT ${FILE}.${BACKUPEXTENSION} -o ${FILE}
fi

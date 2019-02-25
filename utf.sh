#!/bin/bash

UTF="UTF-8"
BACKUPEXTENSION="endodingbackup"

find . -type f | while read -r FILE
do
	echo -n "."
	CURRENTENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`

	if [ "${CURRENTENCODING}" == "ISO-8859" ]; then
		echo Make backup to ${FILE}.${BACKUPEXTENSION} and convert
		mv ${FILE} ${FILE}.${BACKUPEXTENSION}
		iconv -f ISO-8859-1 -t ${UTF}//TRANSLIT ${FILE}.backup -o ${FILE}
	fi

done

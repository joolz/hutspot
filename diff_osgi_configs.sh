#!/bin/bash

TEMP_DIR=`mktemp -d`

echo tempdir is ${TEMP_DIR}

cd ${TEMP_DIR} || exit 1

echo 1

for SERVER in two1 two2 awo1 awo2 pwo1 pwo2
do
	echo "Fetch osgi configs from ${SERVER}"
	mkdir ${SERVER}
	cd ${SERVER}
	scp ${SERVER}:/usr/local/liferay/osgi/configs/* .
	cd ..
done

meld *

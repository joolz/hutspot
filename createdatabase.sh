#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

sudocheck

if [ -z "${1}" ]; then
	echo "Create a database. Usage: $0 DATABASENAME"
	exit 1
fi

CMD="CREATE DATABASE ${1} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
CMD="${CMD} GRANT ALL PRIVILEGES ON ${1}.* TO"
CMD="${CMD} '${LOCAL_DB_USER}'@'${LOCAL_DB_HOST}' IDENTIFIED BY '${LOCAL_DB_PASSWORD}';"

echo "Command is"
echo
echo "${CMD}"
confirm "Continue?"

sudo mysql \
	--host=${LOCAL_DB_HOST} \
	--port=${LOCAL_DB_PORT} \
	--user=root \
	--password=${LOCAL_DB_PASSWORD} \
	-e "${CMD}" || exit 1

doneMessage

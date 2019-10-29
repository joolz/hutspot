#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

sudocheck

if [ -z "${1}" ]; then
	echo "Create a database. Usage: $0 DATABASENAME"
	exit 1
fi

CMD="CREATE DATABASE ${1} CHARACTER SET ${DB_CHARACTER_SET} COLLATE ${DB_DEFAULT_COLLATE};"
CMD="${CMD} CREATE USER '${LOCAL_DB_USER}'@'${LOCAL_DB_HOST}' IDENTIFIED BY '${LOCAL_DB_PASSWORD}';"
CMD="${CMD} ALTER USER '${LOCAL_DB_USER}'@'${LOCAL_DB_HOST}' IDENTIFIED WITH mysql_native_password BY '${LOCAL_DB_PASSWORD}';"
CMD="${CMD} GRANT ALL PRIVILEGES ON ${1}.* TO '${LOCAL_DB_USER}'@'${LOCAL_DB_HOST}' IDENTIFIED BY '${LOCAL_DB_PASSWORD}';"

echo "Command is"
echo
echo "${CMD}"
confirm "Continue?"

sudo mysql \
	--host=${LOCAL_DB_HOST} \
	--port=${LOCAL_DB_PORT} \
	--user=root \
	--password=${LOCAL_DB_PASSWORD} \
	-e "${CMD}"

#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

case "$1" in
"")
	BU_SCHEMA=$DOCKER_DB_SCHEMA
	BU_USER=$DOCKER_DB_USER
	BU_PASSWORD=$DOCKER_DB_PASSWORD
	# docker network inspect compose_default
	BU_HOST=$DOCKER_DB_HOST
	BU_PORT=$DOCKER_DB_PORT
	;;
"local")
	BU_SCHEMA=$LOCAL_DB_SCHEMA
	BU_USER=$LOCAL_DB_USER
	BU_PASSWORD=$LOCAL_DB_PASSWORD
	BU_HOST=$LOCAL_DB_HOST
	BU_PORT=$LOCAL_DB_PORT
	;;
"two")
	BU_SCHEMA=$TWO_DB_SCHEMA
	BU_USER=$TWO_DB_USER
	BU_PASSWORD=$TWO_DB_PASSWORD
	BU_HOST=$TWO_DB_HOST
	BU_PORT=$TWO_DB_PORT
	;;
"awo")
	BU_SCHEMA=$AWO_DB_SCHEMA
	BU_USER=$AWO_DB_USER
	BU_PASSWORD=$AWO_DB_PASSWORD
	BU_HOST=$AWO_DB_HOST
	BU_PORT=$AWO_DB_PORT
	;;
"inc")
	BU_SCHEMA=$INC_DB_SCHEMA
	BU_USER=$INC_DB_USER
	BU_PASSWORD=$INC_DB_PASSWORD
	BU_HOST=$INC_DB_HOST
	BU_PORT=$INC_DB_PORT
	;;
"pwomirror")
	BU_SCHEMA=$PWO_MIRROR_DB_SCHEMA
	BU_USER=$PWO_MIRROR_DB_USER
	BU_PASSWORD=$PWO_MIRROR_DB_PASSWORD
	BU_HOST=$PWO_MIRROR_DB_HOST
	BU_PORT=$PWO_MIRROR_DB_PORT
	;;
*)
	echo "Usage: db_dump local | two | awo | inc | docker"
	exit 1
	;;
esac

cd $DB_DUMP_DIR

DATEFORMATTED=`date +"${DATEFORMAT}"`

BU_FILE=${DATEFORMATTED}.$BU_SCHEMA.mysql

say "Backup schema $BU_SCHEMA to $BU_FILE"

mysqldump \
	--create-options \
	--user=$BU_USER \
	--password=$BU_PASSWORD \
	--result-file=$BU_FILE \
	--protocol=tcp \
	--host=$BU_HOST \
	--port=$BU_PORT \
	--column-statistics=0 \
	--compress \
	$BU_SCHEMA

ERR=$?
if [ "$ERR" -ne "0" ]; then
	echo $ERR
	test -e $DUMPFILE && rm $DUMPFILE
	exit 1
fi

say "Dump made to file ${BU_FILE}"

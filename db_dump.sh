#!/bin/bash

source ~/bin/common.sh
source $CREDSFILE || exit 1

case "$1" in
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
*)
	echo "Usage: db_dump local | two | awo | inc"
	exit 1
	;;
esac

cd $DB_DUMP_DIR || exit 1

DATEFORMATTED=`date +"${DATEFORMAT}"`

BU_FILE=${DATEFORMATTED}.$BU_SCHEMA.mysql

say "Backup mysql $BU_SCHEMA"

mysqldump \
	--create-options \
	--user=$BU_USER \
	--password=$BU_PASSWORD \
	--result-file=$BU_FILE \
	--host=$BU_HOST \
	--port=$BU_PORT \
	--compress \
	$BU_SCHEMA

ERR=$?
if [ "$ERR" -ne "0" ]; then
	echo $ERR
	test -e $DUMPFILE && rm $DUMPFILE
	exit 1
fi

tar -czf ${BU_FILE}.tar.gz $BU_FILE && rm $BU_FILE
say "Dump made to file ${BU_FILE}.tar.gz"
doneMessage

#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

case "$1" in
"")
	Q_SCHEMA=$DOCKER_DB_SCHEMA
	Q_USER=$DOCKER_DB_USER
	Q_PASSWORD=$DOCKER_DB_PASSWORD
	# docker network inspect compose_default
	Q_HOST=$DOCKER_DB_HOST
	Q_PORT=$DOCKER_DB_PORT
	;;
"local")
	Q_SCHEMA=$LOCAL_DB_SCHEMA
	Q_USER=$LOCAL_DB_USER
	Q_PASSWORD=$LOCAL_DB_PASSWORD
	Q_HOST=$LOCAL_DB_HOST
	Q_PORT=$LOCAL_DB_PORT
	;;
"two")
	Q_SCHEMA=$TWO_DB_SCHEMA
	Q_USER=$TWO_DB_USER
	Q_PASSWORD=$TWO_DB_PASSWORD
	Q_HOST=$TWO_DB_HOST
	Q_PORT=$TWO_DB_PORT
	;;
"awo")
	Q_SCHEMA=$AWO_DB_SCHEMA
	Q_USER=$AWO_DB_USER
	Q_PASSWORD=$AWO_DB_PASSWORD
	Q_HOST=$AWO_DB_HOST
	Q_PORT=$AWO_DB_PORT
	;;
"inc")
	Q_SCHEMA=$INC_DB_SCHEMA
	Q_USER=$INC_DB_USER
	Q_PASSWORD=$INC_DB_PASSWORD
	Q_HOST=$INC_DB_HOST
	Q_PORT=$INC_DB_PORT
	;;
"pwomirror")
	Q_SCHEMA=$PWO_MIRROR_DB_SCHEMA
	Q_USER=$PWO_MIRROR_DB_USER
	Q_PASSWORD=$PWO_MIRROR_DB_PASSWORD
	Q_HOST=$PWO_MIRROR_DB_HOST
	Q_PORT=$PWO_MIRROR_DB_PORT
	;;
*)
	echo "Usage: $0 [DB_NAME] [QUERY]"
	echo when not specifying a query you get a shell
	echo
	echo When you want a local root connection, do sudo mysql --user=root
	exit 1
	;;
esac

if [ "$2" == "" ]; then
	mysql \
		--host=$Q_HOST \
		--port=$Q_PORT \
		--user=$Q_USER \
		--password=$Q_PASSWORD \
		--protocol=tcp \
		--prompt="\h:\p/\d\ -\ \R:\r:\s>\ " \
		$Q_SCHEMA
else
	mysql \
		--host=$Q_HOST \
		--port=$Q_PORT \
		--user=$Q_USER \
		--protocol=tcp \
		--password=$Q_PASSWORD \
		$Q_SCHEMA \
		-e "$2" \
		-B > $DB_DUMP_DIR/${DATEFORMATTED}-query.txt
fi

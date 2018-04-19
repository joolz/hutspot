#!/bin/bash

. ~/bin/common.sh

echo
echo "Select schema"
echo 
echo 1 local mysql
echo 2 local docker
echo 3 remote dlwo_inc
echo 4 local dxp
echo
read -r -n1 CHOICE

# non default connection settings
if [ "$CHOICE" == "1" ]; then
  DB_SCHEMA=mysql
elif [ "$CHOICE" == "2" ]; then
  DB_SCHEMA=$DOCKER_DB_SCHEMA
	DB_USER=$DOCKER_DB_USER
	DB_PASSWORD=$DOCKER_DB_PASSWORD
	DB_PORT=$DOCKER_DB_PORT
elif [ "$CHOICE" == "3" ]; then
	DB_USER=$INC_DB_USER
	DB_PASSWORD=$INC_DB_PASSWORD
	DB_HOST=$INC_DB_HOST
	DB_PORT=$INC_DB_PORT
	DB_SCHEMA=$INC_DB_SCHEMA
elif [ "$CHOICE" == "4" ]; then
	DB_SCHEMA=dxp
fi

echo -------------------------------
echo Using schema $DB_SCHEMA
echo -------------------------------

mysql \
	--host=$DB_HOST \
	--port=$DB_PORT \
  --user=$DB_USER \
  --password=$DB_PASSWORD \
  --prompt="\h:\p/\d\ -\ \R:\r:\s>\ " \
  $DB_SCHEMA

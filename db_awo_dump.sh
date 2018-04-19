#!/bin/bash

. ~/bin/credentials.sh
. ~/bin/common.sh

cd $DB_DUMP_DIR || exit 1

TIME=`date +%Y%m%d-%H%M%S`
DUMPFILE=$TIME.$AWO_DB_SCHEMA.mysql

say "backup mysql $AWO_DB_SCHEMA"

mysqldump \
  --create-options \
  --user=$AWO_DB_USER \
  --password=$AWO_DB_PASSWORD \
  --result-file=$DUMPFILE \
  --host=$AWO_DB_HOST \
  --port=$AWO_DB_PORT \
	--compress \
  $AWO_DB_SCHEMA

say Dump made to file $DUMPFILE

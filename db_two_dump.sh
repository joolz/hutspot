#!/bin/bash

. ~/bin/common.sh

cd $DB_DUMP_DIR || exit 1

TIME=`date +%Y%m%d-%H%M%S`
DUMPFILE=$TIME.$TWO_DB_SCHEMA.mysql

say "backup mysql $TWO_DB_SCHEMA"

mysqldump \
  --create-options \
  --user=$TWO_DB_USER \
  --password=$TWO_DB_PASSWORD \
  --result-file=$DUMPFILE \
  --host=$TWO_DB_HOST \
  --port=$TWO_DB_PORT \
	--compress \
  $TWO_DB_SCHEMA

say Dump made to file $DUMPFILE

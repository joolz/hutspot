#!/bin/bash

. ~/bin/common.sh

cd $DB_DUMP_DIR || exit 1

TIME=`date +%Y%m%d-%H%M%S`
DUMPFILE=$TIME.$INC_DB_SCHEMA.mysql

say "backup mysql $INC_DB_SCHEMA"

mysqldump \
  --create-options \
  --user=$INC_DB_USER \
  --password=$INC_DB_PASSWORD \
  --result-file=$DUMPFILE \
  --host=$INC_DB_HOST \
  --port=$INC_DB_PORT \
	--compress \
  $INC_DB_SCHEMA

say Dump made to file $DUMPFILE

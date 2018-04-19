#!/bin/bash

. ~/bin/common.sh || exit 1

mysql \
	--host=$DB_HOST \
	--port=$DB_PORT \
  --user=$DB_USER \
  --password=$DB_PASSWORD \
  $DB_SCHEMA \
	-e "select * from PortletPreferences where portletId like '101_%'" \
	-B > $DB_DUMP_DIR/query.txt


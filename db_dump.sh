#!/bin/bash

OWNER=jal
TARGET_DIR=/home/$OWNER/Desktop

PORTAL_EXT="/opt/liferay-6.2/portal/portal-ext.properties"
DB_USER=`grep jdbc.default.username $PORTAL_EXT | grep -v '^$\|^\s*\#' | awk -F "=" '{print $2}'`
DB_PASSWORD=`grep jdbc.default.password $PORTAL_EXT | grep -v '^$\|^\s*\#' | awk -F "=" '{print $2}'`

function say {
  TIME=`date +%Y%m%d-%H%M%S`
  echo "=== HB $TIME - $1"
}

cd $TARGET_DIR || exit 1

case "$1" in
"")
  WHAT="--all-databases"
  ;;
*)
  WHAT="$1"
  ;;
esac

TIME=`date +%Y%m%d-%H%M%S`
DUMPFILE=$TIME.$WHAT.mysql
say "backup mysql $WHAT"
mysqldump \
  --create-options \
  --lock-all-tables \
  --user=$DB_USER \
  --password=$DB_PASSWORD \
  --result-file=$DUMPFILE \
  $WHAT

ERR=$?
if [ "$ERR" -ne "0" ]; then
  echo $ERR
  test -e $DUMPFILE && rm $DUMPFILE
  exit 1
fi

tar -czf $DUMPFILE.tar.gz $DUMPFILE && rm $DUMPFILE
chown $OWNER.$OWNER $DUMPFILE.tar.gz

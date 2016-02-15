#!/bin/bash

OWNER=jal
TARGET_DIR=/home/$OWNER/Desktop
MYSQLUSER=root
MYSQLPASSWORD=`cat /home/jal/Documents/accounts/mysql_root_pw.txt`

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
  --user=$MYSQLUSER \
  --password=$MYSQLPASSWORD \
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

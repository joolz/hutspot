#!/bin/bash

. ~/bin/common.sh || exit 1

cd $DB_DUMP_DIR || exit 1

case "$1" in
"")
  WHAT="--all-databases"
  ;;
*)
  WHAT="$1"
  ;;
esac

DUMPFILE=${DATEFORMATTED}.$WHAT.mysql
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
chown $USER.$USER $DUMPFILE.tar.gz

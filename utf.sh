#!/bin/bash

INFORMAT=ISO-8859-1
OUTFORMAT=UTF-8

if [ -z "$1" ]; then
  echo Usage: $0 filename
  exit 1
fi

FILEINFO=`file -b $1`

case "$FILEINFO" in

# *ASCII* )
#   echo $1 is $FILEINFO, no conversion
#   ;;

  *UTF-8* )
    echo $1 is $FILEINFO, no conversion
    ;;

  * )
    echo $1 is $FILEINFO, make backup and convert
    cp $1 $1.backup
    iconv -f $INFORMAT -t $OUTFORMAT $1.backup | dos2unix > $1
    ;;

esac

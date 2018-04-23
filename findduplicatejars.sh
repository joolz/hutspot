#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

SEARCHDIR=$DXPSERVERDIR
TEMPFILE=`mktemp`

cd $SEARCHDIR || exit 1

echo Will use tempfile $TEMPFILE

ALLJARS=`find . -name *.jar`

for ALLJAR in $ALLJARS
do

  BN=`basename $ALLJAR`
  echo $BN >> $TEMPFILE

done

for UNIQJAR in `cat $TEMPFILE | sort | uniq`
do

  THEONE=`find . -name $UNIQJAR | head -1`

  echo "================================================================"
  MD5THEONE=`md5sum -b $THEONE`
  echo $MD5THEONE
  echo "----------------------------------------------------------------"

  JARS=`find . -name $UNIQJAR`

  for FOUNDFILE in $JARS
  do

    MD5SUMI=`md5sum -b $FOUNDFILE`
    echo $MD5SUMI

  done

done

rm $TEMPFILE

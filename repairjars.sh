#!/bin/bash

. ~/bin/common.sh

SEARCHDIR=$DXPSERVERDIR

JARNAMES="util-java.jar util-taglib.jar util-bridges.jar portals-bridges.jar"

for JARNAME in $JARNAMES
do

  THEONE=/usr/local/liferay/tomcat/webapps/ROOT/WEB-INF/lib/$JARNAME

  echo Will use this file as original: $THEONE
  ls -l $THEONE

  MD5THEONE=`md5sum -b $THEONE`
  echo MD5Sum of $THEONE:
  echo $MD5THEONE
  echo

  echo press any key to continue...
  read -n 1 DUMMY

  echo ===================================

  cd $SEARCHDIR || exit 1

  JARS=`find . -name $JARNAME`

  for FOUNDFILE in $JARS
  do

#    echo -----------------------------------
#    ls -l $FOUNDFILE
#    echo --- Pre MD5Sum of $FOUNDFILE
    MD5SUMI=`md5sum -b $FOUNDFILE`
    echo $MD5SUMI
#    echo
#
#    if [ "$FOUNDFILE" != "$THEONE" ]; then
#      DIR=`dirname $FOUNDFILE`
#      cp -pvf $THEONE $DIR
#    fi
#
#    echo
#    ls -l $FOUNDFILE
#    MD5SUMI=`md5sum -b $FOUNDFILE`
#    echo --- Post MD5Sum of $FOUNDFILE
#    echo $MD5SUMI

  done

done

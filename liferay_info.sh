#!/bin/bash

LRDIR=/opt/liferay/portal
TOMCATDIR=$LRDIR/tomcat-6.0.32
NOW=`date +%Y%m%d-%H%M`
TARGETFILE=~/Desktop/liferay_info_$NOW.txt

cd $LRDIR/patching-tool

./patching-tool.sh info >|$TARGETFILE

cd $TOMCATDIR/webapps

for FILE in nl-*
do
  pushd $FILE/META-INF/
  HG_BRANCH=`grep Hg-Branch MANIFEST.MF`
  HG_SHORT_NODE=`grep Hg-Short-Node MANIFEST.MF`
  echo '----------------------------------------------' >> $TARGETFILE
  echo "$FILE $HG_BRANCH $HG_SHORT_NODE" >> $TARGETFILE
  popd
done


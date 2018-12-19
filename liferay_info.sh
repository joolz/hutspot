#!/bin/bash

source ~/bin/common.sh || exit 1

LRDIR=/opt/liferay/portal
TOMCATDIR=$LRDIR/tomcat-6.0.32
TARGETFILE="~/Desktop/liferay_info_${DATEFORMATTED}.txt"

cd $LRDIR/patching-tool

./patching-tool.sh info >|$TARGETFILE

cd $TOMCATDIR/webapps

for FILE in nl-*
do
  checkedPushd $FILE/META-INF/
  HG_BRANCH=`grep Hg-Branch MANIFEST.MF`
  HG_SHORT_NODE=`grep Hg-Short-Node MANIFEST.MF`
  echo '----------------------------------------------' >> $TARGETFILE
  echo "$FILE $HG_BRANCH $HG_SHORT_NODE" >> $TARGETFILE
  popd >/dev/null 2>&1
done


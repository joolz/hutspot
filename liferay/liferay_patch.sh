#!/bin/bash

RUN=`ps -ef | grep tomcat | grep liferay | grep -v grep | wc -l`

if [ "$RUN" -ne "0" ]; then
	echo Liferay active, exiting
	exit 1
fi

PATCH_DIR=/opt/liferay-6.2/portal/patching-tool
SRC_DIR=/opt/liferay-6.2/src

cd $SRC_DIR || exit 1
cd $PATCH_DIR || exit 1

rm patches/*

hg pull
hg update --clean

rm *bat

./patching-tool.sh auto-discovery >| default.properties

./patching-tool.sh revert || exit 1
./patching-tool.sh install || exit 1

rm source.properties
./patching-tool.sh source auto-discovery $SRC_DIR source || exit 1

echo Sources patched. Please refresh Liferay source in Eclipse

./patching-tool.sh source install

cd /opt/liferay-6.2/portal/tomcat-7.0.62/ || exit 1

rm -r work && mkdir work
rm -r temp && mkdir temp

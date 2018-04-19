#!/bin/bash

NOW=`date +%Y%m%d`
TEMP_SYNC_DIR=~/tmp/
TARGET_DIR=/media/windows_home/backup_sourceforge

pushd $TEMP_SYNC_DIR || exit 1
mkdir $NOW || exit 1

rsync -av openu.hg.sourceforge.net::hgroot/openu/* $TEMP_SYNC_DIR/$NOW || exit 1

exit 0

tar -jcvf $TARGET_DIR/$NOW.bz2 $TEMP_SYNC_DIR/$NOW || exit 1

rm -r $TEMP_SYNC_DIR/$NOW

popd

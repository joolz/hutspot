#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

TEMP_SYNC_DIR=~/tmp/
TARGET_DIR=/media/windows_home/backup_sourceforge

checkedPushd $TEMP_SYNC_DIR
mkdir ${DATEFORMATTED} || exit 1

rsync -av openu.hg.sourceforge.net::hgroot/openu/* $TEMP_SYNC_DIR/$NOW || exit 1

exit 0

tar -jcvf $TARGET_DIR/$NOW.bz2 $TEMP_SYNC_DIR/$NOW || exit 1

rm -r $TEMP_SYNC_DIR/${DATEFORMATTED}

popd

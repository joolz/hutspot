#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# workaround script for https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-118

liferayrunningcheck

checkedPushd $DXPSERVERDIR/patching-tool

case "$1" in

"source")
	confirm "Will patch DXP sources. Continue?"
	rm patches/*
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/source/* patches/
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
	cp source.properties default.properties
	./patching-tool.sh install
	rm default.properties
	rm -rf $DXPSERVERDIR/osgi/state
	;;

"binary")
	confirm "Will patch DXP binaries. Continue?"
	rm patches/*
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/binary/* patches/
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
	cp binary.properties default.properties
	./patching-tool.sh install
	rm default.properties
	rm -rf $DXPSERVERDIR/osgi/state
	;;

*)
	echo "Usage: $0 [source|binary]"
	;;

esac

# Regardles of what we've done, restore binary as default for normal use
if [ ! -f default.properties ]; then
	cp binary.properties default.properties
fi

popd

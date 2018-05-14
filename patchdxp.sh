#!/bin/bash

# workaround script for https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-118

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

case "$1" in

"source")
	confirm "Will patch DXP sources. Continue?"
	pushd $DXPSERVERDIR/patching-tool || exit 1
	rm patches/* || exit 1
	cp $DXPPATCHESDIR/source/* patches/
	cp $DXPPATCHESDIR/combined/* patches/
	cp source.properties default.properties
	./patching-tool.sh install
	rm default.properties
	popd
	rm -rf $DXPSERVERDIR/osgi/state
	;;

"binary")
	confirm "Will patch DXP binaries. Continue?"
	pushd $DXPSERVERDIR/patching-tool || exit 1
	rm patches/* || exit 1
	cp $DXPPATCHESDIR/binary/* patches/
	cp $DXPPATCHESDIR/combined/* patches/
	cp binary.properties default.properties
	./patching-tool.sh install
	rm default.properties
	popd
	rm -rf $DXPSERVERDIR/osgi/state
	;;

*)
	echo "Usage: $0 [source|binary]"
	;;

esac


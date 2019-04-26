#!/bin/bash

source ~/bin/common.sh || exit 1

DIRS="$ECLIPSE_WORKSPACE $DXPSERVERDIR"

for I in $DIRS; do
	find $I -name rebel.xml -exec grep -L "<dir name=\"$ECLIPSE_WORKSPACE" {} \;
done

doneMessage

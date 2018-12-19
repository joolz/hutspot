#!/bin/bash

PATTERN="/home/jal/workspace"
DIRS="$PATTERN /opt/dxp/server"

for I in $DIRS; do
	find $I -name rebel.xml -exec grep -L "<dir name=\"$PATTERN" {} \;
done


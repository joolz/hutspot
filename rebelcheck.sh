#!/bin/bash

PATTERN="/home/jal/workspace"
DIRS="$PATTERN /opt/dxp/server/tomcat-8.0.32"

for I in $DIRS; do
	find $I -name rebel.xml -exec grep -L "<dir name=\"$PATTERN" {} \;
done


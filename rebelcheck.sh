#!/bin/bash

DIRS="~/workspace ~/workspace-adhoc /opt/liferay/portal/tomcat-7.0.62"

for I in $DIRS; do
	find $I -name rebel.xml -exec grep -L "<dir name=\"~/workspace" {} \;
done


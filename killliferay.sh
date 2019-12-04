#!/bin/bash

source ~/bin/common.sh || exit 1

LIFERAY_PID=`liferaypid`

if [ "$LIFERAY_PID" != "" ]; then
	confirm "Kill liferay PID $LIFERAY_PID ?"
	kill -9 $LIFERAY_PID
else
	confirm "No running tomcat detected. Cleanup temp stuff?"
fi

liferaycleanup

#!/bin/bash

PARAMS="--headless --accept=socket,host=127.0.0.1,port=8100;urp; --nofirststartwizard"
THISSCRIPT=`basename $0`
RUNNINGHEADLESS=`ps -ef | grep -v grep | grep soffice | grep "accept=socket"`

if [ -z "$RUNNINGHEADLESS" ]; then

	RUNNING=`ps -ef | grep soffice | grep -v grep | grep -v $THISSCRIPT`

	if [ -z "$RUNNING" ]; then

		logger "$0 start soffice headless"
		soffice $PARAMS
	
	else

		logger "$0 cannot start soffice headless, another instance of soffice is running"

	fi

fi

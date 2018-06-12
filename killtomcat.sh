#!/bin/bash

source ~/bin/common.sh || exit 1

TOMCATPID=`jps -l | grep org.apache.catalina.startup.Bootstrap | awk '{print $1}'`

if [ "$TOMCATPID" != "" ]; then
	confirm "Kill tomcat PID $TOMCATPID ?"
	kill -9 $TOMCATPID
fi

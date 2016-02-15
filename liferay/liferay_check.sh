#!/bin/bash

RUN=`ps -ef | grep tomcat | grep liferay | grep -v grep | wc -l`

if [ "$RUN" -eq "0" ]; then
	echo No liferay instance found
	exit 0
else
	echo Running liferay instance found
	exit 1
fi

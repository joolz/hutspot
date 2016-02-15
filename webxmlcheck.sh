#!/bin/bash

echo "Check if web.xml for tomcat projects exists"

WEBAPPS_DIR=/opt/liferay-6.2/portal/tomcat-7.0.62/webapps
ERROR_COUNT=0


for I in `ls $WEBAPPS_DIR | grep nl-ou-dlwo`; do
  FILE=$WEBAPPS_DIR/$I/WEB-INF/web.xml
  echo Check $FILE
  if [ ! -s $FILE ]; then
    echo $FILE does not exist or is empty
    ERROR_COUNT=$(($ERROR_COUNT+1))
  fi
done

echo Number of errors $ERROR_COUNT

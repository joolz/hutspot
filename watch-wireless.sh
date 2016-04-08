#!/bin/bash

LOGFILE=/var/log/watch-wireless.log
INTERVAL=5s
INTERFACE=wlan0

while [ 0 ]; do
  DATESTAMP=`date +%Y-%m-%d\ %H:%M:%S`
	IP_ADDRESS=`ip addr show $INTERFACE | awk '/inet/ {print $2}' | cut -d/ -f1 | head -1`
  LINK=`iwconfig $INTERFACE | grep Link | tail`
	RX=`ifconfig $INTERFACE | grep "RX packets:"`
	TX=`ifconfig $INTERFACE | grep "TX packets:"`
	COLLISIONS=`ifconfig $INTERFACE | grep "collisions:"`
  echo $DATESTAMP: $IP_ADDRESS - $LINK $RX $TX $COLLISIONS >> $LOGFILE
  sleep $INTERVAL
done


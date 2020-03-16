#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

LOGFILE=/var/log/watch-wireless.log
INTERVAL=5s
INTERFACE=wlan0
PINGEXTERNALHOST=www.xs4all.nl

while [ 0 ]; do
	IP_ADDRESS=`ip addr show $INTERFACE | awk '/inet/ {print $2}' | cut -d/ -f1 | head -1`
  LINK=`iwconfig $INTERFACE | grep Link | tail`
	RX=`ifconfig $INTERFACE | grep "RX packets:"`
	TX=`ifconfig $INTERFACE | grep "TX packets:"`
	COLLISIONS=`ifconfig $INTERFACE | grep "collisions:"`

	ping -c 1 -W 4 $PINGEXTERNALHOST &> /dev/null
	PINGEXTERNALSTATUS=$?

	DATEFORMATTED=`date +%Y%m%d-%H%M%S`

  echo ${DATEFORMATTED}: $IP_ADDRESS / $LINK / $RX / $TX / $COLLISIONS / \
		ping $PINGEXTERNALHOST status $PINGEXTERNALSTATUS >> $LOGFILE
  sleep $INTERVAL
done


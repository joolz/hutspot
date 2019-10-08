#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

rootcheck

case "$1" in

"--on")
	echo Set redirect on
	iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080
	iptables -t nat -L
	;;

"--off")
	echo Set redirect off
	iptables -t nat -D OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080
	iptables -t nat -L
	;;

*)
	echo "On localhost (un)redirect anything that comes in on port 80 to 8080"
	echo "Usage $0 --on | --off"
	;;

esac

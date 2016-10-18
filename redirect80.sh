#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
  exit 1
fi

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

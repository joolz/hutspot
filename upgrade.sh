#!/bin/bash

echo "Don't use, check unattended-upgrade"

sudo unattended-upgrade --dry-run --debug

exit 1

sudo apt-get update && \
	sudo apt-get dist-upgrade -y && \
	sudo apt-get autoremove -y

if [ -f /var/run/reboot-required.pkgs ]; then
	echo
	cat /var/run/reboot-required.pkgs
	echo "require(s) a reboot"
fi

#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

sendto() {
	echo "send testmail with dummy content (this script) to $1"
	mailx -s "Test mail from $HOSTNAME" $1 < $0
}

sendto `whoami`@ou.nl
sendto `whoami`

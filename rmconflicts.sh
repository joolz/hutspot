#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

if [ "${1}" == "-b" ]; then
	# background for selected crap
	find ${NEXTCLOUDDIR} -regex ".*Microsoft Teams.*conflicted copy.*" -exec rm -v {} \;
else
	# interactive for all conflicted copies
	find ${NEXTCLOUDDIR} -iname "*conflicted copy*" -exec rm -iv {} \;
fi

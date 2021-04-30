#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

if [ "${1}" == "-b" ]; then
	# background for selected crap
	find \
		${NEXTCLOUDDIR} \
		-path ${NEXTCLOUDDIR}/rasa-compose/db -prune -false -o \
		-regex ".*Microsoft Teams.*conflicted copy.*" \
		-exec rm -v {} \;
else
	# interactive for all conflicted copies
	find \
		${NEXTCLOUDDIR} \
		-path ${NEXTCLOUDDIR}/rasa-compose/db -prune -false -o \
		-iname "*conflicted copy*" \
		-exec rm -iv {} \;
fi

#		-not -path "${NEXTCLOUDDIR}/rasa-compose/db/*" \

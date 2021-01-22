#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

NEWVALUE=$1

if [ -z ${NEWVALUE} ]; then
	echo "Usage: $0 timeoutvalueinminutes"
	exit 1
fi

FILES="${DXP72TOMCATDIR}/webapps/ROOT/WEB-INF/web.xml,${DXP72TOMCATDIR}/webapps/ROOT/WEB-INF/slim-runtime-web.xml,${DXP72TOMCATDIR}/conf/web.xml"

for FILE in ${FILES//,/ }; do
	echo ${FILE}
	sed -r -i.bak "s/<session-timeout>([0-9]*)</<session-timeout>${NEWVALUE}</" ${FILE}
done

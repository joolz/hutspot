#!/bin/bash

source ~/bin/common.sh || exit 1

echo To do: xmlstarlet. Search for session-timeout

vi `find ${DXPTOMCATDIR} -name "*xml" -exec grep -l "session.timeout" {} \;`

# ${DXPTOMCATDIR}/webapps/ROOT/WEB-INF/web.xml
# ${DXPTOMCATDIR}/webapps/ROOT/WEB-INF/slim-runtime-web.xml
# ${DXPTOMCATDIR}/conf/web.xml
# <web-app>
# <session-config>
# <session-timeout>


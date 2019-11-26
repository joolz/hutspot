#!/bin/bash

REPO=https://github.com/StevenBlack/hosts.git
BASEDIR=/var/local
DIR=${BASEDIR}/hosts

logger "$0 will work with dir $DIR"

if [ ! -d ${DIR} ]; then
	logger "$DIR not found, clone repo $REPO"
	cd ${BASEDIR} || exit 1
	git clone ${REPO} || exit 1
fi
	
cd ${DIR} || exit 1

logger "Reset and pull git repo"
git reset --hard || exit 1
git pull || exit 1

W=whitelist
echo "" >> $W

logger "Generate new hosts"
python3 updateHostsFile.py \
	--auto \
	--replace \
	--extensions \
	fakenews \
	gambling \
	porn

ERRORLEVEL=$?
logger "Finished with errorlevel $ERRORLEVEL"

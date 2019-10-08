#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

RELEASER=nl-ou-dlwo-releaser
SLEEP=900

# in cron, no one can hear you scream
HOST=`/bin/uname -n`

if [ "$HOST" == "lnx-tst-152v" ]; then
	BRANCH=dxp-two
elif [ "$HOST" == "lnx-tst-153v" ]; then
	BRANCH=dxp-two
elif [ "$HOST" == "lnx-acc-152v" ]; then
	BRANCH=dxp-awo
	log "AWO not implemented yet"
	exit 1
elif [ "$HOST" == "lnx-acc-153v" ]; then
	BRANCH=dxp-awo
	log "AWO not implemented yet"
	exit 1
elif [ "$HOST" == "lnx-hrl-152v" ]; then
	BRANCH=dxp
	log "PWO not implemented yet"
	exit 1
elif [ "$HOST" == "lnx-hrl-153v" ]; then
	BRANCH=dxp
	log "PWO not implemented yet"
	exit 1
fi

if [ "$BRANCH" == "" ]; then
	log "Could not determine branch for host $HOST. Exiting"
	exit 1
else
	log "Have branch $BRANCH for host $HOST"
fi

rootcheck

log "$0 Check for maven settings"
if [ ! -f ~/.m2/settings.xml ]; then
	log "maven setting file not found. Exit"
	exit 1
fi

log "$0 Check for maven bin"
if [ ! -f $MVN ]; then
	log "maven binary not found. Exit"
	exit 1
fi

log "Go to temp dir"
test -d ~/tmp || mkdir ~/tmp
cd ~/tmp
check $?

if [ -d $RELEASER ]; then
	log "remove old version of releaser project"
	rm -rf $RELEASER
	check $?
fi

log "clone $RELEASER"
hg clone ssh://bamboo://repositories/dlwo/$RELEASER
check $?

log "go to $RELEASER"
cd $RELEASER
check $?

log "update $RELEASER to $BRANCH"
hg up $BRANCH
check $?

# FIXME see https://www.mojohaus.org/versions-maven-plugin/use-latest-snapshots-mojo.html#allowIncrementalUpdates
#if [ "$BRANCH" == "dxp-two" ]; then
#	log "We're on branch $BRANCH, update to latest snapshots"
#	$MVN versions:use-latest-snapshots \
#		-D allowIncrementalUpdates=true \
#		-D allowMajorUpdates=true \
#		-D allowMinorUpdates=true \
#		-D allowSnapshots=true \
#		-D includes="nl.ou.dlwo:*:*:*:*"
#fi

log "Run maven project $RELEASER"
$MVN -U package
check $?

log "Remove non-osgi jars"
prepareforosgi.sh -d ~/tmp/$RELEASER/target -x -r

if [ "$BRANCH" != "dxp-two" ]; then
	log "We're not on a two server, exit now"
	exit 0
fi

log "Stop tomcat"
/etc/init.d/tomcat stop

log "Remove osgi/state"
rm -rf $DXPOSGIDIR/state
check $?

log "Remove osgi/wab"
rm -rf $DXPOSGIDIR/wab
check $?

log "Remove modules"
find $DXPOSGIDIR/modules -name "*.jar" -exec rm {} \;
check $?

log "Remove wa?"
find $DXPOSGIDIR/war -name "*.wa?" -exec rm {} \;
check $?

log "Copy files to deploy"
for I in ~/tmp/$RELEASER/target/*
do
	log "$I"
	cp $I $DXPDEPLOYDIR
	check $?
done

cd $DXPDEPLOYDIR
chown tomcat:tomcat *

if [ "$HOST" == "lnx-tst-153v" ]; then
	log "We're on TWO2, sleep $SLEEP before restarting"
	sleep $SLEEP
fi

log "Start tomcat"
/etc/init.d/tomcat start

doneMessage

#!/bin/bash

# MVN=/opt/maven/bin/mvn
MVN=/usr/bin/mvn
# LRDIR=/usr/local/liferay
LRDIR=/opt/dxp/server
LROSGIDIR=$LRDIR/osgi
PROJECT=nl-ou-dlwo-releaser
BRANCH=dxp-two

log() {
	logger "$0 $1"
}

check() {
	if [ $1 -ne 0 ]; then
		log "failed, exit"
		exit 1
	fi
}

logger "$0 Check for maven settings"
if [ ! -f ~/.m2/settings.xml ]; then
	log "maven setting file not found. Exit"
	exit 1
fi

logger "$0 Check for maven bin"
if [ ! -f $MVN ]; then
	log "maven binary not found. Exit"
	exit 1
fi

log "Go to temp dir"
test -d ~/tmp || mkdir ~/tmp
cd ~/tmp
check $?

if [ -d $PROJECT ]; then
	log "remove old version of releaser project"
	rm -rf $PROJECT
	check $?
fi

log "clone $PROJECT"
hg clone ssh://bamboo://repositories/dlwo/$PROJECT
check $?

log "go to $PROJECT"
cd $PROJECT
check $?

log "update $PROJECT to $BRANCH"
hg up $BRANCH
check $?

# FIXME see https://www.mojohaus.org/versions-maven-plugin/use-latest-snapshots-mojo.html#allowIncrementalUpdates
#if [ "$BRANCH" == "dxp-two" ]; then
	log "We're on branch $BRANCH, update to latest snapshots"
	$MVN versions:use-latest-snapshots \
		-D allowIncrementalUpdates=true \
		-D allowMajorUpdates=true \
		-D allowMinorUpdates=true \
		-D allowSnapshots=true \
		-D includes="nl.ou.dlwo:*:*:*:*"
#fi

log "Run maven project $PROJECT"
$MVN -U package || exit 1
check $?

log "Remove non-osgi jars"
prepareforosgi.sh -d ~/tmp/$PROJECT/target -x -r

log "Exiting for now"
exit 0

# TODO check if tomcat on the other server is running

log "Stop tomcat"
/etc/init.d/tomcat stop

log "Cleanup any existing nl-ou-dlwo software"
find $LROSGIDIR -name "nl-ou-dlwo*" -exec rm {} \;
check $?

log "Move files to deploy"
for I in ~/tmp/$PROJECT/target/*
do
	log "$I"
	mv $I $LRDIR/deploy
	check $?
done

log "Start tomcat"
/etc/init.d/tomcat start

#!/bin/bash

# https://intoli.com/blog/exit-on-errors-in-bash-scripts/
set -E
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "$(date) \"${last_command}\" command exited with level $?."' EXIT

TMP=/tmp
NEXTCLOUDDIR=~/Nextcloud
CREDSFILE=$NEXTCLOUDDIR/beheer/credentials.sh

if [ ! -f "$CREDSFILE" ]; then
	echo Could not find $CREDSFILE
	exit 1
fi

DATEFORMAT="%Y-%m-%d_%H:%M:%S"

DXPBASEDIR=/opt/dxp70
DXPSOURCEDIR=$DXPBASEDIR/src
DXPSERVERDIR=$DXPBASEDIR/server
DXPTOMCATDIR=$DXPSERVERDIR/tomcat-8.0.32
DXPDEPLOYDIR=$DXPSERVERDIR/deploy
DXPDOWNLOADSDIR=$NEXTCLOUDDIR/Downloads/dxp
DXPPATCHESDIR=$DXPDOWNLOADSDIR/patches
DXPLOGDIR=$DXPBASEDIR/log
PORTAL_EXT="${DXPSERVERDIR}/portal-ext.properties"
DXPLOG4JCONFIG=${DXPTOMCATDIR}/webapps/ROOT/WEB-INF/classes/log4j.properties

DXP72BASEDIR=/opt/dxp
DXP72SOURCEPHYSICALDIR=liferay-dxp-src-7.2.10.3-sp3
DXP72SOURCEZIP=liferay-dxp-src-7.2.10.3-sp3-202009100727.zip
DXP72SERVERZIP=liferay-dxp-tomcat-7.2.10.3-sp3-20200910120006703.tar.gz
DXP72SERVERPHYSICALDIR=liferay-dxp-7.2.10.3-sp3
DXP72SOURCEDIR=$DXP72BASEDIR/src
DXP72SERVERDIR=$DXP72BASEDIR/server
DXP72TOMCATDIR=$DXP72SERVERDIR/tomcat-9.0.33
DXP72DEPLOYDIR=$DXP72SERVERDIR/deploy
DXP72DOWNLOADSDIR=$DXP72BASEDIR/resources
DXP72PATCHESDIR=$DXP72DOWNLOADSDIR/patches
DXP72BRANCHNAME="DXP72"
PORTAL_EXT72="${DXP72SERVERDIR}/portal-ext.properties"
DXP72BOMVERSION=7.2.10.fp8 

USE_SSL=false

RELEASER=nl-ou-dlwo-releaser

SMTP_HOST=mail.lokaal

DB_TEMP_SCHEMA=dxp_temp
DB_DUMP_DIR=~/Desktop
ECLIPSE_WORKSPACE=/home/jal/workspace

DB_CHARACTER_SET=utf8
DB_DEFAULT_COLLATE=utf8_unicode_ci

SLEEP_LONG=10m
SLEEP_SHORT=2m
SLEEP_NAP=10s

checkOnline() {
	CHECKHOST="www.xs4all.nl"
	wget -q --tries=10 --timeout=20 -O - $CHECKHOST > /dev/null
	ONLINECHECK=$?
	if [ $ONLINECHECK -ne 0 ]; then
		echo "Could not reach $CHECKHOST, seems we're offline"
		exit 1
	fi
}

checkedPushd() {
	# use in combination with popd >/dev/null 2>&1
	pushd $1 >/dev/null 2>&1
	ERROR=$?
	if [ "$ERROR" -ne "0" ]; then
		CURRENT=`pwd`
		echo Error $ERROR going from $CURRENT to $1
		exit 1
	fi
}

confirm() {
	echo $1 [yn]
	read -s -n 1 GOODTOGO
	if [ "$GOODTOGO" != "y" ]; then
		echo Bye
		exit 0
	fi
}

keytocontinue() {
	echo "Press key to continue, ctrl c to stop"
	read -s -n 1
}

hasBom() {
	head -c3 "$1" | LC_ALL=C grep -qP '\xef\xbb\xbf';
}

dxplog() {
	DATEFORMATTED=`date +"${DATEFORMAT}"`
	if [ "$1" == "-m" ]; then
		MESSAGE="${DATEFORMATTED} `caller` - $2"
	else
		MESSAGE="${DATEFORMATTED} `caller` - $1"
	fi
	echo $MESSAGE >> $DXPLOGDIR/general.log
	if [ "$1" == "-m" ]; then
		echo "$MESSAGE" | mailx -s "$MAIL_SUBJECT" -r $MAIL_FROM $MAIL_TO
	fi
}

waitforit() {
  echo -e "Waiting for $1 to complete"
  NOW=$(($(date +%s%N)/1000000))
  FIFO="$TMP/tomcat_$NOW"
  mkfifo $FIFO
  tail -f $CATALINALOG > $FIFO &
  TAIL_PID=$!
  grep -m 1 "$2" $FIFO
  kill $TAIL_PID
  rm $FIFO
  echo -e "$1 completed."
}

convertsecs() {
	((h=${1}/3600))
	((m=(${1}%3600)/60))
	((s=${1}%60))
	printf "%02d:%02d:%02d\n" $h $m $s
}

say() {
	if [ "$1" == "-l" ]; then
		logger $2
	fi
	DATEFORMATTED=`date +"${DATEFORMAT}"`
 	echo "${DATEFORMATTED} - $1"
}

liferaypid() {
	LIFERAY_PID=`ps -ef | grep tomcat | grep java | grep -i dxp | awk '{print $2}'`
	echo $LIFERAY_PID
}

liferayrunningcheck() {
	isLiferayRunning
	RUNNING=$?
	if [ $RUNNING -eq 1 ]; then
		echo Liferay active, exiting
		exit 1
	fi
}

isLiferayRunning() {
	RUN=`liferaypid`
	if [ ! -z `liferaypid` ]; then
		return 1
	else
		return 0
	fi
}

rootcheck() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root"
		exit 1
	fi
}

liferaycleanup() {
	rm -rfv $DXPSERVERDIR/osgi/state
	rm -rfv $DXPSERVERDIR/work
	rm -rfv $DXPSERVERDIR/tomcat-8.0.32/temp
	rm -rfv $DXPSERVERDIR/tomcat-8.0.32/work

	rm -rfv $DXP72SERVERDIR/osgi/state
	rm -rfv $DXP72SERVERDIR/work
	rm -rfv $DXP72SERVERDIR/tomcat-8.0.32/temp
	rm -rfv $DXP72SERVERDIR/tomcat-8.0.32/work
}

sudocheck() {
	sudo -n true
	if [ "$?" -ne "0" ]; then
		echo "Need to be able to sudo"
		exit 1
	fi
}

getProject() {
	# in directory $1, get project $2 and branch $3
	if [[ -z "$1" || -z "$2" ]]; then
		echo Need directory, project
		exit 1
	fi
	if [ -z "$3" ]; then
		BR=default
	else
		BR=$3
	fi
	checkedPushd $1
	if [ -d "$2" ]; then
		cd $2
		hg pull
		hg up -r $BR -C
		hg purge
	else
		hg clone $REPOS/$2
		cd $2
		hg up $BR
	fi
	mvn clean package
	popd >/dev/null 2>&1
}

removeNonOsgi() {
	checkedPushd $1
	TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/"`
	while read -r LINE; do
		checkedPushd $LINE
		find . -name "*.jar" -maxdepth 1 -type f | while read -r FILE
		do
			FOUND=`jar -tf "$FILE" | grep "MANIFEST.MF"`
			if [ "$FOUND" != "" ]; then
				TMPDIR=`mktemp -d -p $TMP`
				FULLNAME=`readlink -f $FILE`
				checkedPushd $TMPDIR
				jar -xvf "${FULLNAME}" $FOUND # &> /dev/null || exit 1
				OSGI=`grep -r "Bundle-SymbolicName" *`
				popd >/dev/null 2>&1
				rm -rf $TMPDIR
				if [ "$OSGI" == "" ]; then
					rm $FILE
					FULLNAME=`readlink -f $FILE`
					echo removed \'$FULLNAME\'
				fi
			fi
		done
		popd >/dev/null 2>&1
	done <<< $TARGETS
	popd >/dev/null 2>&1
}

copyArtifacts() {
	# move artifacts to releaser/target
	if [ ! -z "$1" ] && [ $1 == "7.2" ]; then
		TARGET=$DXP72SERVERDIR
	else
		TARGET=$DXPSERVERDIR
	fi
	PROJECTNAME=${PWD##*/}
	
	checkedPushd ${TARGET}
	FOUND=`find . -name "${PROJECTNAME}*"`
	find . -name "${PROJECTNAME}*" -exec rm -rfv {} \;
	popd >/dev/null 2>&1

	if [ ! -z `liferaypid` ] && [ ! -z "${FOUND}" ]; then
		echo "Liferay is running (`liferaypid`) and files were removed, sleep $SLEEP_NAP"
		sleep $SLEEP_NAP
	fi

	if [ "$2" == "portlet-only" ]; then
		TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/" | grep "\-portlet/"`
	else
		TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/" | sort`
	fi

	while read -r LINE; do
		checkedPushd $LINE
		ARS=`find . -type f -maxdepth 1 -name "*.?ar"`
		while read -r LINE2; do
			if [ ! -z "$LINE2" ]; then
				mv -v $LINE2 $TARGET/deploy
			fi
		done <<< $ARS
		popd >/dev/null 2>&1
	done <<< $TARGETS
}

cleanupLiferay() {
	# remove any existing versions of all artefacts in releaser/target
	# from liferay
	checkedPushd $WORKDIR/$RELEASER/target
	find . -name "nl-ou-dlwo*" -type f | while read -r FILE
	do
		FILE=`basename $FILE`
		FILE=`echo $FILE | sed 's/-[0-9]\+.*//'`
		cleanupFile $FILE $DXPSERVERDIR/osgi/modules
		cleanupFile $FILE $DXPSERVERDIR/osgi/war unversioned
	done
	rm -rfv $DXPSERVERDIR/osgi/state
	echo "Removed $DXPSERVERDIR/osgi/state"
	popd >/dev/null 2>&1
}

doneMessage() {
	DATEFORMATTED=`date +"${DATEFORMAT}"`
	echo "Done at $DATEFORMATTED"
}

beep() {
	paplay /usr/share/sounds/gnome/default/alerts/sonar.ogg
}

addDebugLog() {
	# add debug loglevel for package $1
	if [ ! -z "$1" ]; then
		EXISTS=`grep "$1" ${DXPLOG4JCONFIG}`
		if [ -z "$EXISTS" ]; then
			echo "" >> ${DXPLOG4JCONFIG}
			echo "log4j.logger.${1}=DEBUG" >> ${DXPLOG4JCONFIG}
		fi
	fi
}

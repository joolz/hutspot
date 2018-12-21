#!/bin/bash

REPOS=ssh://bamboo://repositories/dlwo
LR=/opt/dxp/server
RELEASER=nl-ou-dlwo-releaser
RELEASERBRANCH=default
BRANCHES_FILE=/home/jal/bin/branches.csv
WORKDIR=/home/jal/Desktop/work

checkedPushd() {
	# non-verbose pushd with error check
	pushd $1 >/dev/null 2>&1
	ERROR=$?
	if [ "$ERROR" -ne "0" ]; then
		CURRENT=`pwd`
		echo "Error $ERROR going from $CURRENT to $1"
		exit $ERROR
	fi
}

liferayrunningcheck() {
	# abort if liferay is running
	RUN=`ps -ef | grep tomcat | grep "catalina.base" | grep -v grep | wc -l`
	if [ "$RUN" -ne "0" ]; then
		echo Liferay active, exiting
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
		cd $2 || exit 1
		hg pull || exit 1
		hg up -r $BR -C || exit 1
		hg purge || exit 1
	else
		hg clone $REPOS/$2 || exit 1
		cd $2
		hg up $BR
	fi
	mvn clean package || exit 1
	popd >/dev/null 2>&1
}

removeNonOsgi() {
	# remove non-osgi jars
	checkedPushd $1
	TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/"`
	while read -r LINE; do
		checkedPushd $LINE
		find . -name "*.jar" -maxdepth 1 -type f | while read -r FILE
		do
			FULLNAME=`readlink -f $FILE`
			FOUND=`jar -tvf "$FILE" | grep "MANIFEST.MF"`
			if [ "$FOUND" != "" ]; then
				TMPDIR=`mktemp -d -p $TMP`
				checkedPushd $TMPDIR
				jar -xvf "${FULLNAME}" $FOUND &> /dev/null || exit 1 #
				# assume string only occurs in manifest file
				OSGI=`grep -r "Bundle-SymbolicName" *`
				popd >/dev/null 2>&1
				rm -rf $TMPDIR
				if [ "$OSGI" == "" ]; then
					rm $FILE || exit 1
					FULLNAME=`readlink -f $FILE`
					echo "Removed $FULLNAME"
				fi
			fi
		done
		popd >/dev/null 2>&1
	done <<< $TARGETS
	popd >/dev/null 2>&1
}

copyArtifacts() {
	# move artifacts to releaser/target
	if [[ ! -z "$1" && ! -z "$2" ]]; then
		checkedPushd $1
		TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/"`
		while read -r LINE; do
			checkedPushd $LINE
			ARS=`find . -type f -maxdepth 1 -name "*.?ar"`
			while read -r LINE2; do
				if [ ! -z "$LINE2" ]; then
					BARE=`basename $LINE2`
					BARE=`echo $BARE | sed 's/-[0-9]\+.*//'`
					cleanupFile $BARE $2
					mv $LINE2 $2
				fi
			done <<< $ARS
			popd >/dev/null 2>&1
		done <<< $TARGETS
		popd >/dev/null 2>&1
	fi
}

cleanupFile() {
	# remove $1 files from directory $2
	if [[ ! -z "$1" && ! -z "$2" ]]; then
		checkedPushd $2
		find . -name "*" -type f | while read -r FILE
		do
			EXTENSION="${FILE##*.}"
			if [ "$EXTENSION" == "war" ]; then
				if [ "$3" == "unversioned" ]; then
					# deployed wars have no version
					BARE=`basename $FILE`
					BARE="${BARE%.*}"
				else
					BARE=`basename $FILE`
					BARE=`echo $BARE | sed 's/-[0-9]\+.*//'`
				fi
			else
				BARE=`basename $FILE`
				BARE=`echo $BARE | sed 's/-[0-9]\+.*//'`
			fi
			if [ "$BARE" == "$1" ]; then
				rm $FILE || exit 1
				FULLNAME=`readlink -f $FILE`
				echo "Removed $FULLNAME"
			fi
		done
		popd >/dev/null 2>&1
	fi
}

cleanupLiferay() {
	# remove any existing versions of all artefacts in releaser/target
	# from liferay
	checkedPushd $WORKDIR/$RELEASER/target
	find . -name "*" -type f | while read -r FILE
	do
		FILE=`basename $FILE`
		FILE=`echo $FILE | sed 's/-[0-9]\+.*//'`
		cleanupFile $FILE $LR/osgi/modules
		cleanupFile $FILE $LR/osgi/war unversioned
	done
	rm -rf $LR/osgi/state || exit 1
	echo "Removed $LR/osgi/state"
	popd >/dev/null 2>&1
}

usage() {
	echo "BEFORE USING $0 MAKE SURE THE VARIABLES ON TOP OF THE SCRIPT MATCH YOUR ENVIRONMENT!"
	echo
	echo "$0 is a bash script that will try to get the $RELEASERBRANCH branch of $RELEASER from $REPOS and build it. Next, it will look for $BRANCHES_FILE that should be in this format:"
	echo
	echo "someproject,branchname"
	echo "someotherproject,changesetname"
	echo
	echo "and for each line:"
	echo "- fetch the project"
	echo "- switch to the specified branch or changeset"
	echo "- build it"
	echo "- remove the existing version of that project in $RELEASER/target"
	echo "- move the resulting artifacts of the build to $RELEASER/target"
	echo
	echo "Non-osgi jars will be removed and the remaining files copied to $LR/deploy. Existing versions of the artifacts in $LR/osgi/war and modules will removed and finally $LR/osgi/state will be removed."
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	usage
	exit 0
fi

# do it
liferayrunningcheck
checkedPushd $WORKDIR

getProject $WORKDIR $RELEASER $RELEASERBRANCH

if [ ! -f "$BRANCHES_FILE" ]; then
	echo "No $BRANCHES_FILE. Will only deploy $RELEASER"
else
	IFS=','
	while read PROJECT BRANCH
	do
		getProject $WORKDIR $PROJECT $BRANCH
		removeNonOsgi $WORKDIR/$PROJECT
		copyArtifacts $WORKDIR/$PROJECT $WORKDIR/$RELEASER/target
	done < $BRANCHES_FILE
fi

cleanupLiferay

cp -v $WORKDIR/$RELEASER/target/* $LR/deploy

popd >/dev/null 2>&1

#!/bin/bash

REPOS=ssh://bamboo://repositories/dlwo
LR=/opt/dxp/server
RELEASER=nl-ou-dlwo-releaser
RELEASERBRANCH=default
BRANCHES_FILE=/home/jal/bin/branches.csv
WORKDIR=/home/jal/Desktop/work
TEMPDIRLOCATION=/home/jal/tmp

checkedPushd() {
	# non-verbose pushd with error check
	pushd $1 >/dev/null 2>&1
	if [ "$?" -ne "0" ]; then
		echo Error $? going to $1
		exit 1
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

getFresh() {
	# get project and branch
	if [ -z "$2" ]; then
		BR=default
	else
		BR=$2
	fi
	echo "Get $1 branch $BR"
	checkedPushd $WORKDIR
	if [ -d "$1" ]; then
		# this will remove any outstanding changes
		cd $1 || exit 1
		hg pull || exit 1
		hg up -r $BR -C || exit 1
		hg purge || exit 1
	else
		hg clone $REPOS/$1 || exit 1
		cd $1
		hg up $BR
	fi
	mvn clean package || exit 1
	popd >/dev/null 2>&1
}

removeNonOsgi() {
	# remove no-osgi jars
	checkedPushd $WORKDIR/$1
	find . -name target -type d | while read -r TARGETDIR
	do
		checkedPushd $TARGETDIR
		find . -name "*.jar" -maxdepth 1 -type f | while read -r FILE
		do
			FOUND=`jar -tvf "$FILE" | grep "MANIFEST.MF"`
			if [ "$FOUND" != "" ]; then
				TMPDIR=`mktemp -d -p $TEMPDIRLOCATION`
				checkedPushd $TMPDIR
				jar -xvf "../${FILE}" $FOUND &> /dev/null
				# assume string only occurs in manifest file
				OSGI=`grep -r "Bundle-SymbolicName" *`
				popd >/dev/null 2>&1
				rm -rf $TMPDIR
				if [ "$OSGI" == "" ]; then
					echo Remove non-osgi jar $FILE
					rm -v $FILE
				fi
			fi
		done
		popd >/dev/null 2>&1
	done
	popd >/dev/null 2>&1
}

moveToReleaser() {
	# move artifacts to releaser/target
	cleanupProject $1 $WORKDIR/$RELEASER/target
	find $WORKDIR/$1 -name target -type d | while read -r TARGETDIR
	do
		checkedPushd $TARGETDIR
		mv *.?ar $WORKDIR/$RELEASER/target
		popd >/dev/null 2>&1
	done
}

cleanupProject() {
	# remove files from project $1 from directory $2
	# Project is the projectname without version or extension
	if [[ ! -z "$1" && ! -z "$2" ]]; then
		checkedPushd $2
		find . -name "*" -type f | while read -r FILE
		do
			EXTENSION="${FILE##*.}"
			if [ "$EXTENSION" == "war" ]; then
				# no version in wars
				BARE=`basename $FILE`
				BARE="${BARE%.*}"
			else
				BARE=`basename $FILE`
				BARE=`echo $BARE | sed 's/-[0-9]\+.*//'`
			fi
			if [ "$BARE" == "$1" ]; then
				rm -v $FILE
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
		echo "Remove existing ${FILE}* from Liferay"
		cleanupProject $FILE $LR/osgi/modules
		cleanupProject $FILE $LR/osgi/war
	done
	rm -rf $LR/osgi/state
	popd >/dev/null 2>&1
}

usage() {
	echo "$0 is a bash script that will try to get the $RELEASERBRANCH branch of $RELEASER from $REPOS and build it. Next, it will look for $BRANCHES_FILE that should be in this format:"
	echo
	echo "project1name,branch1name"
	echo "project2name,branch2name"
	echo
	echo "For each line fetch the project:"
	echo "- switch to the specified branch or changeset"
	echo "- build it"
	echo "- remove the existing version of that project in $RELEASER/target"
	echo "- move the resulting artifacts of the build to $RELEASER/target"
	echo
	echo "Next, non-osgi jars in $RELEASER/target wil be removed and the remaining files copied to $LR/deploy. Existing versions of the artifacts in $LR/osgi/war and modules will removed and finally $LR/osgi/state will be removed."
	echo
	echo "Before using $0 make sure the variables on top of the script match your environment!"
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	usage
	exit 0
fi

# do it
liferayrunningcheck
checkedPushd $WORKDIR

getFresh $RELEASER $RELEASERBRANCH

if [ ! -f "$BRANCHES_FILE" ]; then
	echo "No $BRANCHES_FILE. Will only deploy $RELEASER"
else
	IFS=','
	while read PROJECT BRANCH
	do
		getFresh $PROJECT $BRANCH
		moveToReleaser $PROJECT
		removeNonOsgi $PROJECT
	done < $BRANCHES_FILE
fi

cleanupLiferay

cp -v $WORKDIR/$RELEASER/target/* $LR/deploy

popd >/dev/null 2>&1

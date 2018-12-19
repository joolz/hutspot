#!/bin/bash

REPOS=ssh://bamboo://repositories/dlwo
LR=/opt/dxp/server
RELEASER=nl-ou-dlwo-releaser
RELEASERBRANCH=default
BRANCHES_FILE=/home/jal/bin/branches.csv
WORKDIR=/home/jal/Desktop/work
TEMPDIRLOCATION=/home/jal/tmp

checkedPushd() {
	pushd $1 >/dev/null 2>&1
	if [ "$?" -ne "0" ]; then
		echo Error $? going to $1
		exit 1
	fi
}

liferayrunningcheck() {
	RUN=`ps -ef | grep tomcat | grep "catalina.base" | grep -v grep | wc -l`
	if [ "$RUN" -ne "0" ]; then
		echo Liferay active, exiting
		exit 1
	fi
}

getFresh() {
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
	if [ "$1" != "nl-ou-dlwo-theme" ]; then
		# skip theme because we also have themeX, themeY etc.
		find $WORKDIR/$RELEASER/target -name "${1}*" -exec rm -rf {} \; 
	fi
	find $WORKDIR/$1 -name target -type d | while read -r TARGETDIR
	do
		checkedPushd $TARGETDIR
		mv *.?ar $WORKDIR/$RELEASER/target
		popd >/dev/null 2>&1
	done
}

cleanupLiferay() {
	checkedPushd $WORKDIR/$RELEASER/target
	find . -name "*" -type f | while read -r FILE
	do
		if [ "$FILE" != "nl-ou-dlwo-theme" ]; then
			# skip theme because we also have themeX, themeY etc.
			FILE=`basename $FILE`
			FILE=`echo $FILE | sed 's/-[0-9]\+.*//'`
			checkedPushd $LR/osgi/modules
			find . -name "${FILE}*" -exec rm -v {} \;
			popd >/dev/null 2>&1
			checkedPushd $LR/osgi/war
			find . -name "${FILE}*" -exec rm -v {} \;
			popd >/dev/null 2>&1
		fi
	done
	rm -rfv $LR/osgi/state
	popd >/dev/null 2>&1
}

usage() {
	echo "$0 is a bash script that will try to get the $RELEASERBRANCH branch"
	echo "of $RELEASER from $REPOS and build it. Next, it will look for"
	echo "$BRANCHES_FILE that should be in this format:"
	echo
	echo "project1name,branch1name"
	echo "project2name,branch2name"
	echo
	echo "and for each line fetch the project, switch to the specified branch"
	echo "and build it. Next, the version of that project in $RELEASER/target"
	echo "will be removed and replaced by the resulting artifacts of the build."
	echo
	echo "Next, anything in $RELEASER/target will be copied to $LR/deploy,"
	echo "after existing versions of the artifacts in $LR/osgi/war and modules"
	echo "have been removed. When cleaning up, nl-ou-dlwo-theme* will be"
	echo "disregarded, because nl-ou-dlwo-theme-etc* can also exist. Finally"
	echo "$LR/osgi/state will be removed."
	echo
	echo "Before using $0 make sure the variables on top of the script match"
	echo "your environment before executing the script!"
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
		removeNonOsgi $PROJECT
		moveToReleaser $PROJECT
	done < $BRANCHES_FILE
fi

cleanupLiferay

cp -v $WORKDIR/$RELEASER/target/* $LR/deploy

popd >/dev/null 2>&1

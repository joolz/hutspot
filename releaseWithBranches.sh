#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# location of the software repos
REPOS=ssh://bamboo://repositories/dlwo

# name of the releaser project
RELEASER=nl-ou-dlwo-releaser

# branch of the releaser project that should be used
RELEASERBRANCH=default

# file containing projects of which a non-standard changeset should be used. See usage()
BRANCHES_FILE=/home/jal/bin/branches.csv

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
	echo "Non-osgi jars will be removed and the remaining files copied to $DXPSERVERDIR/deploy. Existing versions of the artifacts in $DXPSERVERDIR/osgi/war and modules will removed and finally $DXPSERVERDIR/osgi/state will be removed."
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	usage
	exit 0
fi

# do it
liferayrunningcheck
WORKDIR=`mktemp -d`
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

cp -v $WORKDIR/$RELEASER/target/* $DXPSERVERDIR/deploy

rm -r $WORKDIR

popd >/dev/null 2>&1

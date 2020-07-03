#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# https://www.daharveyjr.com/convert-a-mercurial-repository-to-git-using-hg-fast-export/

function doIt() {
	pushd ${WORKDIR}/hg || exit 1
	hg clone ssh://bamboo//repositories/dlwo/${1}
	cd ${1} || exit 1
	HGBRANCHES=`hg branches | wc -l`
	HGTAGS=`hg tags | wc -l`
	popd

	pushd ${WORKDIR}/git || exit 1
	git init ${1} || exit 1
	cd ${1} || exit 1
	${WORKDIR}/fast-export/hg-fast-export.sh -r ~/Desktop/hg/${1} || exit 1
	pushd ${WORKDIR}/git/${1} || exit 1
	git checkout HEAD || exit 1
	GITBRANCHES=`git branch -a | wc -l`
	GITTAGS=`git tag -l`

	if [ ${HGBRANCHES} -ne ${GITBRANCHES} ]; then
		MESSAGE="WRONG NUMBER OF BRANCHES!! HGBRANCHES ${HGBRANCHES} -ne GITBRANCHES ${GITBRANCHES}"
		logger ${MESSAGE}
		confirm "${MESSAGE}. Do you want to continue anyway?"
	fi
	
	if [ ${HGTAGS} -ne ${GITTAGS} ]; then
		MESSAGE="WRONG NUMBER OF TAGS!! HGTAGS ${HGTAGS} -ne GIT ${GITTAGS}"
		logger ${MESSAGE}
		confirm "${MESSAGE}. Do you want to continue anyway?"
	fi
	
	git remote add origin https://dev.ou.nl/bitbucket/scm/youlearn/${1}.git || exit q
	git push --all || exit 1
	git push --tags || exit 1
	popd
	popd
}

WORKDIR=~/Desktop
cd ${WORKDIR} || exit 1
git config core.ignoreCase false

rm -rf ${WORKDIR}/hg
rm -rf ${WORKDIR}/git
rm -rf ${WORKDIR}/fast-export

mkdir ${WORKDIR}/hg || exit 1
mkdir ${WORKDIR}/git || exit 1
git clone git://repo.or.cz/fast-export.git || exit 1

doIt nl-ou-dlwo-releaser

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

# doIt amqsimulator
# doIt dxpdbupgradeserver
# doIt ephorus
# doIt nl-ou-dlwo-announcements
# doIt nl-ou-dlwo-backgroundtask
# doIt nl-ou-dlwo-batchregistration
# doIt nl-ou-dlwo-bridges
# doIt nl-ou-dlwo-chat
# doIt nl-ou-dlwo-ckeditor
# doIt nl-ou-dlwo-ckeditor-config
# doIt nl-ou-dlwo-ckeditor-plugins
# doIt nl-ou-dlwo-collaborate
# doIt nl-ou-dlwo-common
# doIt nl-ou-dlwo-control-menu
# doIt nl-ou-dlwo-control-panel-theme
# doIt nl-ou-dlwo-courseplan
# doIt nl-ou-dlwo-export-portlet
# doIt nl-ou-dlwo-groupchat
# doIt nl-ou-dlwo-groupwall
# doIt nl-ou-dlwo-header-filter-hook
# doIt nl-ou-dlwo-hyperlinks
# doIt nl-ou-dlwo-i19n
# doIt nl-ou-dlwo-layouttemplate
# doIt nl-ou-dlwo-layouttpl
# doIt nl-ou-dlwo-legacy-theme
# doIt nl-ou-dlwo-legacy-theme-control-menu
# doIt nl-ou-dlwo-maildigest
# doIt nl-ou-dlwo-maildigester
# doIt nl-ou-dlwo-main-theme
# doIt nl-ou-dlwo-mb-common
# doIt nl-ou-dlwo-menu
# doIt nl-ou-dlwo-pagecloaker
# doIt nl-ou-dlwo-pagestructure
# doIt nl-ou-dlwo-permissions-dlfolder
# doIt nl-ou-dlwo-plagiarism-checker-portlet
# doIt nl-ou-dlwo-portfolio
# doIt nl-ou-dlwo-products
# doIt nl-ou-dlwo-releaser
# doIt nl-ou-dlwo-releasetest
# doIt nl-ou-dlwo-sanitizer
# doIt nl-ou-dlwo-sitebuilder
# doIt nl-ou-dlwo-site-tools
# doIt nl-ou-dlwo-skeleton-portlet
# doIt nl-ou-dlwo-styleguide
# doIt nl-ou-dlwo-template-expandos
# doIt nl-ou-dlwo-tests-selenium
# doIt nl-ou-dlwo-tests-youlearn-cucumber
# doIt nl-ou-dlwo-test-theme
# doIt nl-ou-dlwo-theme
# doIt nl-ou-dlwo-theme-contributor
# doIt nl-ou-dlwo-theme-control-panel
# doIt nl-ou-dlwo-translations
# doIt nl-ou-dlwo-user-common
# doIt nl-ou-dlwo-userprofile-portlet
# doIt nl.ou.yl.account.preferences
# doIt nl.ou.yl.assessment
# doIt nl.ou.yl.domain
# doIt nl.ou.yl.jsf
# doIt nl.ou.yl.layouttemplate.knowledgeportal
# doIt nl.ou.yl.selftest
# doIt nl.ou.yl.siteexpandos
# doIt nl.ou.yl.templatesandsites
# doIt nl.ou.yl.theme.contributor.knowledgeportal
# doIt performance-test
# doIt scripts
# doIt tiles-portlet
# doIt youlearntemplateserver

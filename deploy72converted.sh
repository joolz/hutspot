#!/bin/bash

set -e

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

for REPO in \
	amqsimulator \
	nl-ou-dlwo-announcements \
	nl-ou-dlwo-bridges \
	nl-ou-dlwo-ckeditor-config \
	nl-ou-dlwo-ckeditor-plugins \
	nl-ou-dlwo-collaborate \
	nl-ou-dlwo-common \
	nl-ou-dlwo-control-menu \
	nl-ou-dlwo-courseplan \
	nl-ou-dlwo-groupchat \
	nl-ou-dlwo-groupwall \
	nl-ou-dlwo-layouttemplate \
	nl-ou-dlwo-maildigester \
	nl-ou-dlwo-mb-common \
	nl-ou-dlwo-menu \
	nl-ou-dlwo-pagecloaker \
	nl-ou-dlwo-pagestructure \
	nl-ou-dlwo-permissions-dlfolder \
	nl-ou-dlwo-products \
	nl-ou-dlwo-releaser \
	nl-ou-dlwo-sanitizer \
	nl-ou-dlwo-sitebuilder \
	nl-ou-dlwo-site-tools \
	nl-ou-dlwo-template-expandos \
	nl-ou-dlwo-theme \
	nl-ou-dlwo-theme-contributor \
	nl-ou-dlwo-theme-control-panel \
	nl-ou-dlwo-translations \
	nl-ou-dlwo-user-common \
	nl-ou-dlwo-userprofile-portlet \
	nl.ou.yl.account.preferences \
	nl.ou.yl.assessment \
	nl.ou.yl.domain \
	nl.ou.yl.editor.theme-contributor \
	nl.ou.yl.entities \
	nl.ou.yl.jsf \
	nl.ou.yl.layouttemplate.knowledgeportal \
	nl.ou.yl.messagebus \
	nl.ou.yl.messagetest \
	nl.ou.yl.selftest \
	nl.ou.yl.siteexpandos \
	nl.ou.yl.tasks \
	nl.ou.yl.templatesandsites \
	nl.ou.yl.theme.contributor.knowledgeportal \
	tiles-portlet
do
	pushd ~/workspace/${REPO}
	set +e
	ISCONVERTED=`hg branches | grep "${DXPBRANCHNAME}"`
	set -e
	if [ ! -z "${ISCONVERTED}" ]; then
		logger "${REPO} has branch ${DXPBRANCHNAME}, deploy it to the server"
		lrbuild.sh
	fi
	popd
done

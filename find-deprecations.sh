#!/bin/bash

rm ~/Desktop/deprecatedlog.log

for PROJECT in ck-source-issue nl-ou-dlwo-announcements nl-ou-dlwo-bridges nl-ou-dlwo-ckeditor-config nl-ou-dlwo-ckeditor-plugins nl-ou-dlwo-collaborate nl-ou-dlwo-common nl-ou-dlwo-control-menu nl-ou-dlwo-courseplan nl-ou-dlwo-groupchat nl-ou-dlwo-groupwall nl-ou-dlwo-layouttemplate nl-ou-dlwo-maildigester nl-ou-dlwo-pagecloaker nl-ou-dlwo-pagestructure nl-ou-dlwo-permissions-dlfolder nl-ou-dlwo-products nl-ou-dlwo-sanitizer nl-ou-dlwo-sitebuilder nl-ou-dlwo-site-tools nl-ou-dlwo-template-expandos nl-ou-dlwo-theme nl-ou-dlwo-theme-contributor nl-ou-dlwo-userprofile nl.ou.yl.account.preferences nl.ou.yl.assessment nl.ou.yl.domain nl.ou.yl.editor.theme-contributor nl.ou.yl.entities nl.ou.yl.jsf nl.ou.yl.layouttemplate.knowledgeportal nl.ou.yl.messagebus nl.ou.yl.messagetest nl.ou.yl.selftest nl.ou.yl.siteexpandos nl.ou.yl.tasks nl.ou.yl.theme.contributor.knowledgeportal tiles-portlet
do
	echo "====================================================================================" >> ~/Desktop/deprecatedlog.log
	echo $PROJECT >> ~/Desktop/deprecatedlog.log
	pushd ~/workspace/${PROJECT}
	lrbuild.sh
	popd
done

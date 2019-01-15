#!/bin/bash

source ~/bin/common.sh || exit 1

function doIt() {
	if [ -d $1 ]; then
		checkedPushd $1
		hg pull
		hg update -r default -C
		mvn clean
		popd
	else
		hg clone ssh://bamboo://repositories/dlwo/$1
	fi
}

test -d ~/tmp/alles || mkdir ~/tmp/alles
checkedPushd ~/tmp/alles

doIt nl-ou-dlwo-announcements
doIt nl-ou-dlwo-bridges
doIt nl-ou-dlwo-ckeditor-config
doIt nl-ou-dlwo-ckeditor-plugins
doIt nl-ou-dlwo-collaborate
doIt nl-ou-dlwo-control-menu
doIt nl-ou-dlwo-courseplan
doIt nl-ou-dlwo-groupchat
doIt nl-ou-dlwo-groupwall
doIt nl-ou-dlwo-layouttemplate
doIt nl-ou-dlwo-maildigester
doIt nl-ou-dlwo-menu
doIt nl-ou-dlwo-pagecloaker
doIt nl-ou-dlwo-pagestructure
doIt nl-ou-dlwo-releaser
doIt nl-ou-dlwo-products
doIt nl-ou-dlwo-sanitizer
doIt nl-ou-dlwo-template-expandos
doIt nl-ou-dlwo-theme
doIt nl-ou-dlwo-theme-contributor
doIt nl-ou-dlwo-theme-control-panel
doIt nl-ou-dlwo-translations
doIt nl-ou-dlwo-userprofile-portlet
doIt scripts

popd >/dev/null 2>&1

#!/bin/bash

function doIt() {
	if [ -d $1 ]; then
		pushd $1
		hg pull
		hg update -r default -C
		popd
	else
		hg clone ssh://bamboo://repositories/dlwo/$1
	fi
}

-d ~/tmp/alles || mkdir ~/tmp/alles
pushd ~/tmp/alles || exit 1

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
doIt nl-ou-dlwo-products
doIt nl-ou-dlwo-sanitizer-hook
doIt nl-ou-dlwo-template-expandos
doIt nl-ou-dlwo-theme
doIt nl-ou-dlwo-theme-contributor
doIt nl-ou-dlwo-theme-control-panel
doIt nl-ou-dlwo-translations
doIt nl-ou-dlwo-userprofile-portlet

popd

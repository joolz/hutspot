#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

declare -a PROJECTS=( \
	"nl-ou-dlwo-announcements" \
	"nl-ou-dlwo-ckeditor" \
	"nl-ou-dlwo-collaborate" \
	"nl-ou-dlwo-control-panel-theme" \
	"nl-ou-dlwo-courseplan" \
	"nl-ou-dlwo-groupchat" \
	"nl-ou-dlwo-groupwall" \
	"nl-ou-dlwo-layouttpl" \
	"nl-ou-dlwo-maildigester" \
	"nl-ou-dlwo-main-theme" \
	"nl-ou-dlwo-pagecloaker" \
	"nl-ou-dlwo-pagestructure" \
	"nl-ou-dlwo-portfolio" \
	"nl-ou-dlwo-products" \
	"nl-ou-dlwo-sanitizer" \
	"nl-ou-dlwo-template-expandos" \
	"nl-ou-dlwo-translations" \
	"nl-ou-dlwo-userprofile" \
	)

checkedPushd ~/Desktop

mkdir tempdeploy
cd tempdeploy

for I in "${PROJECTS[@]}"
do
	echo Clone ssh://bamboo://repositories/dlwo/$I
	hg clone ssh://bamboo://repositories/dlwo/$I
	checkedPushd pushd $I
	mvn clean
	mvn package
	mvn liferay:deploy
	popd >/dev/null 2>&1
done

popd >/dev/null 2>&1

#!/bin/bash

source ~/bin/common.sh || exit 1

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
cd tempdeploy || exit 1

for I in "${PROJECTS[@]}"
do
	echo Clone ssh://bamboo://repositories/dlwo/$I
	hg clone ssh://bamboo://repositories/dlwo/$I || exit 1
	checkedPushd pushd $I
	mvn clean || exit 1
	mvn package || exit 1
	mvn liferay:deploy || exit 1
	popd >/dev/null 2>&1
done

popd >/dev/null 2>&1
doneMessage

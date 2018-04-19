#!/bin/bash

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

pushd ~/Desktop

mkdir tempdeploy
cd tempdeploy || exit 1

for I in "${PROJECTS[@]}"
do
	echo Clone ssh://bamboo://repositories/dlwo/$I
	hg clone ssh://bamboo://repositories/dlwo/$I || exit 1
	pushd $I || exit 1
	mvn clean || exit 1
	mvn package || exit 1
	mvn liferay:deploy || exit 1
	popd
done

popd

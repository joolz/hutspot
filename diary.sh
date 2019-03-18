#!/bin/bash

source ~/bin/common.sh || exit 1

DIARYBASE=~/Nextcloud/diary
YEAR=`date +%Y`
WEEK=`date +%V` # https://stackoverflow.com/questions/19113732/cenos-shows-incorrect-week-number

DAY_OF_WEEK=`date +%u`
PREVIOUS_WEEK=`date -d 'last week' +%V`
PREVIOUS_YEAR=`date -d 'last week' +%Y`

mkdir -p $DIARYBASE/$YEAR || exit 1

DIARY=${DIARYBASE}/${YEAR}/${YEAR}_week_${WEEK}.md
PREVIOUS_DIARY=${DIARYBASE}/${PREVIOUS_YEAR}/${PREVIOUS_YEAR}_week_${PREVIOUS_WEEK}.md

if [ "$DAY_OF_WEEK" == "1" ]; then
	vi -o $PREVIOUS_DIARY $DIARY
else
	vi $DIARY
fi


#!/bin/bash

source ~/bin/common.sh || exit 1

DIARYBASE=~/Nextcloud/diary
YEAR=`date +%Y`
WEEK=`date +%V` # https://stackoverflow.com/questions/19113732/cenos-shows-incorrect-week-number

mkdir -p $DIARYBASE/$YEAR || exit 1

DIARY=${DIARYBASE}/${YEAR}/${YEAR}_week_${WEEK}.md

vi $DIARY

#!/bin/bash

source ~/bin/common.sh || exit 1

find ${NEXTCLOUDDIR} -iname "*conflicted copy*" -exec rm -iv {} \;

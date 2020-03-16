#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

hasBom $1 && echo yes

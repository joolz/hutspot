#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

hasBom $1 && echo yes

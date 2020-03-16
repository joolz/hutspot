#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# generate a small jpg called 1.0 in directory $1 (e.g. /opt/dxp/server/data/document_library/0/0/103565119.jpg)

mkdir -p $1
cd $1
convert -size 100x100 xc: +noise Random noise.jpg
mv noise.jpg 1.0

echo Generated random image $1/1.0

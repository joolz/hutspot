#!/bin/bash

out=${1%.*}-shadow.${1#*.}
in=$1
echo "Convert file : $out"
if [ ! -z $2 ] ; then 
  convert $in -frame $2 $out
  in=$out
fi
convert $in \( +clone -background black -shadow 60x5+10+10 \) \
  +swap -background white -layers merge +repage $out

#!/bin/bash

if [ "$1" == "" ]; then
  echo Usage: $0 file-to-search-for [zip-archive-format]
  exit 1
fi

if [ "$2" == "" ]; then
  ARCHIVE_FORMAT=zip
else
  ARCHIVE_FORMAT=$2
fi

echo Search for $1 in $ARCHIVE_FORMAT files

for I in *.$ARCHIVE_FORMAT; do 
  grep -oP "$1" <(unzip -l "$I") && echo "Found in $I";
done

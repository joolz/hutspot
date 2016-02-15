#!/bin/bash

if [ "$1" == "" ]; then
  echo Create maven dir stucture according to
  echo https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html
  echo
  echo Usage: $0 directoryname
  exit 1
fi

mkdir $1 || exit 1
cd $1

mkdir -p src/main/java
mkdir -p src/main/resources
mkdir -p src/main/filters
mkdir -p src/main/assembly
mkdir -p src/main/config
mkdir -p src/main/scripts
mkdir -p src/main/webapp
mkdir -p src/test/java
mkdir -p src/test/resources
mkdir -p src/test/filters
mkdir -p src/site
mkdir target
touch pom.xml
touch LICENSE.txt
touch NOTICE.txt
touch README.txt


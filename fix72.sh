#!/bin/bash

~/bin/setdependencies.sh /home/jal/bin/72artefacts.txt

# code replacements
CODEREPLACEMENTSFILE="/home/jal/bin/72codereplacements.txt"
while IFS='=' read -r KEY VALUE; do
	find . -type f -name "*.java" -exec sed -i -e "s/${KEY}/${VALUE}/g" {} \;
	find . -type f -name "*.jsp?" -exec sed -i -e "s/${KEY}/${VALUE}/g" {} \;
done < "$CODEREPLACEMENTSFILE"

XMLREPLACEMENTSFILE="/home/jal/bin/72xmlreplacements.txt"
while IFS='=' read -r KEY VALUE; do
	find . -type f -name "*.xml" -exec sed -i -e "s/${KEY}/${VALUE}/g" {} \;
done < "$XMLREPLACEMENTSFILE"


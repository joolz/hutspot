#!/bin/bash

BRANCH=`hg branch`

hg -y merge --tool=internal:fail default
hg revert --all --rev .
hg resolve -a -m
find . -name "*.orig"  -exec rm {} \;
hg commit -m "Merge default to dxp branch"
hg up default
hg merge $BRANCH
hg commit -m "Merge dxp branch to default"

echo "Now dirdiff this directory (default branch) with $BRANCH in old directory"
echo "If no differences are found, hg push in this directory, release the project and update nl-ou-dlwo-releaser to use the new release version of this project."

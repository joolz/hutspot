#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

TEMPDIR=`mktemp -d`

pushd ${TEMPDIR} || exit 1

mkdir two
pushd two
hg clone ssh://bamboo://repositories/dlwo/$RELEASER
cd $RELEASER
hg up two
popd

mkdir default
pushd default
hg clone ssh://bamboo://repositories/dlwo/$RELEASER
cd $RELEASER
hg up default
popd

echo "Now, merge versions from two to default and save"
keytocontinue
meld two/${RELEASER}/pom.xml default/${RELEASER}/pom.xml
keytocontinue

echo "Nerge release notes and save"
keytocontinue
meld two/${RELEASER}/info/release-notes.txt default/${RELEASER}/info/release-notes.txt
keytocontinue

pushd default/${RELEASER}
mvn clean package || exit 1
echo "Default seems OK, will now commit and push"
keytocontinue
hg commit -m "After pre-release merge for yOUlearn version $1" || exit 1
hg push
popd

rm -rf ${TEMPDIR}

echo "All done, now go to a server and do https://confluence.ou.nl/display/DTS/het+maken+van+een+yOUlearn+release#hetmakenvaneenyOUlearnrelease-ReleasenaardeAWO'senverder."

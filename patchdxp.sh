#!/bin/bash

sudocheck

PT=patching-tool
REPO=ssh://bamboo://repositories/dlwo/$PT

pushd $DXPSERVERDIR || exit 1

if [ -d "${PT}/.hg" ]; then
	confirm "${PT}/.hg exists. Remove local changes and update from repo?"
	sudo chown -R jal $PT
	pushd $PT
	hg pull
	hg update -r default -C
	hg purge
	popd
	sudo chown -R tomcat:tomcat $PT
else
	confirm "${PT}/.hg does not exist. Remove current dir and clone from repo?"
	sudo rm -rf $PT
	sudo mkdir $PT
	sudo chown jal $PT
	hg clone $REPO ${PT}/
	sudo chown -R tomcat:tomcat $PT
fi

confirm "Install the patches?"
liferayrunningcheck

cd ${DXPSERVERDIR}/${PT} || exit 1
sudo -u tomcat ./${PT}.sh install

popd

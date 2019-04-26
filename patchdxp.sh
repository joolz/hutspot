#!/bin/bash

source ~/bin/common.sh || exit 1

sudocheck

PT=patching-tool
REPO=ssh://bamboo://repositories/dlwo/$PT

checkedPushd $DXPSERVERDIR

if [ -d "${PT}/.hg" ]; then
	confirm "${PT}/.hg exists. Remove local changes and update from repo?"
	sudo chown -R jal $PT
	pushd $PT
	hg pull
	hg update -r default -C
	hg purge
	popd >/dev/null 2>&1
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

popd >/dev/null 2>&1
doneMessage

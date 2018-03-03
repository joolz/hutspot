#!/bin/bash

REQUIRED_PATCHES=liferay-fix-pack-de-39-7010.zip

function confirm() {
	echo $1 [yn]
	read -s -n 1 GOODTOGO
	if [ "$GOODTOGO" != "y" ]; then
		echo Bye
		exit 0
	fi
}

confirm "Did you read https://customer.liferay.com/documentation/7.0/deploy/-/official_documentation/deployment/preparing-an-upgrade-to-liferay-7 ?"
confirm "Did you run deleteOrphanedDDMTemplates.groovy in 6.2 ?"
confirm "Did you run clean_journalarticleimage.groovy in 6.2 ?"
confirm "Did you install Liferay OAuth Provider 7.0.x-20170222.lpkg in DXP ?"
confirm "Patch(es) $REQUIRED_PATCHES are installed ?"
confirm "After the upgrade has completed, do upgrade:check in the gogo shell. Press y to start the upgrade"

DXPDIR=/opt/dxp/server
UPGRADEDIR=$DXPDIR/tools/portal-tools-db-upgrade-client
IXMNGRFILE=$DXPDIR/osgi/configs/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.cfg
IXPROPERTYTRUE="indexReadOnly=true"
LOG=`date +%Y%m%d-%H%M-dxpdbupgrade.log`
GCLOG=`date +%Y%m%d-%H%M-gc.log`

# just check if they're there. Make sure they are installed as well
PATCHDIR=$DXPDIR/patching-tool/patches

cd $PATCHDIR || exit 1

OLDIFS=$IFS
IFS=","
for I in $REQUIRED_PATCHES; do
	if [ ! -f $I ]; then
		echo Patch $I not found, exiting
		exit 1
	fi
done
IFS=$OLDIFS

cd $UPGRADEDIR || exit 1

if [ -f $IXMNGRFILE ]; then
	PRESENT=`grep $IXPROPERTYTRUE $IXMNGRFILE`
	if [ -z $PRESENT ]; then
		echo $IXPROPERTYTRUE >> $IXMNGRFILE
	fi
else
	echo $IXPROPERTYTRUE > $IXMNGRFILE
fi

rm -r $DXPDIR/osgi/state

# see https://customer.liferay.com/documentation/7.0/deploy/-/official_documentation/deployment/running-the-upgrade-process
java -jar com.liferay.portal.tools.db.upgrade.client.jar \
	-j "-Dfile.encoding=UTF8 -Duser.country=NL -Duser.language=nl -Duser.timezone=CET -Xmx10240m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGC -Xloggc:$GCLOG " -l $LOG

sed -i "s/$IXPROPERTYTRUE//" $IXMNGRFILE

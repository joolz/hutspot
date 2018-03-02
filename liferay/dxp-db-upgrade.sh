#!/bin/bash

echo Did you run deleteOrphanedDDMTemplates.groovy in 6.2 ? [yn]
read -s -n 1 GOODTOGO
if [ "$GOODTOGO" != "y" ]; then
	echo Do that first please
	exit 0
fi

echo Did you run clean_journalarticleimage.groovy in 6.2 ? [yn]
read -s -n 1 GOODTOGO
if [ "$GOODTOGO" != "y" ]; then
	echo Do that first please
	exit 0
fi

echo Did you install Liferay OAuth Provider 7.0.x-20170222.lpkg in DXP ? [yn]
read -s -n 1 GOODTOGO
if [ "$GOODTOGO" != "y" ]; then
	echo Do that first please
	exit 0
fi

DXPDIR=/opt/dxp/server
UPGRADEDIR=$DXPDIR/tools/portal-tools-db-upgrade-client
IXMNGRFILE=$DXPDIR/osgi/configs/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.cfg
IXPROPERTYTRUE="indexReadOnly=true"
LOG=`date +%Y%m%d-%H%M-dxpdbupgrade.log`
GCLOG=`date +%Y%m%d-%H%M-gc.log`

# just check if they're there. Make sure they are installed as well
PATCHDIR=$DXPDIR/patching-tool/patches
REQUIRED_PATCHES=liferay-fix-pack-de-39-7010.zip

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

echo "All patches seem to be present ($REQUIRED_PATCHES), make sure they're installed properly"

cd $UPGRADEDIR || exit 1

# see https://customer.liferay.com/documentation/7.0/deploy/-/official_documentation/deployment/preparing-an-upgrade-to-liferay-7
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

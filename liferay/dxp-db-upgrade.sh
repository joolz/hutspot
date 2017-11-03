#!/bin/bash

DXPDIR=/opt/dxp/server
UPGRADEDIR=$DXPDIR/tools/portal-tools-db-upgrade-client
IXMNGRFILE=$DXPDIR/osgi/configs/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.cfg
IXPROPERTYTRUE="indexReadOnly=true"
LOG=`date +%Y%m%d-%H%M-dxpdbupgrade.log`

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
	-j "-Dfile.encoding=UTF8 -Duser.country=NL -Duser.language=nl -Duser.timezone=CET -Xmx4096m" -l $LOG

sed -i "s/$IXPROPERTYTRUE//" $IXMNGRFILE

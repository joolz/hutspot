#!/bin/bash

# Script to do the database upgrade from 6.2 to DXP. This includes
# remove the old db upgrademe and importing the dump from the
# production database. Logging will end up in $DXPLOGDIR/general.log

. ~/bin/common.sh

UPGRADEDIR=$DXPSERVERDIR/tools/portal-tools-db-upgrade-client
IXMNGRFILE=$DXPSERVERDIR/osgi/configs/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.cfg
IXPROPERTYTRUE="indexReadOnly=true"
LOG=`date +%Y%m%d-%H%M-dxpdbupgrade.log`
GCLOG=`date +%Y%m%d-%H%M-gc.log`

cd $UPGRADEDIR || exit 1

dxplog "Set $IXPROPERTYTRUE in $IXMNGRFILE"
if [ -f $IXMNGRFILE ]; then
	PRESENT=`grep $IXPROPERTYTRUE $IXMNGRFILE`
	if [ -z $PRESENT ]; then
		echo $IXPROPERTYTRUE >> $IXMNGRFILE
	fi
else
	echo $IXPROPERTYTRUE > $IXMNGRFILE
fi

dxplog "Remove $DXPSERVERDIR/osgi/state"
rm -r $DXPSERVERDIR/osgi/state

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-100
dxplog "Clean orphan journal article images"
SQL="
delete from JournalArticleImage 
	where articleId in
	(select articleId from
	(select * from
	(SELECT articleImageId, groupId, articleId, version, elInstanceId, elName, languageId, tempImage, COUNT(*)
	AS duplicates FROM JournalArticleImage
	group by groupId, articleId, version, elName, languageId) as temp WHERE duplicates > 1) as temp2)
	AND elInstanceId like '';"
mysql --user="$DB_USER" --password="$DB_PASSWORD" \
	--database="$DB_SCHEMA" --execute="$SQL" || exit 1

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-90
dxplog "Delete orphan DDMTemplates"
SQL="
delete from DDMTemplate where classNameId = (select classNameId from
	ClassName_ where value =
	'com.liferay.portlet.dynamicdatamapping.model.DDMStructure') and
	classPK not in (select structureId from DDMStructure);"
mysql --user="$DB_USER" --password="$DB_PASSWORD" \
	--database="$DB_SCHEMA" --execute="$SQL" || exit 1

dxplog "Start the database upgrade process. After the upgrade has completed, do upgrade:check in the gogo shell."
START=$SECONDS
java -jar com.liferay.portal.tools.db.upgrade.client.jar \
	-j "-Dfile.encoding=UTF8 -Duser.country=NL -Duser.language=nl -Duser.timezone=CET -Xmx10240m -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGC -Xloggc:$DXPLOGDIR/$GCLOG -Djava.io.tmpdir=$TMP " \
	-l $DXPLOGDIR/$LOG

SUCCESS=$?

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

dxplog "Finished the database upgrade process with error level $SUCCESS in $DURATIONREADABLE"

if [ $SUCCESS == 0 ]; then
	db_dump.sh
fi

sed -i "s/$IXPROPERTYTRUE//" $IXMNGRFILE

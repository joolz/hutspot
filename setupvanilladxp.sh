#!/bin/bash

# Script to install a vanilla DXP with some patches and upgrades.This
# installation is intended to be used for the database upgrade from
# 6.2 to DXP. Logging will end up in $DXPLOGDIR/general.log

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

if [ -d "$DXPSERVERDIR" ]; then
	echo $DXPSERVERDIR already exists, exiting.
	exit 1
fi

SERVERZIP=liferay-dxp-digital-enterprise-tomcat-7.0-sp4-20170705142422877.zip
ACTIVATIONKEY="$DXPDOWNLOADSDIR/activation-key-new yearly digitalenterprisedevelopment-7.0-openuniversitynetherlandsyoulearnexdlwo.xml"

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-90
OATHPROVIDER="$DXPDOWNLOADSDIR/Liferay OAuth Provider 7.0.x-20170222.lpkg"

MYSQLJAR=$DXPDOWNLOADSDIR/mysql.jar
GEOLITEDATA=$DXPDOWNLOADSDIR/GeoLiteCity.dat
SETENV=$SERVER/tomcat-8.0.32/bin/setenv.sh

PATCHINGTOOL=$DXPDOWNLOADSDIR/patching-tool-2.0.7.zip
PROPS=$DXPSERVERDIR/portal-ext.properties
TOMCATDIR=$DXPSERVERDIR/tomcat-8.0.32
WEBXML=$TOMCATDIR/webapps/ROOT/WEB-INF/web.xml
SETENV=$TOMCATDIR/bin/setenv.sh
ROOTCLASSESDIR=$TOMCATDIR/webapps/ROOT/WEB-INF/classes
SYSTEMPROPS=$ROOTCLASSESDIR/system-ext.properties

dxplog "Start installing vanilla DXP in $DXPSERVERDIR"
START=$SECONDS

cd $DXPBASEDIR

unzip $DXPDOWNLOADSDIR/$SERVERZIP -d $DXPBASEDIR || exit 1

cd $DXPSERVERDIR || exit 1

cp $MYSQLJAR tomcat-8.0.32/lib/ext/
mkdir tomcat-8.0.32/lib/ext/global
rm tomcat-8.0.32/bin/*bat

# see
# https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109
# and
# https://customer.liferay.com/documentation/knowledge-base/-/kb/1086550
mkdir -p $DXPSERVERDIR/geoip
cp $GEOLITEDATA $DXPSERVERDIR/geoip
mkdir -p $DXPSERVERDIR/osgi/configs
echo "filePath=$DXPSERVERDIR/geoip/GeoLiteCity.dat" \
	>| $DXPSERVERDIR/osgi/configs/com.liferay.ip.geocoder.internal.IPGeocoderConfiguration.cfg

dxplog "Run patching tool"
rm -r patching-tool
unzip $PATCHINGTOOL -d .
cd patching-tool || exit 1
mkdir -p patches
cp $DXPPATCHESDIR/* patches/ || exit 1

./patching-tool.sh auto-discovery
sed -i "s/java $PT_OPTS/java -Djava.io.tmpdir=\/opt\/dxp\/tmp $PT_OPTS/g" ./patching-tool.sh
./patching-tool.sh install

cd $DXPSERVERDIR || exit 1
mkdir deploy
cp -v "$ACTIVATIONKEY" deploy/
cp -v "$OATHPROVIDER" deploy/

echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dfile.encoding=UTF8\"" >| $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Djava.net.preferIPv4Stack=true\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Duser.timezone=Europe/Amsterdam\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Xmx3072m\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -XX:MaxPermSize=1024m\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttp.proxyHost=mail.lokaal\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttp.proxyPort=80\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttps.proxyHost=mail.lokaal\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttps.proxyPort=80\"" >> $SETENV

cp $DXPDOWNLOADSDIR/app-server.properties $DXPSERVERDIR/tools/portal-tools-db-upgrade-client
cp $DXPDOWNLOADSDIR/portal-upgrade-database.properties $DXPSERVERDIR/tools/portal-tools-db-upgrade-client
cp $DXPDOWNLOADSDIR/portal-upgrade-ext.properties $DXPSERVERDIR/tools/portal-tools-db-upgrade-client

dxplog "Write temporary portal-ext, points to $DB_TEMP_SCHEMA"
echo "jdbc.default.driverClassName=com.mysql.jdbc.Driver" >| $PROPS
echo "jdbc.default.url=jdbc:mysql://$DXPUPGRADE_DB_HOST/$DB_TEMP_SCHEMA?useUnicode=true&amp;characterEncoding=UTF-8&amp;useFastDateParsing=false" >> $PROPS
echo "jdbc.default.username=$LOCAL_DB_USER" >> $PROPS
echo "jdbc.default.password=$LOCAL_DB_PASSWORD" >> $PROPS

dxplog "Create schema $DB_TEMP_SCHEMA"
mysql --user="$LOCAL_DB_USER" --password="$LOCAL_DB_PASSWORD" \
	--execute="DROP DATABASE IF EXISTS $DB_TEMP_SCHEMA;" || exit 1
mysql --user="$LOCAL_DB_USER" --password="$LOCAL_DB_PASSWORD" \
	--execute="CREATE DATABASE $DB_TEMP_SCHEMA DEFAULT CHARACTER SET $DB_CHARACTER_SET DEFAULT COLLATE $DB_DEFAULT_COLLATE;" || exit 1

dxplog "Wait for tomcat start to complete for the first time"
$TOMCATDIR/bin/startup.sh
dxplog "Sleep $SLEEP_LONG so tomcat startup can complete"
sleep $SLEEP_LONG
$TOMCATDIR/bin/shutdown.sh
dxplog "Sleep $SLEEP_SHORT so tomcat shutdown can complete"
sleep $SLEEP_SHORT

dxplog "Wait for tomcat to be started again"
$TOMCATDIR/bin/startup.sh
dxplog "Sleep $SLEEP_LONG so tomcat startup can complete"
sleep $SLEEP_LONG
$TOMCATDIR/bin/shutdown.sh
dxplog "Sleep $SLEEP_SHORT so tomcat shutdown can complete"
sleep $SLEEP_SHORT

dxplog "Drop schema $DB_TEMP_SCHEMA"
mysql --user="$LOCAL_DB_USER" --password="$LOCAL_DB_PASSWORD" \
	--execute="DROP DATABASE IF EXISTS $DB_TEMP_SCHEMA;" || exit 1

dxplog "Write final portal-ext, $DB_SCHEMA"
echo "jdbc.default.driverClassName=com.mysql.jdbc.Driver" >| $PROPS
echo "jdbc.default.url=jdbc:mysql://$DXPUPGRADE_DB_HOST/$DB_SCHEMA?useUnicode=true&amp;characterEncoding=UTF-8&amp;useFastDateParsing=false" >> $PROPS
echo "jdbc.default.username=$DXPUPGRADE_DB_USER" >> $PROPS
echo "jdbc.default.password=$DXPUPGRADE_DB_PASSWORD" >> $PROPS
echo "" >> $PROPS
echo "locales=nl_NL,en_US,en_GB" >> $PROPS
echo "locales.enabled=nl_NL,en_US,en_GB" >> $PROPS

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109/comment/105976486
mkdir -p $ROOTCLASSESDIR || exit 1
dxplog "Write $SYSTEMPROPS"
echo "user.language=nl" >> $SYSTEMPROPS
echo "user.country=NL"  >> $SYSTEMPROPS

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

dxplog "Save directory contents and settings to $SCRIPT_DIR so it will be part of the hg repo"
ls -Rl --color=never $DXPBASEDIR >| $SCRIPT_DIR/dxpdircontent.txt
cp $MYSQL_HOME/my.cnf $SCRIPT_DIR

dxplog "Finished installing vanilla DXP in $DXPSERVERDIR in $DURATIONREADABLE"
dxplog "DO NOT START DXP UNTIL THE DATABASE CONVERSION HAS BEEN DONE"

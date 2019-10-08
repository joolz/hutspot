#!/bin/bash

# Script to install a vanilla DXP with some patches and upgrades.This
# installation is intended to be used for the database upgrade from
# 6.2 to DXP. Logging will end up in $DXPLOGDIR/general.log

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

# ACTIVATIONKEY="$DXPDOWNLOADSDIR/activation-key-digitalenterprisedevelopment-7.0-openuniversitynetherlandsyoulearn10IPs.xml"
ACTIVATIONKEY="$DXPDOWNLOADSDIR/activation-key-digitalenterprisedevelopment-7.0-openuniversiteitnetherlands.xml"

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-90
OATHPROVIDER="$DXPDOWNLOADSDIR/Liferay OAuth Provider 7.0.x-20170222.lpkg"

MYSQLJAR=$DXPDOWNLOADSDIR/mysql.jar
GEOLITEDATA=$DXPDOWNLOADSDIR/GeoLiteCity.dat
SETENV=$SERVER/tomcat-8.0.32/bin/setenv.sh

PATCHINGTOOL=$DXPDOWNLOADSDIR/patching-tool-2.0.12.zip
PROPS=$DXPSERVERDIR/portal-ext.properties
TOMCATDIR=$DXPSERVERDIR/tomcat-8.0.32
WEBXML=$TOMCATDIR/webapps/ROOT/WEB-INF/web.xml
SETENV=$TOMCATDIR/bin/setenv.sh
ROOTCLASSESDIR=$TOMCATDIR/webapps/ROOT/WEB-INF/classes
SYSTEMPROPS=$ROOTCLASSESDIR/system-ext.properties

logger "Remove own snapshots from Maven repo"
find ~/tmp/m2_repository -type f -name "nl*SNAPSHOT*" -exec rm -v {} \;

logger "Start installing vanilla DXP in $DXPSERVERDIR"
START=$SECONDS

cd $DXPBASEDIR

logger "Remove existing sources, unzip and create link"
rm -f $DXPSOURCEDIR
rm -rf $DXPSOURCEPHYSICALDIR
unzip $DXPDOWNLOADSDIR/$DXPSOURCEZIP -d $DXPBASEDIR || exit 1
ln -s $DXPSOURCEPHYSICALDIR $DXPSOURCEDIR || exit 1

logger "Remove existing server, unzip and link"
rm -f $DXPSERVERDIR
rm -rf $DXPSERVERPHYSICALDIR
unzip $DXPDOWNLOADSDIR/$DXPSERVERZIP -d $DXPBASEDIR || exit 1
ln -s $DXPSERVERPHYSICALDIR $DXPSERVERDIR || exit 1

cd $DXPSERVERDIR || exit 1
ln -s $NEXTCLOUDDIR/beheer/accounts/portal-ext.properties .

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

logger "Link document library"
rm -rf $DXPSERVERDIR/data/document_library
ln -s $DXPDOWNLOADSDIR/document_library $DXPSERVERDIR/data/document_library

logger "Install patching tool"
rm -r patching-tool
unzip "$PATCHINGTOOL" -d .
cd patching-tool || exit 1
mkdir -p patches

# Due to a bug, server- and source-patches must be installed
# separately and both need a file called default.properties

logger "Patch sources"
rm -f default.properties || exit 1
cp $DXPPATCHESDIR/source.properties . || exit 1
mv source.properties default.properties || exit 1
cp $DXPPATCHESDIR/$DXPPATCHLEVEL/source/* patches/
cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
./patching-tool.sh install

logger "Patch server"
rm -f default.properties || exit 1
cp $DXPPATCHESDIR/default.properties . || exit 1
rm patches/* || exit 1
cp $DXPPATCHESDIR/$DXPPATCHLEVEL/binary/* patches/ || exit 1
cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
./patching-tool.sh install

logger "Copy license"
cd $DXPSERVERDIR || exit 1
mkdir -p deploy || exit 1
cp -v "$ACTIVATIONKEY" deploy/
cp -v "$OATHPROVIDER" deploy/

mkdir -p osgi/modules
mkdir -p osgi/war

logger "Make $SETENV"
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dfile.encoding=UTF8\"" >| $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Djava.net.preferIPv4Stack=true\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dorg.apache.catalina.loader.WebappClassLoader.ENABLE_CLEAR_REFERENCES=false\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Duser.timezone=GMT\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Xmx3072m\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -XX:MaxPermSize=1024m\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttp.proxyHost=mail.lokaal\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttp.proxyPort=80\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttps.proxyHost=mail.lokaal\"" >> $SETENV
echo "CATALINA_OPTS=\"$CATALINA_OPTS -Dhttps.proxyPort=80\"" >> $SETENV

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

logger "Finished installing vanilla DXP in $DXPSERVERDIR in $DURATIONREADABLE"
doneMessage

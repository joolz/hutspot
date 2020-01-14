#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

ACTIVATIONKEY="$DXPDOWNLOADSDIR/activation-key-digitalenterprisedevelopment-7.0-openuniversiteitnetherlands.xml"

MYSQLJAR=$DXPDOWNLOADSDIR/mysql.jar
XUGGLER=$DXPDOWNLOADSDIR/xuggle-xuggler-arch-x86_64-pc-linux-gnu.jar
GEOLITEDATA=$DXPDOWNLOADSDIR/GeoLiteCity.dat

PATCHINGTOOL=$DXPDOWNLOADSDIR/"Patching Tool 2.0.15.zip"
PROPS=$DXP72SERVERDIR/portal-ext.properties
TOMCATDIR=$DXP72SERVERDIR/tomcat-9.0.17
SETENV=$TOMCATDIR/bin/setenv.sh
ROOTDIR=$TOMCATDIR/webapps/ROOT
WEBXML=$ROOTDIR/WEB-INF/web.xml
ROOTCLASSESDIR=$ROOTDIR/WEB-INF/classes
ROOTLIBDIR=$ROOTDIR/WEB-INF/lib

logger "Start installing vanilla DXP 7.2 in $DXP72SERVERDIR"
START=$SECONDS

cd $DXP72BASEDIR

# logger "Remove existing sources, unzip and create link"
# rm -f $DXP72SOURCEDIR
# rm -rf $DXP72SOURCEPHYSICALDIR
# unzip $DXP72DOWNLOADSDIR/$DXP72SOURCEZIP -d $DXP72BASEDIR
# ln -s $DXP72SOURCEPHYSICALDIR $DXP72SOURCEDIR

logger "Remove existing server, unzip and link"
rm -f $DXP72SERVERDIR
rm -rf $DXP72SERVERPHYSICALDIR
tar -xvf $DXP72DOWNLOADSDIR/$DXP72SERVERZIP || exit 1
ln -s $DXP72SERVERPHYSICALDIR $DXP72SERVERDIR

cd $DXP72SERVERDIR
ln -s $NEXTCLOUDDIR/beheer/accounts/portal-ext72.properties portal-ext.properties

cp $MYSQLJAR $TOMCATDIR/lib/ext/
mkdir $TOMCATDIR/lib/ext/global
rm $TOMCATDIR/bin/*bat

mkdir -p $ROOTLIBDIR
cp $XUGGLER $ROOTLIBDIR

# see
# https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109
# and
# https://customer.liferay.com/documentation/knowledge-base/-/kb/1086550
mkdir -p $DXP72SERVERDIR/geoip
cp $GEOLITEDATA $DXP72SERVERDIR/geoip
mkdir -p $DXP72SERVERDIR/osgi/configs
echo "filePath=$DXP72SERVERDIR/geoip/GeoLiteCity.dat" \
	>| $DXP72SERVERDIR/osgi/configs/com.liferay.ip.geocoder.internal.IPGeocoderConfiguration.cfg

echo "service.disabled=true" \
	>| $DXP72SERVERDIR/osgi/configs/nl.ou.yl.kafka.client.impl.KafkaClientImpl.cfg

logger "Link document library"
rm -rf $DXP72SERVERDIR/data/document_library
ln -s $DXP72DOWNLOADSDIR/document_library $DXP72SERVERDIR/data/document_library

logger "Install patching tool"
rm -r patching-tool
unzip "$PATCHINGTOOL" -d .
cd patching-tool
mkdir -p patches

# Due to a bug, server- and source-patches must be installed
# separately and both need a file called default.properties
# TODO this might not be necessary anymore

logger "Patch sources"
rm -f default.properties
cp $DXP72PATCHESDIR/source.properties .
mv source.properties default.properties
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/source/* patches/
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* patches/
./patching-tool.sh install

logger "Patch server"
rm -f default.properties
cp $DXP72PATCHESDIR/default.properties .
rm patches/*
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/binary/* patches/
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* patches/
./patching-tool.sh install

logger "Copy license"
cd $DXP72SERVERDIR
mkdir -p deploy
cp -v "$ACTIVATIONKEY" deploy/

mkdir -p osgi/modules
mkdir -p osgi/war

logger "Make $SETENV"

echo 'CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF-8"' >| $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Djava.locale.providers=JRE,COMPAT,CLDR"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Djava.net.preferIPv4Stack=true"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Duser.timezone=GMT"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Xms2560m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Xmx2560m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MaxNewSize=1536m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MaxMetaspaceSize=768m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=768m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:NewSize=1536m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:SurvivorRatio=7"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttp.proxyHost=mail.lokaal"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttp.proxyPort=80"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyHost=mail.lokaal"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyPort=80"' >> $SETENV

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

logger "Finished installing vanilla DXP 7.2 in $DXP72SERVERDIR in $DURATIONREADABLE"

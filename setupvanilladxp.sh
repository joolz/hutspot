#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

for I in "$@"; do
	case $I in
		-n|--nosources)
			NOSOURCES=true
			;;
		*)
			;;
	esac
done

ACTIVATIONKEY="$DXPDOWNLOADSDIR/$DXPACTIVATIONKEY"

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-90
OATHPROVIDER="$DXPDOWNLOADSDIR/Liferay OAuth Provider 7.0.x-20170222.lpkg"

MYSQLJAR=$DXPDOWNLOADSDIR/mysql.jar
XUGGLER=$DXPDOWNLOADSDIR/xuggle-xuggler-arch-x86_64-pc-linux-gnu.jar
GEOLITEDATA=$DXPDOWNLOADSDIR/GeoLiteCity.dat

PATCHINGTOOL=$DXPDOWNLOADSDIR/"Patching Tool 2.0.15.zip"
PROPS=$DXPSERVERDIR/portal-ext.properties
TOMCATDIR=$DXPSERVERDIR/tomcat-8.0.32
SETENV=$TOMCATDIR/bin/setenv.sh
ROOTDIR=$TOMCATDIR/webapps/ROOT
WEBXML=$ROOTDIR/WEB-INF/web.xml
ROOTCLASSESDIR=$ROOTDIR/WEB-INF/classes
ROOTLIBDIR=$ROOTDIR/WEB-INF/lib

# logger "Remove own snapshots from Maven repo"
# find ~/tmp/m2_repository -type f -name "nl*SNAPSHOT*" -exec rm -v {} \;

logger "Start installing vanilla DXP in $DXPSERVERDIR"
START=$SECONDS

cd $DXPBASEDIR

if [ "$NOSOURCES" = true ]; then
	logger "Skip sources"
else
	logger "Remove existing sources, unzip and create link"
	rm -f $DXPSOURCEDIR
	rm -rf $DXPSOURCEPHYSICALDIR
	unzip $DXPDOWNLOADSDIR/$DXPSOURCEZIP -d $DXPBASEDIR
	ln -s $DXPSOURCEPHYSICALDIR $DXPSOURCEDIR
fi

logger "Remove existing server, unzip and link"
rm -f $DXPSERVERDIR
rm -rf $DXPSERVERPHYSICALDIR
unzip $DXPDOWNLOADSDIR/$DXPSERVERZIP -d $DXPBASEDIR
ln -s $DXPSERVERPHYSICALDIR $DXPSERVERDIR

cd $DXPSERVERDIR
ln -s $NEXTCLOUDDIR/beheer/accounts/portal-ext.properties .

logger "Pre-create some directories (deploy/ etc.)"
cd $DXPSERVERDIR
mkdir -p deploy
mkdir -p osgi/modules
mkdir -p osgi/war

logger "Copy $ACTIVATIONKEY and $OATHPROVIDER"
cp -v "$ACTIVATIONKEY" deploy/
cp -v "$OATHPROVIDER" deploy/

cp $MYSQLJAR tomcat-8.0.32/lib/ext/
mkdir tomcat-8.0.32/lib/ext/global
rm tomcat-8.0.32/bin/*bat

mkdir -p $ROOTLIBDIR
cp $XUGGLER $ROOTLIBDIR

# see
# https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109
# and
# https://customer.liferay.com/documentation/knowledge-base/-/kb/1086550
mkdir -p $DXPSERVERDIR/geoip
cp $GEOLITEDATA $DXPSERVERDIR/geoip
mkdir -p $DXPSERVERDIR/osgi/configs
echo "filePath=$DXPSERVERDIR/geoip/GeoLiteCity.dat" \
	>| $DXPSERVERDIR/osgi/configs/com.liferay.ip.geocoder.internal.IPGeocoderConfiguration.cfg

echo "service.disabled=true" \
	>| $DXPSERVERDIR/osgi/configs/nl.ou.yl.kafka.client.impl.KafkaClientImpl.cfg

logger "Link document library"
rm -rf $DXPSERVERDIR/data/document_library
ln -s $DXPDOWNLOADSDIR/document_library $DXPSERVERDIR/data/document_library

logger "Install patching tool"
rm -r patching-tool
unzip "$PATCHINGTOOL" -d .
cd patching-tool
mkdir -p patches

# Due to a bug, server- and source-patches must be installed
# separately and both need a file called default.properties

if [ -z "${DXPPATCHLEVEL}" ]; then
	logger "No patchlevel specified, so not applying any patches"
else
	if [ "$NOSOURCES" = true ]; then
		logger "Skip patching sources"
	else
		logger "Patch sources"
		rm -f default.properties
		cp $DXPPATCHESDIR/source.properties .
		mv source.properties default.properties
		cp $DXPPATCHESDIR/$DXPPATCHLEVEL/source/* patches/
		cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
		./patching-tool.sh install
	fi

	logger "Patch server"
	rm -f default.properties
	cp $DXPPATCHESDIR/default.properties .
	rm patches/*
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/binary/* patches/
	cp $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* patches/
	./patching-tool.sh install
fi

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

TIMEOUT=99
logger "Set timeout to $TIMEOUT"
. setdxptimeout.sh ${TIMEOUT}

logger "Add debug logging for some packages"
# addDebugLog "nl.ou.yl.diffsanitized"
# addDebugLog "nl.ou.dlwo.antisamy.internal"
addDebugLog "nl.ou.yl.serviceoverride"
addDebugLog "nl.ou.dlwo.export.service"

logger "Finished installing vanilla DXP in $DXPSERVERDIR in $DURATIONREADABLE"

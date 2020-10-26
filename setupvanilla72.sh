#!/bin/bash

set -e

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

ACTIVATIONKEY="$DXP72DOWNLOADSDIR/activation-key-digitalenterprisedevelopment-7.2-developeractivationkeys.xml"
XUGGLER=$DXP72DOWNLOADSDIR/xuggle-xuggler-arch-x86_64-pc-linux-gnu.jar
ES_CONNECTOR="$DXP72DOWNLOADSDIR/Liferay Connector to Elasticsearch 7.lpkg"
GEOLITEDATA=$DXP72DOWNLOADSDIR/GeoLiteCity.dat
INDEXREADONLYCONFIG=$DXP72DOWNLOADSDIR/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.config

if [ ! -f ${INDEXREADONLYCONFIG} ]; then
	echo "indexReadOnly=\"true\"" > ${INDEXREADONLYCONFIG}
fi

[[ -e "${ACTIVATIONKEY}" ]] && echo "${ACTIVATIONKEY} exists" || { echo "${ACTIVATIONKEY} not found" 1>&2 ; exit 1; }
[[ -e "${XUGGLER}" ]] && echo "${XUGGLER} exists" || { echo "${XUGGLER} not found" 1>&2 ; exit 1; }
[[ -e "${ES_CONNECTOR}" ]] && echo "${ES_CONNECTOR} exists" || { echo "${ES_CONNECTOR} not found" 1>&2 ; exit 1; }
[[ -e "${GEOLITEDATA}" ]] && echo "${GEOLITEDATA} exists" || { echo "${GEOLITEDATA} not found" 1>&2 ; exit 1; }
[[ -e "${INDEXREADONLYCONFIG}" ]] && echo "${INDEXREADONLYCONFIG} exists" || { echo "${INDEXREADONLYCONFIG} not found" 1>&2 ; exit 1; }

PROPS=$DXP72SERVERDIR/portal-ext.properties
SETENV=$DXP72TOMCATDIR/bin/setenv.sh
ROOTDIR=$DXP72TOMCATDIR/webapps/ROOT
WEBXML=$ROOTDIR/WEB-INF/web.xml
ROOTCLASSESDIR=$ROOTDIR/WEB-INF/classes
ROOTLIBDIR=$ROOTDIR/WEB-INF/lib
# DB_SCHEMA_72=dxp72
DB_SCHEMA_72=two

logger "Start installing vanilla DXP 7.2 in $DXP72SERVERDIR"
START=$SECONDS

cd $DXP72BASEDIR

logger "Remove existing sources, unzip and create link"
rm -f $DXP72SOURCEDIR
rm -rf $DXP72SOURCEPHYSICALDIR
unzip $DXP72DOWNLOADSDIR/$DXP72SOURCEZIP -d $DXP72BASEDIR
ln -s $DXP72SOURCEPHYSICALDIR $DXP72SOURCEDIR

logger "Remove existing server, unzip and link"
rm -f $DXP72SERVERDIR
rm -rf $DXP72SERVERPHYSICALDIR
tar -xvf $DXP72DOWNLOADSDIR/$DXP72SERVERZIP || exit 1
ln -s $DXP72SERVERPHYSICALDIR $DXP72SERVERDIR

cd $DXP72SERVERDIR
ln -s $NEXTCLOUDDIR/beheer/accounts/portal-ext72.properties portal-ext.properties

mkdir $DXP72TOMCATDIR/lib/ext/global
rm $DXP72TOMCATDIR/bin/*bat

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

# Due to a bug, server- and source-patches must be installed
# separately and both need a file called default.properties

logger "Patch sources"

# https://help.liferay.com/hc/en-us/requests/32659 Need to patch ReleaseInfo.java first, see https://help.liferay.com/hc/es/articles/360043206032--Problem-with-the-configuration-Unknown-release-in-folder-when-patching-the-source-code
cp -f ${DXP72DOWNLOADSDIR}/ReleaseInfo.java ${DXP72SOURCEDIR}/portal-kernel/src/com/liferay/portal/kernel/util/

rm -f default.properties
cp $DXP72PATCHESDIR/source.properties .
mv source.properties default.properties
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/source/* ${DXP72SERVERDIR}/patching-tool/patches/
# cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* ${DXP72SERVERDIR}/patching-tool/patches/
cd ${DXP72SERVERDIR}/patching-tool
./patching-tool.sh install
rm -rf ${DXP72SERVERDIR}/osgi/state

logger "Patch server"
rm -f default.properties
cp $DXP72PATCHESDIR/default.properties .
rm ${DXP72SERVERDIR}/patching-tool/patches/*
cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/binary/* ${DXP72SERVERDIR}/patching-tool/patches/
# cp $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* ${DXP72SERVERDIR}/patching-tool/patches/
cd ${DXP72SERVERDIR}/patching-tool
./patching-tool.sh install
rm -rf ${DXP72SERVERDIR}/osgi/state

logger "Copy license"
cd $DXP72SERVERDIR
mkdir -p deploy
cp -v "$ACTIVATIONKEY" deploy/

logger "Copy Elasticsearch connector"
cp -v "$ES_CONNECTOR" deploy/

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
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyPort=80"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyHost=mail.lokaal"' >> $SETENV

UPGRADEDIR=${DXP72SERVERDIR}/tools/portal-tools-db-upgrade-client
ASP=${UPGRADEDIR}/app-server.properties
PUDP=${UPGRADEDIR}/portal-upgrade-database.properties
PUEP=${UPGRADEDIR}/portal-upgrade-ext.properties
UW=${UPGRADEDIR}/upgradewrapper.sh

logger "Make upgradescript $ASP"
echo "dir=/" >| $ASP
echo "extra.lib.dirs=${DXP72TOMCATDIR}/bin" >> $ASP
echo "global.lib.dir=${DXP72TOMCATDIR}/lib" >> $ASP
echo "portal.dir=${DXP72TOMCATDIR}/webapps/ROOT" >> $ASP
echo "server.detector.server.id=tomcat" >> $ASP

logger "Make upgradescript $PUDP"
echo "jdbc.default.driverClassName=com.mysql.cj.jdbc.Driver" >| $PUDP
echo "jdbc.default.url=jdbc:mysql://${LOCAL_DB_HOST}/${DB_SCHEMA_72}?characterEncoding=UTF-8" >> $PUDP
echo "jdbc.default.username=${LOCAL_DB_USER}" >> $PUDP
echo "jdbc.default.password=${LOCAL_DB_PASSWORD}" >> $PUDP

logger "Make upgradescript $PUEP"
echo "liferay.home=${DXP72SERVERDIR}" >| $PUEP
echo "dl.store.impl=com.liferay.portal.store.file.system.FileSystemStore" >> $PUEP

logger "Make upgrade wrapper $UW"
echo "#!/bin/bash" >| $UW
echo "" >> $UW
echo "./db_upgrade.sh \\" >> $UW
echo "	-j \"-Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en -Duser.timezone=GMT -Xmx10240m\" \\" >> $UW
echo "	-l \"upgrade\`date +%Y%m%d-%H%M-%s\`.log\" \\" >> $UW
chmod +x $UW

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

logger "Finished installing vanilla DXP 7.2 in $DXP72SERVERDIR in $DURATIONREADABLE"

confirm "Database upgrade script ${UW} has been prepared. Do you want to run it to upgrade the database ${DB_SCHEMA_72}?"
cp -v ${INDEXREADONLYCONFIG} ${DXP72SERVERDIR}/osgi/configs
logger "Updating database ${DB_SCHEMA_72}"
${UW}
rm -v ${DXP72SERVERDIR}/osgi/configs/${INDEXREADONLYCONFIG}

logger "Finished updating database ${DB_SCHEMA_72}"


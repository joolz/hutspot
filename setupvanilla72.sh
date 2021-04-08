#!/bin/bash

set -e

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

BOOKMARKS="$DXPDOWNLOADSDIR/Liferay Bookmarks.lpkg"
XUGGLER=$DXPDOWNLOADSDIR/xuggle-xuggler-arch-x86_64-pc-linux-gnu.jar
GEOLITEDATA=$DXPDOWNLOADSDIR/GeoLiteCity.dat
INDEXREADONLYCONFIG=$DXPDOWNLOADSDIR/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.config

if [ ! -f ${INDEXREADONLYCONFIG} ]; then
	echo "indexReadOnly=\"true\"" > ${INDEXREADONLYCONFIG}
fi

[[ -e "${DXPACTIVATIONKEY}" ]] && echo "${DXPACTIVATIONKEY} exists" || { echo "${DXPACTIVATIONKEY} not found" 1>&2 ; exit 1; }
[[ -e "${BOOKMARKS}" ]] && echo "${BOOKMARKS} exists" || { echo "${BOOKMARKS} not found" 1>&2 ; exit 1; }
[[ -e "${XUGGLER}" ]] && echo "${XUGGLER} exists" || { echo "${XUGGLER} not found" 1>&2 ; exit 1; }
[[ -e "${GEOLITEDATA}" ]] && echo "${GEOLITEDATA} exists" || { echo "${GEOLITEDATA} not found" 1>&2 ; exit 1; }
[[ -e "${INDEXREADONLYCONFIG}" ]] && echo "${INDEXREADONLYCONFIG} exists" || { echo "${INDEXREADONLYCONFIG} not found" 1>&2 ; exit 1; }

SETENV=$DXPTOMCATDIR/bin/setenv.sh
ROOTDIR=$DXPTOMCATDIR/webapps/ROOT
WEBXML=$ROOTDIR/WEB-INF/web.xml
ROOTCLASSESDIR=$ROOTDIR/WEB-INF/classes
ROOTLIBDIR=$ROOTDIR/WEB-INF/lib
DB_SCHEMA_72=dxp72mb4

SOURCESTOO=true

if [ "$SOURCESTOO" == true ]; then
	logger "Start installing vanilla DXP 7.2 in $DXPSERVERDIR"
else
	logger "Start installing vanilla DXP 7.2 in ${DXPSERVERDIR}, sources are excluded"
fi

START=$SECONDS

cd $DXPBASEDIR

logger "Remove existing server, unzip and link"
rm -f $DXPSERVERDIR
rm -rf $DXPSERVERPHYSICALDIR
tar -xvf $DXPDOWNLOADSDIR/$DXPSERVERZIP || exit 1
ln -s $DXPSERVERPHYSICALDIR $DXPSERVERDIR

logger "Copy in portal-ext.properties from repo and configure it"
cd ${ECLIPSE_WORKSPACE}
TEMPLATE_PE="template-portal-ext"
if [ -d "${TEMPLATE_PE}" ]; then
	pushd ${TEMPLATE_PE}
	hg update -r ${DXPBRANCHNAME} -C
else
	hg clone ssh://bamboo//repositories/rest/${TEMPLATE_PE}
	pushd ${TEMPLATE_PE}
fi

cp portal-ext.properties $DXPSERVERDIR
cd $DXPSERVERDIR

logger "Configure portal-ext.properties"
PROPS=${DXPSERVERDIR}/portal-ext.properties

if [ "$USE_SSL" = true ]; then
	logger "Add SSL settings to ${PROPS}"

	sed -i "/^web\.server\.host/d" ${PROPS}
	sed -i "/^web\.server\.protocol/d" ${PROPS}
	sed -i "/^web\.server\.https\.port/d" ${PROPS}
	sed -i "/^redirect\.url\.security\.mode/d" ${PROPS}
	sed -i "/^redirect\.url\.domains\.allowed/d" ${PROPS}

	echo "" >> ${PROPS}
	echo "web.server.protocol=https" >> ${PROPS}
	echo "web.server.https.port=443" >> ${PROPS}
	echo "redirect.url.security.mode=domain" >> ${PROPS}
	echo "redirect.url.domains.allowed=youlearnfun.two.ou.nl" >> ${PROPS}
fi

logger "Set template variables in portal-ext to local values"
sed -i "s/LOCAL_DB_USER/$LOCAL_DB_USER/g" ${PROPS}
sed -i "s/LOCAL_DB_PASSWORD/$LOCAL_DB_PASSWORD/g" ${PROPS}
sed -i "s/LOCAL_DB_HOST/$LOCAL_DB_HOST/g" ${PROPS}
sed -i "s/LOCAL_DB_PORT/$LOCAL_DB_PORT/g" ${PROPS}
sed -i "s/LOCAL_DB_SCHEMA/$DB_SCHEMA_72/g" ${PROPS}
sed -i "s/PORTAL_EXT_EMAIL_USER/$PORTAL_EXT_EMAIL_USER/g" ${PROPS}
sed -i "s/PORTAL_EXT_EMAIL_ADDRESS/$PORTAL_EXT_EMAIL_ADDRESS/g" ${PROPS}
sed -i "s~BROKER_URL~$BROKER_URL~g" ${PROPS}
sed -i "s~LOCAL_LIFERAY_HOME~$DXPSERVERDIR~g" ${PROPS}
sed -i "s~LOCAL_DOCLIB~$DXPSERVERDIR/data/document_library~g" ${PROPS}

mkdir $DXPTOMCATDIR/lib/ext/global
rm $DXPTOMCATDIR/bin/*bat

mkdir -p $ROOTLIBDIR
cp -v $XUGGLER $ROOTLIBDIR

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109
# and https://customer.liferay.com/documentation/knowledge-base/-/kb/1086550
mkdir -p $DXPSERVERDIR/geoip
cp -v $GEOLITEDATA $DXPSERVERDIR/geoip
mkdir -p $DXPSERVERDIR/osgi/configs
echo "filePath=$DXPSERVERDIR/geoip/GeoLiteCity.dat" \
	>| $DXPSERVERDIR/osgi/configs/com.liferay.ip.geocoder.internal.IPGeocoderConfiguration.cfg

echo "service.disabled=true" \
	>| $DXPSERVERDIR/osgi/configs/nl.ou.yl.kafka.client.impl.KafkaClientImpl.cfg

cp -v $DXPDOWNLOADSDIR/nl.ou.yl.messagebus.config.AMQConfig.cfg $DXPSERVERDIR/osgi/configs || exit 1

logger "Link document library"
rm -rf $DXPSERVERDIR/data/document_library
ln -s $DXPDOWNLOADSDIR/document_library $DXPSERVERDIR/data/document_library

logger "Link Elastic Search"
rm -rf $DXPSERVERDIR/data/elasticsearch6
ln -s $DXPDOWNLOADSDIR/elasticsearch6 $DXPSERVERDIR/data/elasticsearch6

logger "Copy patching configurations"
cp -v $DXPPATCHESDIR/source.properties patching-tool/
cp -v $DXPPATCHESDIR/default.properties patching-tool/

if [ "$SOURCESTOO" == true ]; then
	logger "Remove existing sources, unzip and create link"
	rm -fv $DXPSOURCEDIR
	rm -rfv ${DXPBASEDIR}/${DXPSOURCEPHYSICALDIR}
	unzip $DXPDOWNLOADSDIR/$DXPSOURCEZIP -d $DXPBASEDIR
	ln -s $DXPSOURCEPHYSICALDIR $DXPSOURCEDIR
	cp -v $DXPDOWNLOADSDIR/liferay-source-eclipse-metadata/.classpath $DXPSOURCEDIR
	cp -v $DXPDOWNLOADSDIR/liferay-source-eclipse-metadata/.project $DXPSOURCEDIR

	logger "Patch sources"

	# https://help.liferay.com/hc/en-us/requests/32659 Need to patch ReleaseInfo.java first, see https://help.liferay.com/hc/es/articles/360043206032--Problem-with-the-configuration-Unknown-release-in-folder-when-patching-the-source-code
	cp -vf ${DXPDOWNLOADSDIR}/ReleaseInfo.java ${DXPSOURCEDIR}/portal-kernel/src/com/liferay/portal/kernel/util/

	cp -v $DXPPATCHESDIR/$DXPPATCHLEVEL/source/* ${DXPSERVERDIR}/patching-tool/patches/
	if [ -d $DXPPATCHESDIR/$DXPPATCHLEVEL/combined ]; then
		cp -v $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* ${DXPSERVERDIR}/patching-tool/patches/
	fi
	cd ${DXPSERVERDIR}/patching-tool
	./patching-tool.sh source install
	rm -rf ${DXPSERVERDIR}/osgi/state
fi

logger "Patch server"
cp -v $DXPPATCHESDIR/$DXPPATCHLEVEL/binary/* ${DXPSERVERDIR}/patching-tool/patches/
if [ -d $DXPPATCHESDIR/$DXPPATCHLEVEL/combined ]; then
	cp -v $DXPPATCHESDIR/$DXPPATCHLEVEL/combined/* ${DXPSERVERDIR}/patching-tool/patches/
fi
cd ${DXPSERVERDIR}/patching-tool
./patching-tool.sh install
rm -rf ${DXPSERVERDIR}/osgi/state

logger "Copy license $DXPACTIVATIONKEY to $DXPSERVERDIR/deploy"
cd $DXPSERVERDIR
mkdir -p deploy
cp -v "$DXPACTIVATIONKEY" deploy/

logger "Copy bookmarks portlet"
cp -v "$BOOKMARKS" deploy/

mkdir -p osgi/modules
mkdir -p osgi/war

logger "Make $SETENV"

echo 'CATALINA_OPTS="$CATALINA_OPTS -Dfile.encoding=UTF-8"' >| $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Djava.locale.providers=JRE,COMPAT,CLDR"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Djava.net.preferIPv4Stack=true"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Duser.timezone=GMT"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Xms4096m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Xmx4096m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MaxNewSize=1536m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MaxMetaspaceSize=2048m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:MetaspaceSize=2048m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:NewSize=1536m"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -XX:SurvivorRatio=7"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttp.proxyHost=mail.lokaal"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttp.proxyPort=80"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyPort=80"' >> $SETENV
echo 'CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyHost=mail.lokaal"' >> $SETENV

UPGRADEDIR=${DXPSERVERDIR}/tools/portal-tools-db-upgrade-client
ASP=${UPGRADEDIR}/app-server.properties
PUDP=${UPGRADEDIR}/portal-upgrade-database.properties
PUEP=${UPGRADEDIR}/portal-upgrade-ext.properties
UW=${UPGRADEDIR}/upgradewrapper.sh

logger "Make upgradescript $ASP"
echo "dir=/" >| $ASP
echo "extra.lib.dirs=${DXPTOMCATDIR}/bin" >> $ASP
echo "global.lib.dir=${DXPTOMCATDIR}/lib" >> $ASP
echo "portal.dir=${DXPTOMCATDIR}/webapps/ROOT" >> $ASP
echo "server.detector.server.id=tomcat" >> $ASP

logger "Make upgradescript $PUDP"
echo "jdbc.default.driverClassName=com.mysql.cj.jdbc.Driver" >| $PUDP
echo "jdbc.default.url=jdbc:mysql://${LOCAL_DB_HOST}/${DB_SCHEMA_72}?characterEncoding=UTF-8" >> $PUDP
echo "jdbc.default.username=${LOCAL_DB_USER}" >> $PUDP
echo "jdbc.default.password=${LOCAL_DB_PASSWORD}" >> $PUDP

logger "Make upgradescript $PUEP"
echo "liferay.home=${DXPSERVERDIR}" >| $PUEP
echo "dl.store.impl=com.liferay.portal.store.file.system.FileSystemStore" >> $PUEP

logger "Make upgrade wrapper $UW"
echo "#!/bin/bash" >| $UW
echo "" >> $UW
echo "./db_upgrade.sh \\" >> $UW
echo "	-j \"-Dfile.encoding=UTF-8 -Duser.country=US -Duser.language=en -Duser.timezone=GMT -Xmx10240m\" \\" >> $UW
echo "	-l \"upgrade\`date +%Y%m%d-%H%M-%s\`.log\" \\" >> $UW
chmod +x $UW

logger "Deploy already converted projects from releaser, branch ${DXPBRANCHNAME}"
TEMPRELEASER=`mktemp -d`
pushd ${TEMPRELEASER}
hg clone ssh://bamboo//repositories/dlwo/${RELEASER}
cd nl-ou-dlwo-releaser
hg up fun
mvn -U package # TODO remove -U when we are more stable
cd target
mv * ${DXPSERVERDIR}/deploy
popd
rm -rf ${TEMPRELEASER}

popd >/dev/null 2>&1

TIMEOUT=600
logger "Set timeout to ${600}"
setdxptimeout.sh ${TIMEOUT}

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

logger "Finished installing vanilla DXP 7.2 in $DXPSERVERDIR in $DURATIONREADABLE"

# confirm "Database upgrade script ${UW} has been prepared. Do you want to run it to upgrade the database ${DB_SCHEMA_72}?"
# cp -v ${INDEXREADONLYCONFIG} ${DXPSERVERDIR}/osgi/configs
# pushd ${DXPSERVERDIR}/tools/portal-tools-db-upgrade-client
# logger "Updating database ${DB_SCHEMA_72}"
# ${UW}
# popd
# rm -v ${DXPSERVERDIR}/osgi/configs/${INDEXREADONLYCONFIG}
# logger "Finished updating database ${DB_SCHEMA_72}"


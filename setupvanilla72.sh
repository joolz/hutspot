#!/bin/bash

set -e

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

confirm "Existing server and sources will be removed, after that, a fresh install will be done. Continue?"

ACTIVATIONKEY="$DXP72DOWNLOADSDIR/activation-key-digitalenterprisedevelopment-7.2-developeractivationkeys.xml"
XUGGLER=$DXP72DOWNLOADSDIR/xuggle-xuggler-arch-x86_64-pc-linux-gnu.jar
GEOLITEDATA=$DXP72DOWNLOADSDIR/GeoLiteCity.dat
INDEXREADONLYCONFIG=$DXP72DOWNLOADSDIR/com.liferay.portal.search.configuration.IndexStatusManagerConfiguration.config

if [ ! -f ${INDEXREADONLYCONFIG} ]; then
	echo "indexReadOnly=\"true\"" > ${INDEXREADONLYCONFIG}
fi

[[ -e "${ACTIVATIONKEY}" ]] && echo "${ACTIVATIONKEY} exists" || { echo "${ACTIVATIONKEY} not found" 1>&2 ; exit 1; }
[[ -e "${XUGGLER}" ]] && echo "${XUGGLER} exists" || { echo "${XUGGLER} not found" 1>&2 ; exit 1; }
[[ -e "${GEOLITEDATA}" ]] && echo "${GEOLITEDATA} exists" || { echo "${GEOLITEDATA} not found" 1>&2 ; exit 1; }
[[ -e "${INDEXREADONLYCONFIG}" ]] && echo "${INDEXREADONLYCONFIG} exists" || { echo "${INDEXREADONLYCONFIG} not found" 1>&2 ; exit 1; }

SETENV=$DXP72TOMCATDIR/bin/setenv.sh
ROOTDIR=$DXP72TOMCATDIR/webapps/ROOT
WEBXML=$ROOTDIR/WEB-INF/web.xml
ROOTCLASSESDIR=$ROOTDIR/WEB-INF/classes
ROOTLIBDIR=$ROOTDIR/WEB-INF/lib
DB_SCHEMA_72=dxp72mb4

SOURCESTOO=false

if [ "$SOURCESTOO" == true ]; then
	logger "Start installing vanilla DXP 7.2 in $DXP72SERVERDIR"
else
	logger "Start installing vanilla DXP 7.2 in ${DXP72SERVERDIR}, sources are excluded"
fi

START=$SECONDS

cd $DXP72BASEDIR

logger "Remove existing server, unzip and link"
rm -f $DXP72SERVERDIR
rm -rf $DXP72SERVERPHYSICALDIR
tar -xvf $DXP72DOWNLOADSDIR/$DXP72SERVERZIP || exit 1
ln -s $DXP72SERVERPHYSICALDIR $DXP72SERVERDIR

logger "Copy in portal-ext.properties from repo and configure it"
cd ${ECLIPSE_WORKSPACE}
TEMPLATE_PE="template-portal-ext"
if [ -d "${TEMPLATE_PE}" ]; then
	pushd ${TEMPLATE_PE}
	hg update -r DXP72 -C
else
	hg clone ssh://bamboo//repositories/rest/${TEMPLATE_PE}
	pushd ${TEMPLATE_PE}
fi

cp portal-ext.properties $DXP72SERVERDIR
cd $DXP72SERVERDIR

logger "Configure portal-ext.properties"
PROPS=${DXP72SERVERDIR}/portal-ext.properties

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
sed -i "s~LOCAL_LIFERAY_HOME~$DXP72SERVERDIR~g" ${PROPS}
sed -i "s~LOCAL_DOCLIB~$DXP72SERVERDIR/data/document_library~g" ${PROPS}

mkdir $DXP72TOMCATDIR/lib/ext/global
rm $DXP72TOMCATDIR/bin/*bat

mkdir -p $ROOTLIBDIR
cp -v $XUGGLER $ROOTLIBDIR

# see https://web.liferay.com/group/customer/support/-/support/ticket/OUNDLWO-109
# and https://customer.liferay.com/documentation/knowledge-base/-/kb/1086550
mkdir -p $DXP72SERVERDIR/geoip
cp -v $GEOLITEDATA $DXP72SERVERDIR/geoip
mkdir -p $DXP72SERVERDIR/osgi/configs
echo "filePath=$DXP72SERVERDIR/geoip/GeoLiteCity.dat" \
	>| $DXP72SERVERDIR/osgi/configs/com.liferay.ip.geocoder.internal.IPGeocoderConfiguration.cfg

echo "service.disabled=true" \
	>| $DXP72SERVERDIR/osgi/configs/nl.ou.yl.kafka.client.impl.KafkaClientImpl.cfg

cp -v $DXP72DOWNLOADSDIR/nl.ou.yl.messagebus.config.AMQConfig.cfg $DXP72SERVERDIR/osgi/configs || exit 1

logger "Link document library"
rm -rf $DXP72SERVERDIR/data/document_library
ln -s $DXP72DOWNLOADSDIR/document_library $DXP72SERVERDIR/data/document_library

logger "Copy patching configurations"
cp -v $DXP72PATCHESDIR/source.properties patching-tool/
cp -v $DXP72PATCHESDIR/default.properties patching-tool/

if [ "$SOURCESTOO" == true ]; then
	logger "Remove existing sources, unzip and create link"
	rm -fv $DXP72SOURCEDIR
	rm -rfv ${DXP72BASEDIR}/${DXP72SOURCEPHYSICALDIR}
	unzip $DXP72DOWNLOADSDIR/$DXP72SOURCEZIP -d $DXP72BASEDIR
	ln -s $DXP72SOURCEPHYSICALDIR $DXP72SOURCEDIR
	cp -v $DXP72DOWNLOADSDIR/liferay-source-eclipse-metadata/.classpath $DXP72SOURCEDIR
	cp -v $DXP72DOWNLOADSDIR/liferay-source-eclipse-metadata/.project $DXP72SOURCEDIR

	logger "Patch sources"

	# https://help.liferay.com/hc/en-us/requests/32659 Need to patch ReleaseInfo.java first, see https://help.liferay.com/hc/es/articles/360043206032--Problem-with-the-configuration-Unknown-release-in-folder-when-patching-the-source-code
	cp -vf ${DXP72DOWNLOADSDIR}/ReleaseInfo.java ${DXP72SOURCEDIR}/portal-kernel/src/com/liferay/portal/kernel/util/

	cp -v $DXP72PATCHESDIR/$DXP72PATCHLEVEL/source/* ${DXP72SERVERDIR}/patching-tool/patches/
	if [ -d $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined ]; then
		cp -v $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* ${DXP72SERVERDIR}/patching-tool/patches/
	fi
	cd ${DXP72SERVERDIR}/patching-tool
	./patching-tool.sh source install
	rm -rf ${DXP72SERVERDIR}/osgi/state
fi

logger "Patch server"
cp -v $DXP72PATCHESDIR/$DXP72PATCHLEVEL/binary/* ${DXP72SERVERDIR}/patching-tool/patches/
if [ -d $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined ]; then
	cp -v $DXP72PATCHESDIR/$DXP72PATCHLEVEL/combined/* ${DXP72SERVERDIR}/patching-tool/patches/
fi
cd ${DXP72SERVERDIR}/patching-tool
./patching-tool.sh install
rm -rf ${DXP72SERVERDIR}/osgi/state

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

logger "Deploy already converted projects from releaser, branch ${DXP72BRANCHNAME}"
TEMPRELEASER=`mktemp -d`
pushd ${TEMPRELEASER}
hg clone ssh://bamboo//repositories/dlwo/${RELEASER}
cd nl-ou-dlwo-releaser
hg up DXP72
mvn -U package # TODO remove -U when we are more stable
cd target
mv * ${DXP72SERVERDIR}/deploy
popd
rm -rf ${TEMPRELEASER}

popd >/dev/null 2>&1

DURATION=$((SECONDS - START))
DURATIONREADABLE=`convertsecs $DURATION`

logger "Finished installing vanilla DXP 7.2 in $DXP72SERVERDIR in $DURATIONREADABLE"

confirm "Database upgrade script ${UW} has been prepared. Do you want to run it to upgrade the database ${DB_SCHEMA_72}?"
cp -v ${INDEXREADONLYCONFIG} ${DXP72SERVERDIR}/osgi/configs
pushd ${DXP72SERVERDIR}/tools/portal-tools-db-upgrade-client
logger "Updating database ${DB_SCHEMA_72}"
${UW}
popd
rm -v ${DXP72SERVERDIR}/osgi/configs/${INDEXREADONLYCONFIG}

logger "Finished updating database ${DB_SCHEMA_72}"


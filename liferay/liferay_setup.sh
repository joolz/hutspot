#!/bin/bash

echo Press y to setup liferay
read -r -n1 CHOICE

if [ "$CHOICE" != "y" ]; then
  echo
  echo Not setting up. Bye.
  exit 0
fi

readonly ZIPDIR=/home/jal/Downloads/Liferay/6.2
readonly TARGETDIR=/opt/liferay-6.2

readonly SDKZIP=liferay-plugins-sdk-6.2-ee-sp5-20140606104845789.zip
readonly MAVENZIP=liferay-portal-maven-6.2-ee-sp5-20140606104845789.zip
readonly SRCZIP=liferay-portal-src-6.2-ee-sp5-20140606104845789.zip
readonly PORTALZIP=liferay-portal-tomcat-6.2-ee-sp5-20140606104845789.zip
readonly FIXPACKSZIP=liferay-portal-fix-packs-6.2-ee-20140703.zip
readonly LICENSE=license-portaldevelopment-developer-6.2ga1-oundevga.xml

cd $TARGETDIR || exit 1

unzip $ZIPDIR/$MAVENZIP
SOURCEDIR=`ls -d liferay-portal-maven**`
ln -s $SOURCEDIR maven

unzip $ZIPDIR/$SRCZIP
SOURCEDIR=`ls -d liferay-portal-src*`
ln -s $SOURCEDIR src

unzip $ZIPDIR/$PORTALZIP
SOURCEDIR=`ls -d liferay-portal-6*`
ln -s $SOURCEDIR portal

find . -name *.bat -exec rm {} \;

unzip $ZIPDIR/$SDKZIP
SOURCEDIR=`ls -d liferay-plugins-sdk*`
ln -s $SOURCEDIR sdk

readonly PROPS=sdk/build.$USER.properties

echo "javac.compiler = modern" >| $PROPS
echo "theme.parent = classic" >> $PROPS
echo "liferay.dir.owner = $USER" >> $PROPS
echo "liferay.dir.group = $USER" >> $PROPS
echo "app.server.parent.dir = $TARGETDIR/portal" >> $PROPS
echo 'auto.deploy.dir = ${app.server.parent.dir}/deploy' >> $PROPS
readonly TOMCATDIR=`ls -d $TARGETDIR/portal/tomcat-*`
echo "app.server.dir = $TOMCATDIR" >> $PROPS
echo 'app.server.lib.global.dir = ${app.server.dir}/lib/ext' >> $PROPS
echo 'app.server.deploy.dir = ${app.server.dir}/webapps' >> $PROPS
echo 'app.server.portal.dir = ${app.server.deploy.dir}/ROOT' >> $PROPS

cp $ZIPDIR/portal-ext.properties portal/

pushd portal/patching-tool/patches
unzip -n $ZIPDIR/$FIXPACKSZIP
cd ..
./patching-tool.sh auto-discovery | grep = > default.properties
echo "auto.update.plugins=true" >> default.properties
./patching-tool.sh install
./patching-tool.sh auto-discovery ../../src source | grep = > source.properties
./patching-tool.sh source install
popd

mkdir portal/deploy
cp $ZIPDIR/$LICENSE portal/deploy

echo -----------------------------------------------------------------
echo "Add deployXML=\"false\" to server.xml <Host>"
echo -----------------------------------------------------------------
echo remove DeveloperStudio/resources/liferay zip files
echo -----------------------------------------------------------------
echo remove liferay portal and sdk dirs from DeveloperStudio
echo -----------------------------------------------------------------
echo start DeveloperStudio and point paths for server and sdk
echo to the new locations:
echo - prefs, server, runtimes
echo - prefs, liferay, installed plugin sdks
echo -----------------------------------------------------------------

#!/bin/bash

TARGET_DIR=/opt/liferay-6.2
PORTAL_DIR=$TARGET_DIR/liferay-portal-6.2-ee-sp14
TOMCAT_DIR=$PORTAL_DIR/tomcat-7.0.62
SETENV_FILE=$TOMCAT_DIR/bin/setenv.sh
DOWNLOAD_DIR=/home/jal/Downloads/liferay-6.2
ACCOUNTS_DIR=/home/jal/Documents/accounts

if [ -d $PORTAL_DIR ]; then
	read -p "$PORTAL_DIR exists. Delete and continue? " answer
	case $answer in
	[yY] ) 
		echo Will now continue;
		;;
	* )
		exit
		;;
	esac
fi

rm -r $PORTAL_DIR
cd $TARGET_DIR
unzip $DOWNLOAD_DIR/liferay-portal-tomcat-6.2-ee-sp14-20151105114451508.zip
mkdir $PORTAL_DIR/deploy

cp $ACCOUNTS_DIR/portal-ext.properties $PORTAL_DIR/
cp $ACCOUNTS_DIR/license-portaldevelopment-developer-6.2ee-oundev.xml $PORTAL_DIR/deploy/
cp "$DOWNLOAD_DIR/Notifications EE.lpkg" $PORTAL_DIR/deploy/
cp "$DOWNLOAD_DIR/Resources Importer EE.lpkg" $PORTAL_DIR/deploy/
cp $DOWNLOAD_DIR/liferay-hotfix-14954-6210.zip $PORTAL_DIR/patching-tool/patches/
rm $TOMCAT_DIR/bin/*.bat
rm $PORTAL_DIR/patching-tool/*.bat
cp $ACCOUNTS_DIR/log4j.properties $TOMCAT_DIR/webapps/ROOT/WEB-INF/classes/

sed -i 's/-Duser.timezone=GMT/-Duser.timezone=CET/g' $SETENV_FILE
sed -i 's/-Xmx1024m/-Xmx4096m/g' $SETENV_FILE
sed -i 's/-XX:MaxPermSize=256m/-XX:MaxPermSize=1024m/g' $SETENV_FILE

echo Initial setup complete.
echo
echo Now, start Liferay so the portlet lpkgs will be installed
echo then stop Liferay and run the patching tool. There should be no collisions

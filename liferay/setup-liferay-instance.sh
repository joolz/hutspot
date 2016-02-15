#!/bin/bash

BASE=/home/jal/Desktop
LR=liferay-portal-6.2-ee-sp8
SRC=liferay-portal-src-6.2-ee-sp8

cd $BASE

unzip -n ~/Downloads/liferay-portal-tomcat-6.2-ee-sp8-20140904111637931.zip
unzip -n ~/Downloads/liferay-portal-src-6.2-ee-sp8-20140904111637931.zip

cd $LR || exit 1
rm -r patching-tool/
hg clone ssh://bamboo//repositories/rest/patching-tool

cd patching-tool || exit 1

./patching-tool.sh source auto-discovery \
	/home/jal/Desktop/liferay-portal-src-6.2-ee-sp8/ source

./patching-tool.sh install
./patching-tool.sh source install

cd ../tomcat-7.0.42/bin/

rm *bat

sed -i 's/Duser.timezone=GMT/-Duser.timezone=CET/' setenv.sh
sed -i 's/-Xmx1024m/-Xmx4096m/' setenv.sh
sed -i 's/-XX:MaxPermSize=256m/-XX:MaxPermSize=1024m/' setenv.sh

cd $BASE/$LR

ln -s ~/Documents/accounts/portal-ext.properties .
cd tomcat-7.0.42/webapps/ROOT/WEB-INF/classes
ln -s ~/Documents/accounts/log4j.properties .



#!/bin/bash

USER_PREFIX=student
FORWARD=jal

DB_SCHEMA=lportal6_0_12
DB_PASSWORD=`sudo cat /home/jal/Documents/accounts/mysql_root_pw.txt`
DB_USR=root

CSV_FILE=/home/jal/Desktop/liferay_users.csv
CSV_HEADER="Username,First name,Middle name,Last name,E-Mail Address,Password,Locale,Timezone,Global Roles,Global Groups,Community,Community"

echo $CSV_HEADER >| $CSV_FILE

for I in {1..20} # max 99
do

  if [ ${#I} -lt 2 ]; then
    NUMBER=0$I
  else
    NUMBER=$I
  fi

  PSUSER=$USER_PREFIX$NUMBER

  echo Cleanup old user
  userdel -r $PSUSER

  echo Create user $PSUSER
  PASSWORD=`pwgen -1 30`
  useradd $PSUSER -m -p `mkpasswd $PASSWORD`
  # disable actual login
  passwd -l $PSUSER
 
  ALIASFOUND=`grep $PSUSER /etc/aliases | wc -l`
  if [ "$ALIASFOUND" -lt 1 ]; then
    echo Forward mail to $FORWARD
    echo "$PSUSER: jal" >> /etc/aliases
  fi

  LRPASSWORD=test123
  LRLOCALE=nl_NL
  LRTIMEZONE=UTC
  LRGLOBALROLES=
  LRGLOBALGROUPS=
  LRCOMMUNITY1=
  LRCOMMUNITY2=
  EMAIL_ADDRESS=$PSUSER@localhost.localdomain
  CSV_LINE="$PSUSER,$PSUSER,$PSUSER,$PSUSER,$EMAIL_ADDRESS,$LRPASSWORD,$LRLOCALE,$LRTIMEZONE,$LRGLOBALROLES,$LRGLOBALGROUPS,$LRCOMMUNITY1,$LRCOMMUNITY2"

  echo $CSV_LINE >> $CSV_FILE

  DELETE_STATEMENT="delete from User_ where emailAddress='$EMAIL_ADDRESS'"

  mysql \
    --user==$DB_USR \
    --password=$DB_PASSWORD \
    --execute=$DELETE_STATEMENT \
    $DB_SCHEMA

done

echo Run newaliases
cd /etc
newaliases

chown jal.jal $CSV_FILE


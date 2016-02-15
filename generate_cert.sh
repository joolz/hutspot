#!/bin/bash

echo See https://help.ubuntu.com/12.04/serverguide/certificates-and-security.html
echo

echo "Enter basename for certificate (e.g. jira.ou.nl)"
read -r BASENAME

echo "Create certificate $BASENAME? yN"
read -r -n1 CHOICE

if [ "$CHOICE" != "y" ]; then
  echo Exiting
  exit 1
fi

echo "Generate key (give a password)"
echo "When using big keysizes in combination with a JRE, read this"
echo "http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html"
openssl genrsa -des3 -out $BASENAME.key 2048

echo "Create insecure key"
openssl rsa -in $BASENAME.key -out $BASENAME.key.insecure
mv $BASENAME.key $BASENAME.key.secure
mv $BASENAME.key.insecure $BASENAME.key

echo "Create signing request (no challenge password)"
openssl req -new -key $BASENAME.key -out $BASENAME.csr

echo "Create self-signed certificate"
openssl x509 -req -days 365 \
  -in $BASENAME.csr \
  -signkey $BASENAME.key \
  -out $BASENAME.crt

echo "Now copy $BASENAME.crt to /etc/ssl/certs"
echo "     and $BASENAME.key to /etc/ssl/private"

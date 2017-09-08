#!/bin/bash

TO=`whoami`@ou.nl

echo "send testmail with dummy content (this script) to $TO"
mailx -s "Test mail from $HOSTNAME" $TO < $0

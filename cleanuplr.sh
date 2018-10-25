#!/bin/bash

# Script to do the database upgrade from 6.2 to DXP. This includes
# remove the old db upgrademe and importing the dump from the
# production database. Logging will end up in $DXPLOGDIR/general.log

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

liferayrunningcheck

rm -v $DXPSERVERDIR/osgi/modules/*jar
rm -v $DXPSERVERDIR/osgi/war/*war

confirm "Also remove state directory?"
rm -rv $DXPSERVERDIR/osgi/state

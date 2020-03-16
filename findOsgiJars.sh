#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

for FILE in ls *jar; do
	FULLNAME=`readlink -f $FILE`
	FOUND=`jar -tvf "$FILE" | grep "MANIFEST.MF"`
	if [ "$FOUND" != "" ]; then
		TMPDIR=`mktemp -d -p $TMP`
		checkedPushd $TMPDIR
		jar -xvf "${FULLNAME}" $FOUND &> /dev/null
		# assume string only occurs in manifest file
		OSGI=`grep -r "Bundle-SymbolicName" *`
		popd >/dev/null 2>&1
		rm -rf $TMPDIR
		if [ "$OSGI" == "" ]; then
			FULLNAME=`readlink -f $FILE`
			echo "  $FULLNAME is NOT OSGi"
		else
			echo "* $FULLNAME is OSGi"
		fi
	fi
done

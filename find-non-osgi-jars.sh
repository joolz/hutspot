#!/bin/bash

find . -name "*.jar" | while read -r FILE
do
	FOUND=`jar -tvf "$FILE" | grep "MANIFEST.MF"`
	if [ "$FOUND" != "" ]; then
		TMPDIR=`mktemp -d -p .`
		pushd $TMPDIR &> /dev/null
		jar -xvf "../${FILE}" $FOUND &> /dev/null
		OSGI=`grep -r "Bundle-SymbolicName" *`
		popd &> /dev/null
		rm -rf $TMPDIR
		if [ "$OSGI" == "" ]; then
			echo "$FILE does not have a manifest file containing Bundle-SymbolicName"
			if [ "$1" == "-r" ]; then
				echo "Remove $FILE"
				rm $FILE
			fi
		else
			echo $FILE has a manifest file containing Bundle-SymbolicName
		fi
	fi
done

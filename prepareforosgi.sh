#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# fire from bamboo to remove non-osgi jars of an artefacet, some more cleaning up
# see https://confluence.atlassian.com/bamboo/bamboo-variables-289277087.html

usage() {
	echo "Read $0 and use proper parameters. Make sure specified directories exist."
	exit 1
}

log() {
	if [ "$VERBOSE" != "" ]; then
		echo $1
	fi
}

# JARCMD=/etc/alternatives/jre/bin/jar

POSITIONAL=()
while [[ $# -gt 0 ]]; do
	KEY="$1"

	case $KEY in
		-d|--directory)
			DIRECTORY="$2"
			shift # past argument
			shift # past value
			;;
		-x|--removeexecutable)
			REMOVEEXECUTABLE="$1"
			shift # past argument
			;;
		-r|--removenonosgi)
			REMOVENONOSGI="$1"
			shift # past argument
			;;
		-t|--tempdirlocation)
			TEMPDIRLOCATION="$2"
			shift # past argument
			shift # past value
			;;
		-v|--verbose)
			VERBOSE="$1"
			shift
			;;
		-h|--help)
			usage
			;;
		*) # unknown option
			POSITIONAL+=("$1") # save it in an array for later
			shift # past argument
			;;
	esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$DIRECTORY" == "" ]; then
	usage
fi

if [ "$TEMPDIRLOCATION" == "" ]; then
	TEMPDIRLOCATION=.
else
	if [ ! -d $TEMPDIRLOCATION ]; then
		usage
	fi
fi

log "DIRECTORY = ${DIRECTORY}"
log "REMOVEEXECUTABLE = ${REMOVEEXECUTABLE}"
log "REMOVENONOSGI = ${REMOVENONOSGI}"
log "TEMPDIRLOCATION  = ${TEMPDIRLOCATION}"

pushd $DIRECTORY >/dev/null || usage

find . -name target -type d | while read -r TARGETDIR
do
	log "Have target dir $TARGETDIR"
	pushd $TARGETDIR >/dev/null
	find . -name "*.jar" -maxdepth 1 -type f | while read -r FILE
	do
		log "Investigate jar $FILE"

		FOUND=`$JARCMD -tvf "$FILE" | grep "MANIFEST.MF"`
		if [ "$FOUND" != "" ]; then
			log "$FILE has a manifest"
			TMPDIR=`mktemp -d -p $TEMPDIRLOCATION`
			pushd $TMPDIR &> /dev/null
			$JARCMD -xvf "../${FILE}" $FOUND &> /dev/null
			OSGI=`grep -r "Bundle-SymbolicName" *`
			popd &> /dev/null
			rm -rf $TMPDIR
			if [ "$OSGI" == "" ]; then
				log "$FILE is not OSGI"
				if [ "$REMOVENONOSGI" != "" ]; then
					log "Remove non-osgi jar $FILE from $TARGETDIR"
					rm $FILE
				fi
			else
				log "$FILE seems to be OSGI"
			fi
		fi

	done

	if [ "$REMOVEEXECUTABLE" != "" ]; then
		log "Remove executable attribute from all files in $TARGETDIR"
		find . -type f -exec chmod ugo-x {} \;
	fi

	popd >/dev/null
done

popd >/dev/null

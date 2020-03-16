#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

rm -fv $DXPTOMCATDIR/temp/*pdf
rm -fv $DXPTOMCATDIR/temp/*html
find $DXPSERVERDIR/data/document_library/pdf_exports -name "*pdf" -exec rm -fv {} \;

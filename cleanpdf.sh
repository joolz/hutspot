#!/bin/bash

source ~/bin/common.sh

rm -fv $DXPTOMCATDIR/temp/*pdf
rm -fv $DXPTOMCATDIR/temp/*html
find $DXPSERVERDIR/data/document_library/pdf_exports -name "*pdf" -exec rm -fv {} \;
doneMessage

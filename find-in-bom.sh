#!/bin/bash

source ~/bin/common.sh || exit 1

FILE1=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom/${DXP72BOMVERSION}/release.dxp.bom-${DXP72BOMVERSION}.pom
FILE2=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom.compile.only/${DXP72BOMVERSION}/release.dxp.bom.compile.only-${DXP72BOMVERSION}.pom
FILE3=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom.third.party/${DXP72BOMVERSION}/release.dxp.bom.third.party-${DXP72BOMVERSION}.pom
FILE4=/home/jal/workspace/nl.ou.yl.bom/pom.xml

echo "In Liferay BOMs -----------------------------------------------"
grep -B 2 -A 2 "$1" "${FILE1}"
grep -B 2 -A 2 "$1" "${FILE2}"
grep -B 2 -A 2 "$1" "${FILE3}"

echo "In yOUlearn BOM -----------------------------------------------"
grep -B 2 -A 2 "$1" "${FILE4}"

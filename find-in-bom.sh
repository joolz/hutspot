#!/bin/bash

VERSION=7.2.10-fp7

FILE1=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom/7.2.10.fp7/release.dxp.bom-${VERSION}.pom
FILE2=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom.compile.only/7.2.10.fp7/release.dxp.bom.compile.only-${VERSION}.pom
FILE3=/home/jal/tmp/m2_repository/com/liferay/portal/release.dxp.bom.third.party/7.2.10.fp7/release.dxp.bom.third.party-${VERSION}.pom

grep -B 2 -A 2 "$1" "${FILE1}"
grep -B 2 -A 2 "$1" "${FILE2}"
grep -B 2 -A 2 "$1" "${FILE3}"

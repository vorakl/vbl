#!/bin/bash

OLD_DIR="$(pwd)"
cd ${POTENTIAL_DIFFERENCE_REPO:=.}

THEME_DIR="$(awk -F"=" '$1 ~ /THEMEDIR/ {print $2}' Makefile.local)"
MAKE_CMD="make -f ${THEME_DIR}/../Makefile"

${MAKE_CMD} "$@"

cd ${OLD_DIR}

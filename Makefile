# (c) Oleksii Tsvietnov, me@vorakl.name
#
# Variables:
ECHO_BIN ?= echo
CP_BIN ?= cp
MKDIR_BIN ?= mkdir
LN_BIN ?= ln
SED_BIN ?= sed
PWD_BIN ?= pwd
BASENAME_BIN ?= basename
GIT_BIN ?= git
SHA256SUM_BIN ?= sha256sum 
FIND_BIN ?= find

# -------------------------------------------------------------------------
# Set a default target
.MAIN: usage

DIR = $(shell ${PWD_BIN} -P)
SELF = $(shell ${BASENAME_BIN} ${DIR})
VER = $(shell ${SED_BIN} -n '1s/^[[:space:]]*//; 1s/[[:space:]]*$$//; 1p' ${DIR}/version)
VERSION ?= ${VER}
LAST_COMMIT = $(shell ${GIT_BIN} log -1 | sed -n '/^commit/s/^commit //p')

usage:
	@${ECHO_BIN} "Usage: make [target] ..."
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Examples: make setver"
	@${ECHO_BIN} "          make VERSION=v1.15.2 setver"
	@${ECHO_BIN} "          make settag"
	@${ECHO_BIN} "          make push"
	@${ECHO_BIN} "          make release"
	@${ECHO_BIN} "          make VERSION=v1.1.14 release"
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Description:"
	@${ECHO_BIN} "  setver         Set a new version (is taken from environment or file)."
	@${ECHO_BIN} "  settag         Set a new version as a tag to the last commit."
	@${ECHO_BIN} "  push           Push to the repo (with tags)."
	@${ECHO_BIN} "  publish        Publish all libbraries to the static site with sha256 sums."
	@${ECHO_BIN} "  release        Set a version, tag and push to the repo."
	@${ECHO_BIN} "  test           Run all tests"
	@${ECHO_BIN} ""

test:
	@bash -c '\
	    lib_name="common"; \
	    source <(curl -sSLf http://lib-sh.vorakl.name/files/$${lib_name}) && \
	    cd tests && \
	    roundup'

setver:
	@${ECHO_BIN} "Setting version to ${VERSION}"
	@${SED_BIN} -i "s/# Version: .*$$/# Version: ${VERSION}/" ${DIR}/src/*
	@${SED_BIN} -i "1s/.*/${VERSION}/" ${DIR}/version

settag:
	@${ECHO_BIN} "Setting ${VERSION} as a tag to ${LAST_COMMIT}"
	@${GIT_BIN} tag ${VERSION} ${LAST_COMMIT} 2>/dev/null || true
	@${MKDIR_BIN} docs/files/${VERSION}

push:
	@${ECHO_BIN} "Pushing commits..."
	@${GIT_BIN} push origin
	@${ECHO_BIN} "Pushing tags..."
	@${GIT_BIN} push origin ${VERSION}

publish: publish-latest publish-tag

publish-latest:
	@${LN_BIN} -vf src/* docs/files/
	@(cd docs/files/ && ${FIND_BIN} . -maxdepth 1 ! -name "*.sha256" -type f -exec bash -c '_file=$$(basename {}); ${SHA256SUM_BIN} $${_file} | tee $${_file}.sha256' \;)

publish-tag:
	@${CP_BIN} -vf src/* docs/files/${VERSION}/
	@(cd docs/files/${VERSION}/ && ${FIND_BIN} . -maxdepth 1 ! -name "*.sha256" -type f -exec bash -c '_file=$$(basename {}); ${SHA256SUM_BIN} $${_file} | tee $${_file}.sha256' \;)

cirelease: setver settag publish
	@${GIT_BIN} add .
	@${GIT_BIN} ci -m "Release new version: ${VERSION}"

release: cirelease push

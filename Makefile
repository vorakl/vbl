# (c) Oleksii Tsvietnov, me@vorakl.name
#
# Variables:
SHELL = bash
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

.PHONY: usage setver settag \
    	test test-dev test-ver \
        push-all push-commits push-tag \
	publish-all publish-latest publish-ver \
	release-all release-latest release-ver \
	deploy deploy-latest deploy-ver

DIR = $(shell ${PWD_BIN} -P)
VER = $(shell ${SED_BIN} -n '1s/^[[:space:]]*//; 1s/[[:space:]]*$$//; 1p' ${DIR}/version)
VERSION ?= ${VER}

usage:
	@${ECHO_BIN} "Usage: make [target] ..."
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Examples: make test"
	@${ECHO_BIN} "          make VERSION=v1.15.2 deploy-latest"
	@${ECHO_BIN} "          make deploy"
	@${ECHO_BIN} ""

test: test-dev

test-dev:
	@${ECHO_BIN} "Testing development version:"
	@(lib_name="common"; \
	 source ${DIR}/src/$${lib_name} && \
	 cd tests && \
	 ${SHELL} $$(which roundup); \
	)

test-latest:
	@${ECHO_BIN} "Testing latest version:"
	@(lib_name="common"; \
	 source ${DIR}/docs/latest/$${lib_name} && \
	 cd tests && \
	 ${SHELL} $$(which roundup); \
	)

test-ver:
	@${ECHO_BIN} "Testing ${VERSION} version:"
	@(lib_name="common"; \
	 source ${DIR}/docs/${VERSION}/$${lib_name} && \
	 cd tests && \
	 ${SHELL} $$(which roundup); \
	)

setver:
	@${ECHO_BIN} "Setting version to ${VERSION}"
	@${SED_BIN} -i "s/# Version: .*$$/# Version: ${VERSION}/" ${DIR}/src/*
	@${SED_BIN} -i "1s/.*/${VERSION}/" ${DIR}/version

settag:
	@LAST_COMMIT=$$(${GIT_BIN} log -1 | sed -n '/^commit/s/^commit //p'); \
	 ${ECHO_BIN} "Setting ${VERSION} as a tag to $${LAST_COMMIT}"; \
	 ${GIT_BIN} tag ${VERSION} ${LAST_COMMIT} 2>/dev/null

push-all: push-commits push-tag

push-commits:
	@${ECHO_BIN} "Pushing commits..."
	@${GIT_BIN} push origin

push-tag:
	@${ECHO_BIN} "Pushing the tag..."
	@${GIT_BIN} push origin ${VERSION}

publish-all: publish-latest publish-ver

publish-latest:
	@[[ -d ${DIR}/docs/latest ]] || ${MKDIR_BIN} ${DIR}/docs/latest
	@${CP_BIN} -vf ${DIR}/src/* ${DIR}/docs/latest/
	@(cd ${DIR}/docs/latest/ && ${FIND_BIN} . -maxdepth 1 ! -name "*.sha256" -type f -exec bash -c '_file=$$(basename {}); ${SHA256SUM_BIN} $${_file} | tee $${_file}.sha256' \;)

publish-ver:
	@[[ -d ${DIR}/docs/${VERSION} ]] || ${MKDIR_BIN} ${DIR}/docs/${VERSION}
	@${CP_BIN} -vf ${DIR}/src/* ${DIR}/docs/${VERSION}/
	@(cd ${DIR}/docs/${VERSION}/ && ${FIND_BIN} . -maxdepth 1 ! -name "*.sha256" -type f -exec bash -c '_file=$$(basename {}); ${SHA256SUM_BIN} $${_file} | tee $${_file}.sha256' \;)

release-latest: setver publish-latest test-latest
	@${GIT_BIN} add .
	@${GIT_BIN} ci -m "Release ${VERSION} as the latest version"

release-ver: setver publish-ver test-ver
	@${GIT_BIN} add .
	@${GIT_BIN} ci -m "Release a new version: ${VERSION}"

release-all: setver publish-all test-ver
	@${GIT_BIN} add .
	@${GIT_BIN} ci -m "Release a new version ${VERSION} and the latest"

deploy-latest: release-latest push-commits

deploy-ver: release-ver settag push-all

deploy: release-all settag push-all


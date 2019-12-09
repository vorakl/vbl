# (c) Oleksii Tsvietnov, vorakl@protonmail.com
#
# Variables:

# The order of modules in the list is important!
LIBS_BASE := sys.sh str.sh exec.sh
LIBS_MISC := matrix.sh 

SHELL = bash
ECHO_BIN ?= echo
PWD_BIN ?= pwd
WHICH_BIN ?= which
CP_BIN ?= cp
RM_BIN ?= rm
MKDIR_BIN ?= mkdir
BASENAME_BIN ?= basename
SHA256SUM_BIN ?= sha256sum 

# -------------------------------------------------------------------------
# Set a default target
.MAIN: usage

.PHONY: usage test pub pub-latest pub-version

DIR = $(shell ${PWD_BIN} -P)

usage:
	@${ECHO_BIN} "Usage: make [target] ..."
	@${ECHO_BIN} ""
	@${ECHO_BIN} "Examples: make test"
	@${ECHO_BIN} "          make pub"
	@${ECHO_BIN} "          make pub-latest"
	@${ECHO_BIN} "          make pub-stable"
	@${ECHO_BIN} ""

test:
	@${ECHO_BIN} "---> Run all tests for a development version:"
	@(for lib in ${LIBS_BASE}; do source ${DIR}/src/$${lib}; done;\
	  for lib in ${LIBS_MISC}; do source ${DIR}/src/$${lib}; done;\
	  cd tests && \
	  ${SHELL} $$(${WHICH_BIN} roundup); \
	)

pub: pub-latest pub-stable

pub-latest:
	@[[ -d ${DIR}/docs/latest ]] || \
	    ${MKDIR_BIN} ${DIR}/docs/latest
	@${ECHO_BIN} "---> Publish modules to the latest dir..."
	@(declare -A latest=(); \
	  for lib in ${LIBS_BASE} ${LIBS_MISC}; do \
	    source ${DIR}/src/$${lib}; \
	    eval latest[$${lib%.sh}]="\$${__$${lib%.sh}_version}"; \
	    ${CP_BIN} -vf ${DIR}/src/$${lib} ${DIR}/docs/latest/$${lib%.sh}; \
	    (cd ${DIR}/docs/latest/; \
	     ${SHA256SUM_BIN} $${lib%.sh} |\
	     tee $${lib%.sh}.sha256); \
	  done; \
	  ${ECHO_BIN} "---> Create a latest.lst..."; \
	  ${RM_BIN} -f ${DIR}/docs/latest.lst; \
	  for lib in $${!latest[*]}; do \
	    eval echo "$${lib}=\'\$${latest[$${lib}]}\'" | \
	       tee -a ${DIR}/docs/latest.lst; \
	  done ; \
	)

pub-stable:
	@[[ -d ${DIR}/docs/archive ]] || \
	    ${MKDIR_BIN} ${DIR}/docs/archive
	@[[ -d ${DIR}/docs/stable ]] || \
	    ${MKDIR_BIN} ${DIR}/docs/stable
	@${ECHO_BIN} "---> Publish modules to the version dirs..."
	@(declare -A stable=(); \
	  for lib in ${LIBS_BASE} ${LIBS_MISC}; do \
	    source ${DIR}/src/$${lib}; \
	    eval ver="\$${__$${lib%.sh}_version}"; \
	    stable[$${lib%.sh}]="$${ver}"; \
	    [[ -d ${DIR}/docs/$${ver} ]] || \
	    	${MKDIR_BIN} ${DIR}/docs/$${ver}; \
	    ${CP_BIN} -vf ${DIR}/src/$${lib} ${DIR}/docs/$${ver}/$${lib%.sh}; \
	    ${CP_BIN} -vf ${DIR}/src/$${lib} ${DIR}/docs/stable/$${lib%.sh}; \
	    (cd ${DIR}/docs/$${ver}/; \
	     ${SHA256SUM_BIN} $${lib%.sh} | tee $${lib%.sh}.sha256; \
	     cd ${DIR}/docs/stable/; \
	     ${SHA256SUM_BIN} $${lib%.sh} | tee $${lib%.sh}.sha256; \
	    ); \
	  done; \
	  ${ECHO_BIN} "---> Create a stable.lst..."; \
	  ${RM_BIN} -f ${DIR}/docs/stable.lst; \
	  for lib in $${!stable[*]}; do \
	     eval echo "$${lib}=\'\$${stable[$${lib}]}\'" | \
	        tee -a ${DIR}/docs/stable.lst; \
	  done; \
	)


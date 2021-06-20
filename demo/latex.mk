MAKEFILE4LATEX_REVISION = v0.7.0
MAKEFILE4LATEX_CACHE = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/.cache

BUILDDIR = .build

PREREQUISITE += JHEP.bst
CLEANFILES += JHEP.bst

JHEP.bst:
	$(download) JHEP.bst https://raw.githubusercontent.com/tueda/JHEP-mod.bst/upstream/JHEP.bst

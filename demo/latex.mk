MAKEFILE4LATEX_REVISION = v0.7.0
MAKEFILE4LATEX_CACHE = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/.cache

BUILDDIR = .build

PREREQUISITE += JHEP.bst
CLEANFILES += JHEP.bst

PDFTOPPM_OPT += -r 150 -hide-annotations

JHEP.bst:
	$(download) JHEP.bst https://raw.githubusercontent.com/tueda/JHEP-mod.bst/upstream/JHEP.bst

# "make conv" generates images for the demo.
conv: demo-JHEP.png demo-JHEP-mod.png
	convert -trim demo-JHEP.png ../docs/images/demo-JHEP.png
	convert -trim demo-JHEP-mod.png ../docs/images/demo-JHEP-mod.png

SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: swiftinfo

swiftinfo: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: swiftinfo
	@install -d "$(bindir)" "$(libdir)"
	@install "$(BUILDDIR)/release/swiftinfo" "$(bindir)"
	@cp -a "$(REPODIR)/Sources/Csourcekitd/." "$(bindir)/Csourcekitd"

.PHONY: portable_zip
portable_zip: swiftinfo
	rm -f "$(BUILDDIR)/release/portable_swiftinfo.zip"
	zip -j "$(BUILDDIR)/release/portable_swiftinfo.zip" "$(BUILDDIR)/release/swiftinfo" "$(REPODIR)/LICENSE"
	echo "Portable ZIP created at: $(BUILDDIR)/release/portable_swiftinfo.zip"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/swiftinfo"
	@rm -rf "$(bindir)/Csourcekitd"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)

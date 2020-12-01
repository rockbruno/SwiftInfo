SHELL = /bin/bash

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
RELEASEBUILDDIR = $(BUILDDIR)/release
TEMPPRODUCTDIR = $(BUILDDIR)/_PRODUCT
PRODUCTDIR = $(RELEASEBUILDDIR)/_PRODUCT

.DEFAULT_GOAL = all

.PHONY: all
all: build

.PHONY: build
build:
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"
	@rm -rf "$(PRODUCTDIR)"
	@rm -rf "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(TEMPPRODUCTDIR)/include/swiftinfo"
	@cp -a "$(RELEASEBUILDDIR)/." "$(TEMPPRODUCTDIR)/include/swiftinfo"
	@cp -a "$(TEMPPRODUCTDIR)/." "$(PRODUCTDIR)"
	@rm -rf "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(PRODUCTDIR)/bin"
	@rm -rf $(PRODUCTDIR)/include/swiftinfo/ModuleCache
	@mv "$(PRODUCTDIR)/include/swiftinfo/swiftinfo" "$(PRODUCTDIR)/bin"
	@cp -a "$(REPODIR)/Sources/Csourcekitd/." "$(PRODUCTDIR)/include/swiftinfo/Csourcekitd"
	@rm -f "$(RELEASEBUILDDIR)/swiftinfo"
	@ln -s "$(PRODUCTDIR)/bin/swiftinfo" "$(RELEASEBUILDDIR)/swiftinfo"
	@cp "$(REPODIR)/LICENSE" "$(PRODUCTDIR)/LICENSE"

.PHONY: package
package:
	rm -f "$(PRODUCTDIR)/swiftinfo.zip"
	cd $(PRODUCTDIR) && zip -r ./swiftinfo.zip ./
	echo "ZIP created at: $(PRODUCTDIR)/swiftinfo.zip"

.PHONY: clean
clean:
	@rm -rf "$(BUILDDIR)"
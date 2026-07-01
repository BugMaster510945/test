APP_NAME ?= hello
GO ?= go
DIST_DIR ?= dist
VERSION ?= dev

# Default platforms are stable from a Linux builder.
PLATFORMS ?= linux/amd64 linux/arm64 linux/arm/v7 windows/amd64

DEB_VERSION ?= 0.0.0~git-1
DEB_DIST ?= trixie
CHANGELOG_MSG ?= Automated build from CI
MAINTAINER_NAME ?= CI Builder
MAINTAINER_EMAIL ?= ci@example.com

.PHONY: build dist clean debian-changelog deb

build:
	mkdir -p bin
	CGO_ENABLED=0 $(GO) build -trimpath -ldflags "-s -w" -o bin/$(APP_NAME) .

dist:
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	@set -e; \
	for platform in $(PLATFORMS); do \
		os=$${platform%%/*}; \
		rest=$${platform#*/}; \
		arch=$${rest%%/*}; \
		variant=""; \
		if [ "$$rest" != "$$arch" ]; then variant=$${rest#*/}; fi; \
		outfile="$(DIST_DIR)/$(APP_NAME)_$(VERSION)_$${os}_$${arch}"; \
		if [ -n "$$variant" ]; then outfile="$$outfile$$variant"; fi; \
		if [ "$${os}" = "windows" ]; then outfile="$$outfile.exe"; fi; \
		echo "Building $$outfile"; \
		GOOS="$${os}" GOARCH="$${arch}" GOARM="$${variant#v}" CGO_ENABLED=0 $(GO) build -trimpath -ldflags "-s -w" -o "$$outfile" .; \
	done

debian-changelog:
	@printf "hello (%s) %s; urgency=medium\n\n" "$(DEB_VERSION)" "$(DEB_DIST)" > debian/changelog
	@printf "  * %s\n\n" "$(CHANGELOG_MSG)" >> debian/changelog
	@printf " -- %s <%s>  %s\n" "$(MAINTAINER_NAME)" "$(MAINTAINER_EMAIL)" "$$(date -R)" >> debian/changelog

deb: debian-changelog
	dpkg-buildpackage -us -uc -b

clean:
	rm -rf bin $(DIST_DIR)
EXTENSION ?= 
DIST_DIR ?= dist/
GOOS ?= linux
ARCH ?= $(shell uname -m)
BUILDINFOSDET ?= 

SOFT_NAME    := gocast
SOFT_VERSION := $(shell git describe --tags $(git rev-list --tags --max-count=1))
VERSION_PKG   := $(shell echo $(SOFT_VERSION) | sed 's/^v//g')
ARCH          := x86_64
LICENSE       := MIT
URL           := https://github.com/mayuresh82/gocast
DESCRIPTION   := GoCast is a tool for controlled BGP route announcements from a host
BUILDINFOS    :=  ($(shell date +%FT%T%z)$(BUILDINFOSDET))
LDFLAGS       := '-X main.version=$(SOFT_VERSION) -X main.buildinfos=$(BUILDINFOS)'

OUTPUT_SOFT := $(DIST_DIR)gocast-$(SOFT_VERSION)-$(GOOS)-$(ARCH)$(EXTENSION)

.PHONY: vet
vet:
	go vet main.go

.PHONY: test
test:
	go test -v -race -short -failfast -mod=vendor  -v ./...

.PHONY: prepare
prepare:
	mkdir -p $(DIST_DIR)

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)

.PHONY: build
build: prepare
	go build -ldflags $(LDFLAGS) -o $(OUTPUT_SOFT)

debug:
	go build -mod=vendor -race $(DIST_DIR)

.PHONY: package-deb
package-deb: prepare
	fpm -s dir -t deb -n $(SOFT_NAME) -v $(VERSION_PKG) \
        --description "$(DESCRIPTION)"  \
        --url "$(URL)" \
        --architecture $(ARCH) \
        --license "$(LICENSE)" \
        --package $(DIST_DIR) \
        $(OUTPUT_SOFT)=/usr/bin/gocast \
		gocast.service=/usr/lib/systemd/system/gocast.service

.PHONY: package-rpm
package-rpm: prepare
	fpm -s dir -t rpm -n $(SOFT_NAME) -v $(VERSION_PKG) \
        --description "$(DESCRIPTION)"  \
        --url "$(URL)" \
        --architecture $(ARCH) \
        --license "$(LICENSE)" \
        --package $(DIST_DIR) \
        $(OUTPUT_SOFT)=/usr/bin/gocast \
		gocast.service=/usr/lib/systemd/system/gocast.service
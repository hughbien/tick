INSTALL_BIN ?= /usr/local/bin

build:
	crystal build --release tick.cr
	rm -f tick.dwarf

build-static:
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:0.36.1-alpine crystal build tick.cr --release --static
	mv tick tick-linux64

release: build-static
	$(eval VERSION := $(shell cat tick.cr | grep "VERSION = " | sed "s/\"//g" | cut -d " " -f5))
	$(eval MD5 := $(shell md5sum tick-linux64 | cut -d" " -f1))
	@echo v$(VERSION) $(MD5)
	sed -i "" -E "s/v[0-9]+\.[0-9]+\.[0-9]+/v$(VERSION)/g" README.md
	sed -i "" -E "s/[0-9a-f]{32}/$(MD5)/g" README.md

push:
	$(eval VERSION := $(shell cat tick.cr | grep "VERSION = " | sed "s/\"//g" | cut -d " " -f5))
	git tag v$(VERSION)
	git push --tags
	gh release create -R hughbien/tick -t v$(VERSION) v$(VERSION) ./tick-linux64

install: build
	cp tick $(INSTALL_BIN)

clean:
	rm -rf tick tick-linux64 tick.dwarf

run:
	crystal run tick.cr -- $(ARGS)

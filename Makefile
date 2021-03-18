INSTALL_BIN ?= /usr/local/bin

build: tick
tick:
	crystal build --release tick.cr
	rm tick.dwarf

build-static:
	docker run --rm -it -v $(PWD):/workspace -w /workspace crystallang/crystal:0.36.1-alpine crystal build tick.cr --release --static
	mv tick tick-linux64

install: build
	cp tick $(INSTALL_BIN)

clean:
	rm -rf tick tick-linux64 tick.dwarf

run:
	crystal run tick.cr -- $(ARGS)

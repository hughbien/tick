INSTALL_BIN ?= /usr/local/bin

build: tick
tick:
	crystal build --release tick.cr
	rm tick.dwarf

install: build
	cp tick $(INSTALL_BIN)

clean:
	rm -rf tick tick.dwarf

run:
	crystal run tick.cr -- $(ARGS)

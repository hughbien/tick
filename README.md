# Tick

Look up stock prices from the command line.

Implementation of [ticker.sh](https://github.com/pstadler/ticker.sh) in Crystal.

## Install

**Mac**

```
brew install hughbien/tap/tick
```

This will install Crystal as a dependency. If you already have a non-homebrew Crystal installed, you
can use the `--ignore-dependencies crystal` option.

**Linux**

Download the latest binary and place it in your `$PATH`:

```
wget -O /usr/local/bin/tick https://github.com/hughbien/tick/releases/download/v0.1.2/tick-linux-amd64
chmod +x /usr/local/bin/tick
```

MD5 checksum is: `b31ff0519db9d9751ae1cb050eafcf2b`

**From Source**

Checkout this repo, run `make` and `make install` (requires [Crystal](https://crystal-lang.org/install/)):

```
git clone https://github.com/hughbien/tick.git
cd tick
make
make install
```

## Usage

Look up symbols:

```
$ tick VTI VXUS BND
```

Keep your favorites in the `TICK` env variable:

```
export TICK="VTI VXUS BND"
$ tick
```

You can override the `TICK` env var by passing in a symbol. Use `-i` or `--include` to include
symbols in addition to your env vars.

```
$ tick GME     # just GME
$ tick -i GME  # VTI VXUS BND and GME
```

Use `-r` or `--regular` if you're only interested in regular market hours.

## TODO

* option to show regular + pre/post
* show periods (1d, 5d, 1m, 6m, ytd, 1y, 5y, max)

## License

Copyright 2021 Hugh Bien.

Released under BSD License, see LICENSE for details.

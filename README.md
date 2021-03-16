# Tick

Look up stock prices from the command line.

Implementation of [ticker.sh](https://github.com/pstadler/ticker.sh) in Crystal.

## Installation

1. install [Crystal](https://crystal-lang.org/install/)
2. checkout this repo
3. make build
4. move `tick` binary somewhere in your `$PATH`

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

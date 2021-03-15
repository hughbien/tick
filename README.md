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
TICK="VTI VXUS BND"
$ tick
```

You can override the `TICK` env var by passing in a symbol. Use the `+` prefix to look up in addition
to your defaults.

```
$ tick GME   # just GME
$ tick +GME  # VTI VXUS BND and GME
```

## License

Copyright 2021 Hugh Bien.

Released under BSD License, see LICENSE for details.

# Chaps

[![Build Status](https://github.com/the-mikedavis/chaps/workflows/tests/badge.svg)](https://github.com/the-mikedavis/chaps/actions)
[![hex.pm version](https://img.shields.io/hexpm/v/chaps.svg)](https://hex.pm/packages/chaps)
[![hex.pm license](https://img.shields.io/hexpm/l/chaps.svg)](https://github.com/the-mikedavis/chaps/blob/main/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/the-mikedavis/chaps.svg)](https://github.com/the-mikedavis/chaps/commits/main)

A fork of [ExCoveralls](https://github.com/parroty/excoveralls) focusing on the 100% coverage use-case.

## The 100% Coverage Use-Case

Shooting for 100% coverage is usually criticized as unnecessary and
unproductive, and I tend to agree with that sentiment. But as far as measuring
code coverage in percentage points goes, 100% is the only reasonable target:
any other percent-based target flaps around when SLOCs are added or removed.

Instead of shooting for a hard "we must get 100% coverage" rule, Chaps
recommends that you use ignores judiciously to avoid spending unnecessary
time trying to increase coverage, but still set the target coverage percentage
at 100%. This workflow sets a default "you must cover or ignore these lines"
mantra which forces code authors to be explicit.

This workflow also allows one to setup automated CI checks to fail when the
coverage is less than 100%, obviating the need to upload the coverage report
to an external service like coveralls.

## Installation

1. Add the dependency to your `mix.exs` `deps/0` function
1. Set the `test_coverage` tool in the `project/0` function
1. Set the `preferred_cli_env` to test for any tasks you intend to use

```
# mix.exs
def project do
  [
    app: :my_app,
    version: "0.0.1",
    elixir: "~> 1.6",
    deps: deps(),
    test_coverage: [tool: Chaps],    #2
    preferred_cli_env: [             #3
      chaps: :test,
      "chaps.html": :test
    ],
    # ..
  ]
end

defp deps do
  [
    {:chaps, "~> 0.1", only: :test}   #1
  ]
end
```

## Usage

Run `mix chaps` to run the test suite and show coverage. The output format
can be controlled by calling `mix chaps.<output format>` instead, where
`<output format>` can be any of

- `html`: an HTML based report showing coverage on source code
- `detail`: a terminal based output showing coverage on source code
- `json`, `xml`, or `lcov`: a JSON/XML/LCOV based data structure representing
  SLOCs

## Configuration

Chaps is configured in `config/test.exs` like so

```elixir
config :chaps,
  coverage_options: [
    treat_no_relevant_lines_as_covered: true
  ]
```

For the full schema, see the documentation of the `Chaps.Settings` module.

## Differences from `parroty/excoveralls`

- Coverage is truncated to the nearest tenth instead of rounded
- Tasks and dependencies for uploading coverage reports have been removed
    - the `:hackney` dependency has been removed
- Configuration is done in `config/test.exs` instead of a JSON file
    - the `:jason` dependency is optional and is only used if running
      `mix chaps.json`

## License/Notice

This repository is a fork of
[`parroty/excoveralls`](https://github.com/parroty/excoveralls). Almost
all source code originates from the original repository. The following
changes have been made to this repository but not the original and should
be considered copyright (c) 2021-present, the-mikedavis:

- Flooring of coverage percentage
    - [commit](097443d298f56240e46ac9615a5988de4533a6e1)
    - authored by [`@tonyvanriet`](https://github.com/tonyvanriet)
    - see [#257](https://github.com/parroty/excoveralls/pull/257)
- Replacement of JSON file configuration with application configuration
    - [commit](df24f58f2d0896b0e4097d8b29f66e24188805d4)

All remaining source code is copyright (c) 2013-present, parroty.

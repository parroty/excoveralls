# Chaps

[![Build Status](https://github.com/the-mikedavis/chaps/workflows/tests/badge.svg)](https://github.com/the-mikedavis/chaps/actions)
[![hex.pm version](https://img.shields.io/hexpm/v/chaps.svg)](https://hex.pm/packages/chaps)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/chaps.svg)](https://hex.pm/packages/chaps)
[![hex.pm license](https://img.shields.io/hexpm/l/chaps.svg)](https://github.com/the-mikedavis/chaps/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/the-mikedavis/chaps.svg)](https://github.com/the-mikedavis/chaps/commits/master)

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

## License/Notice

This repository is a fork of
[`parroty/excoveralls`](https://github.com/parroty/excoveralls). Almost
all source code originates from the original repository. The following
changes have been made to this repository but not the original and should
be considered copyright (c) 2021-present, the-mikedavis:

- TODO

All remaining source code is copyright (c) 2013-present, parroty.

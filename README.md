ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master)
============

A library to post coverage stats to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and post the result to coveralls.io through the json API.

Curerntly, it's under trial for travis-ci integration. [coverage_sample](https://github.com/parroty/coverage_sample) is an example using from a project.

# Setting
### mix.exs
Include :excoveralls in the deps section of the file.

```elixir
defp deps do
  [
    {:excoveralls, github: "parroty/excoveralls"}
  ]
end
```

## Run at Local
Run the "mix coveralls" task.
It locally prints out the coverage information. This task doesn't submit the result to server.

```
$ mix coveralls
...
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/excoveralls/general.ex                     28        4        0
 75.0% lib/excoveralls.ex                             54        8        2
 94.7% lib/excoveralls/stats.ex                       70       19        1
100.0% lib/excoveralls/poster.ex                      16        3        0
 95.5% lib/excoveralls/local.ex                       79       22        1
100.0% lib/excoveralls/travis.ex                      23        3        0
100.0% lib/mix/tasks.ex                               44        8        0
100.0% lib/excoveralls/cover.ex                       32        5        0
[TOTAL]  94.4%
----------------
```


## Run at Travis-CI
Specify "mix coveralls.travis" as after_success section of .travis.yml
It is for submiting the result to server when Travis-CI build is executed.

### .travis.yml
```
language: erlang
otp_release:
  - R16B
before_install:
  - git clone https://github.com/elixir-lang/elixir
  - cd elixir && make && cd ..
before_script: "export PATH=`pwd`/elixir/bin:$PATH"
script: "MIX_ENV=test mix do deps.get, test"
after_success:
  - "mix coveralls.travis"
```

## Run at Local with detailed information
Run the "mix coveralls.detail" task.
It displays coverage information at the source-code level in colored strings.
Green indicates covered line, and red indicates not-covered line.
If source is large, piping with "less" command may help looking into the detail.

```
$ mix coveralls.detail | less
...
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/excoveralls/general.ex                     28        4        0
...
[TOTAL]  94.4%

--------lib/excoveralls.ex--------
defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
...
```


## coveralls.conf
"coveralls.conf" provides a setting for excoveralls.

The default "coveralls.conf" is stored in "deps/excoveralls/lib/conf", and custom "coveralls.conf" can be placed under mix project root. The custom definition is prioritized over default one (if definitions in custom file is not found, definitions in default file is used).

### Stop Words
Stop words defined in "coveralls.conf" will be excluded from the coverage calculation. Some kernal macros defined in Elixir is not considered "covered" by Erlang's cover library. It can be used for excluding these macros, or any other reasons.

The words are taken as regular expression.
```
{
  "default_stop_words": [
    "defmodule",
    "defrecord",
    "defimpl",
    "def.+(.+\/\/.+).+do"
  ],

  "custom_stop_words": [
  ]
}
```

### Notes
- If meck library is being used, it shows some warnings during execution.
- When "mix coveralls" fails, "mix test" in advance, might avoid the error.

### TODO
- It depends on curl command for posting JSON. Replace it with Elixir library.
  - Tried to use hackney, but doesn't work well.

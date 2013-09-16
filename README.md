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

# Usage
## Check coverage at the local host
Run "mix coveralls" command.

This task locally prints out the coverage information. It doesn't submit the result to server.

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


## Post coverage from the Travis-CI server
Specify "mix coveralls.travis" as after_success section of .travis.yml.

This task is for submiting the result to coveralls server when Travis-CI build is executed.

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

## Post coverage from the local host
Set coveralls token as environment variable (COVERALLS_REPO_TOKEN), and then run "mix coveralls.post" command.

It is for submiting the result to coveralls server from the local host.

```
$ mix coveralls.post
...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16958  100    64  100 16894     23   6330  0:00:02  0:00:02 --:--:--  7644
{"message":"Job #xx.1","url":"https://coveralls.io/jobs/xxxx"}
```

## Check coverage at the local host with source detail
Run "mix coveralls.detail" command.

This task displays coverage information at the source-code level with colored text.
Green indicates covered line, and red indicates not-covered line.
If source is large, piping with "less" command may help looking around the detail.

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

## coveralls.json
"coveralls.json" provides a setting for excoveralls.

The default "coveralls.json" is stored in "deps/excoveralls/lib/conf", and custom "coveralls.json" can be placed under mix project root. The custom definition is prioritized over the default one (if definitions in custom file is not found, then definitions in default file is used).

### Stop Words
Stop words defined in "coveralls.json" will be excluded from the coverage calculation. Some kernal macros defined in Elixir is not considered "covered" by Erlang's cover library. It can be used for excluding these macros, or any other reasons.

The words are parsed as regular expression.
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
    - https://github.com/eproxus/meck/pull/17
- When Erlang clashes at "mix coveralls", executing "mix test" in advance might avoid the error.

### Todo
- It depends on curl command for posting JSON. Replace it with Elixir library.
  - Tried to use hackney, but doesn't work well.

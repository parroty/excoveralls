ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master)
============

A library to post coverage stats to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and post it to coveralls' json API.

Curerntly, it's under trial for travis-ci integration. [coverage_sample](https://github.com/parroty/coverage_sample) is an example using from a project.

# Setting
### mix.exs
Add setting parameters in the Mix.Project (excoveralls_setting) as follows, and include :excoveralls in deps.

```elixir
def project do
  [ app: :coverage_sample,
    version: "0.0.1",
    elixir: "~> 0.10.3-dev",
    deps: deps
  ]
end

defp deps do
  [
    {:excoveralls, github: "parroty/excoveralls"}
  ]
end
```

## Run at Local
Run the "mix coveralls" task.

```
$ mix coveralls
...
----------------
COV    FILE                                        LINES RELEVANT  COVERED
 50.0% lib/excoveralls.ex                             54        8        4
 60.0% lib/excoveralls/cover.ex                       27        5        3
100.0% lib/excoveralls/general.ex                     28        4        4
 77.3% lib/excoveralls/local.ex                       79       22       17
  0.0% lib/excoveralls/poster.ex                      16        3        0
 94.7% lib/excoveralls/stats.ex                       70       19       18
  0.0% lib/excoveralls/travis.ex                      23        3        0
[TOTAL]  71.9%
----------------
```


## Run at Travis-CI
### .travis.yml
Specify "mix coveralls.travis" as after_success section of .travis.yml

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

### Notes
- If meck library is used, it shows some warnings.

### TODO
- It depends on curl command for posting JSON. Replace it with Elixir library.
  - Tried to use hackney, but doesn't work well.
- Find a way to control mix behavior instead of adding custom "MIX_ENV".
- Simplify mix.exs setting.

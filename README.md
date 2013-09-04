ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master)
============

A library to post coverage stats to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and post it to coveralls' json API.

Curerntly, it's under trial for travis-ci integration.

# Setting
### mix.exs
Add env parameter in project, and include :excoveralls in deps.

```elixir
def project do
  [ app: :coverage_sample,
    version: "0.0.1",
    elixir: "~> 0.10.3-dev",
    deps: deps,
    env: [
      coveralls_travis:  [
        test_coverage: [output: "ebin", tool: ExCoveralls, type: "travis"]
      ]
    ]
  ]
end

defp deps do
  [
    {:excoveralls, github: "parroty/excoveralls"}
  ]
end
```

### .travis.yml
Specify "MIX_ENV=coveralls_travis mix test --cover" as after_success section of .travis.yml

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
  - "MIX_ENV=coveralls_travis mix test --cover"
```

### post.sh
Create post.sh with the following contents under project root, and assign executable(+x) permission.

```
curl "https://coveralls.io/api/v1/jobs" -F json_file=@tmp/post.json
```

### TODO
- It depends on curl command for posting JSON. Replace it with Elixir library.
- Find a way to control mix behavior instead of adding custom "MIX_ENV".

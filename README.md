ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/excoveralls.svg)](https://hex.pm/packages/excoveralls) [![hex.pm downloads](https://img.shields.io/hexpm/dt/excoveralls.svg)](https://hex.pm/packages/excoveralls)
============

An elixir library that reports test coverage statistics, with the option to post to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and posts the test coverage results to coveralls.io through the json API.

Currently, it's under trial for travis-ci integration.
  - [coverage_sample](https://github.com/parroty/coverage_sample) is a basic example project.
  - [excoveralls_umbrella](https://github.com/parroty/excoveralls_umbrella) is an example on umbrella project.

# Settings
### mix.exs
Add the following parameters.

- `test_coverage: [tool: ExCoveralls]` for using ExCoveralls for coverage reporting.
- `preferred_cli_env: [coveralls: :test]` for running `mix coveralls` in `:test` env by default
    - It's an optional setting for skipping `MIX_ENV=test` part when executing `mix coveralls` tasks.
- `test_coverage: [test_task: "espec"]` if you use Espec instead of default ExUnit.
- `:excoveralls` in the deps function.

```elixir
def project do
  [ app: :excoveralls,
    version: "1.0.0",
    elixir: "~> 1.0.0",
    deps: deps(Mix.env),
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
    # if you want to use espec,
    # test_coverage: [tool: ExCoveralls, test_task: "espec"]
  ]
end

defp deps do
  [{:excoveralls, "~> 0.3", only: :test}]
end
```

# Usage
## Mix Tasks
- [mix coveralls](#mix-coveralls-show-coverage)
- [mix coveralls.travis](#mix-coverallstravis-post-coverage-from-travis)
- [mix coveralls.post](#mix-coverallspost-post-coverage-from-localhost)
- [mix coveralls.detail](#mix-coverallsdetail-show-coverage-with-detail)

### [mix coveralls] Show coverage
Run the `MIX_ENV=test mix coveralls` command to show coverage information on localhost.
This task locally prints out the coverage information. It doesn't submit the results to the server.

```Shell
$ MIX_ENV=test mix coveralls
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

Specifying the --help option displays the options list for available tasks.

```Shell
Usage: mix coveralls
  Used to display coverage

  -h (--help)         Show helps for excoveralls mix tasks

  Common options across coveralls mix tasks

  -u (--umbrella)     Show overall coverage for umbrella project.
  -v (--verbose)      Show json string for posting.

Usage: mix coveralls.detail [--filter file-name-pattern]
  Used to display coverage with detail
  [--filter file-name-pattern] can be used to limit the files to be displayed in detail

Usage: mix coveralls.travis
  Used to post coverage from Travis CI server

Usage: mix coveralls.post [options] [coveralls-token]
  Used to post coverage from local server using token
  [coveralls-token] should be specified here or in COVERALLS_REPO_TOKEN
  environment variable

  -n (--name)         Service name ('VIA' column at coveralls page)
  -b (--branch)       Branch name ('BRANCH' column at coveralls page)
  -c (--committer)    Committer name ('COMMITTER' column at coveralls page)
  -m (--message)      Commit message ('COMMIT' column at coveralls page)
```

### [mix coveralls.travis] Post coverage to travis
Specify `mix coveralls.travis` in the `.travis.yml`.
This task is for submiting the result to the coveralls server when Travis-CI build is executed.

#### .travis.yml
```
language: erlang
otp_release:
  - R16B
before_install:
  - git clone https://github.com/elixir-lang/elixir
  - cd elixir && make && cd ..
before_script: "export PATH=`pwd`/elixir/bin:$PATH"
script:
  - "MIX_ENV=test mix do deps.get, compile, coveralls.travis"
```

### [mix coveralls.post] Post coverage from localhost
Acquire the repository token of coveralls.io in advance, and run the `mix coveralls.post` command.
It is for submitting the result to coveralls server from localhost.

The token can be specified as a mix task argument, or as an environment variable (`COVERALLS_REPO_TOKEN`).

```Shell
$ MIX_ENV=test mix coveralls.post [YOUR_TOKEN]
...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16958  100    64  100 16894     23   6330  0:00:02  0:00:02 --:--:--  7644
{"message":"Job #xx.1","url":"https://coveralls.io/jobs/xxxx"}
```

### [mix coveralls.detail] Show coverage with detail
This task displays coverage information at the source-code level with colored text.
Green indicates a tested line, and red indicates lines which are not tested.
When reviewing many source files, pipe the output to the `less` program (with the `-R` option for color) to paginate the results.

```Shell
$ MIX_ENV=test mix coveralls.detail | less -R
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

Also, displayed source code can be filtered by specifying arguments (it will be matched against the FILE column value). The following example lists the source code only for general.ex.
```Shell
$ MIX_ENV=test mix coveralls.detail --filter general.ex
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
`coveralls.json` provides a setting for excoveralls.

The default `coveralls.json` file is stored in `deps/excoveralls/lib/conf`, and custom `coveralls.json` files can be placed in the mix project root. The custom definition is prioritized over the default one (if definitions in custom file are not found, then the definitions in the default file are used).

#### Stop Words
Stop words defined in `coveralls.json` will be excluded from the coverage calculation. Some kernal macros defined in Elixir are not considered "covered" by Erlang's cover library. It can be used for excluding these macros, or for any other reasons. The words are parsed as regular expression.

#### Coverage Options
- treat_no_relevant_lines_as_covered
   - By default, coverage for [files with no relevant lines] are displayed as 0% for aligning with coveralls.io behavior. But, if `treat_no_relevant_lines_as_covered` is set to `true`, it will be displayed as 100%.

```javascript
{
  "default_stop_words": [
    "defmodule",
    "defrecord",
    "defimpl",
    "def.+(.+\/\/.+).+do"
  ],

  "custom_stop_words": [
  ],

  "coverage_options": {
    "treat_no_relevant_lines_as_covered": true
  }
}
```

### Notes
- If mock library is used, it will show some warnings during execution.
    - https://github.com/eproxus/meck/pull/17
- In case Erlang clashes at `mix coveralls`, executing `mix test` in advance might avoid the error.
- When erlang version 17.3 is used, an error message `(MatchError) no match of right hand side value: ""` can be shown. Refer to issue #14 for the details.
    - https://github.com/parroty/excoveralls/issues/14

### Todo
- It might not work well on projects which handle multiple project (Mix.Project) files.
    - Needs improvement on file-path handling.

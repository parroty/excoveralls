ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.png?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.png?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/excoveralls.svg)](https://hex.pm/packages/excoveralls) [![hex.pm downloads](https://img.shields.io/hexpm/dt/excoveralls.svg)](https://hex.pm/packages/excoveralls)
============

An elixir library to report coverage stats, with a capability to post it to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and post the result to coveralls.io through the json API.

Curerntly, it's under trial for travis-ci integration. [coverage_sample](https://github.com/parroty/coverage_sample) is an example using from a project.

# Setting
### mix.exs
Add the following parameters.

- `test_coverage: [tool: ExCoveralls]` in the project function.
- `:excoveralls` in the deps function.

```elixir
def project do
  [ app: :excoveralls,
    version: "1.0.0",
    elixir: "~> 0.xx.yy",
    deps: deps(Mix.env),
    test_coverage: [tool: ExCoveralls]
  ]
end

defp deps do
  [{:excoveralls, "~> 0.3", only: [:dev, :test]}]
end
```

# Usage
## Mix Tasks
- [mix coveralls](#mix-coveralls-show-coverage)
- [mix coveralls.travis](#mix-coverallstravis-post-coverage-from-travis)
- [mix coveralls.post](#mix-coverallspost-post-coverage-from-localhost)
- [mix coveralls.detail](#mix-coverallsdetail-show-coverage-with-detail)

### [mix coveralls] Show coverage
Run "mix coveralls" command to show coverage information at the local host
This task locally prints out the coverage information. It doesn't submit the result to server.

```Shell
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

Specifying the --help option displays the option lists for available tasks.

```Shell
$ mix coveralls --help
Usage: mix coveralls
  Used to display coverage

  -h (--help)         Show helps for excoveralls mix tasks

Usage: mix coveralls.detail [file-name-pattern]
  Used to display coverage with detail
  [file-name-pattern] can be used to limit the target files

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

### [mix coveralls.travis] Post coverage from travis
Specify `mix compile && mix coveralls.travis` as after_success section of .travis.yml.
This task is for submiting the result to coveralls server when Travis-CI build is executed.

#### .travis.yml
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
  - "mix compile && mix coveralls.travis"
```

### [mix coveralls.post] Post coverage from localhost
Acquire the repository token of coveralls.io in advance, and run "mix coveralls.post" command.
It is for submiting the result to coveralls server from the local host.

The token can be specified as mix task argument, or as environment variable (COVERALLS_REPO_TOKEN).

```Shell
$ mix coveralls.post [YOUR_TOKEN]
...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 16958  100    64  100 16894     23   6330  0:00:02  0:00:02 --:--:--  7644
{"message":"Job #xx.1","url":"https://coveralls.io/jobs/xxxx"}
```

### [mix coveralls.detail] Show coverage with detail
This task displays coverage information at the source-code level with colored text.
Green indicates covered line, and red indicates not-covered line.
If source is large, piping with "less" command may help looking around the detail.

```Shell
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

Also, displayed source codes can be filtered by specifying arguments (it will be matched against FILE column value). The following example lists the source codes only for general.ex.
```Shell
$ mix coveralls.detail general.ex
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

The default `coveralls.json` is stored in `deps/excoveralls/lib/conf`, and custom `coveralls.json` can be placed just under mix project root. The custom definition is prioritized over the default one (if definitions in custom file is not found, then definitions in default file is used).

#### Stop Words
Stop words defined in "coveralls.json" will be excluded from the coverage calculation. Some kernal macros defined in Elixir is not considered "covered" by Erlang's cover library. It can be used for excluding these macros, or any other reasons. The words are parsed as regular expression.

#### Coverage Options
- treat_no_relevant_lines_as_covered
   - By default, coverage for [files with no relevant lines] are displayed as 0% for aligning with coveralls.io behavior. But, if `treat_no_relevant_lines_as_covered` is set as `true`, it will be displayed as 100%.

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
- If meck library is being used, it shows some warnings during execution.
    - https://github.com/eproxus/meck/pull/17
- In case Erlang clashes at `mix coveralls`, executing `mix test` in advance might avoid the error.
- When erlang version 17.3 is used, an error message `(MatchError) no match of right hand side value: ""` can be shown. Refer to issue #14 for the details.

### Todo
- It might not work well on the projects which handles multiple project (Mix.Project) files.
    - Need improvement on file-path handling.

ExCoveralls [![Build Status](https://secure.travis-ci.org/parroty/excoveralls.svg?branch=master "Build Status")](http://travis-ci.org/parroty/excoveralls) [![Coverage Status](https://coveralls.io/repos/parroty/excoveralls/badge.svg?branch=master)](https://coveralls.io/r/parroty/excoveralls?branch=master) [![hex.pm version](https://img.shields.io/hexpm/v/excoveralls.svg)](https://hex.pm/packages/excoveralls) [![hex.pm downloads](https://img.shields.io/hexpm/dt/excoveralls.svg)](https://hex.pm/packages/excoveralls) [![Deps Status](https://beta.hexfaktor.org/badge/all/github/parroty/excoveralls.svg)](https://beta.hexfaktor.org/github/parroty/excoveralls)
============

An Elixir library that reports test coverage statistics, with the option to post to [coveralls.io](https://coveralls.io/) service.
It uses Erlang's [cover](http://www.erlang.org/doc/man/cover.html) to generate coverage information, and posts the test coverage results to coveralls.io through the json API.

The following are example projects.
  - [coverage_sample](https://github.com/parroty/coverage_sample) is for Travis CI.
  - [circle_sample](https://github.com/parroty/circle_sample) is for CircleCI .
  - [semaphore_sample](https://github.com/parroty/semaphore_sample) is for Semaphore CI.
  - [excoveralls_umbrella](https://github.com/parroty/excoveralls_umbrella) is for umbrella project.
  - [gitlab_sample](https://gitlab.com/parroty/gitlab_sample) is for GitLab CI (using GitLab CI feature instead of coveralls.io).

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
  [
    app: :excoveralls,
    version: "1.0.0",
    elixir: "~> 1.0.0",
    deps: deps(Mix.env),
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
    # if you want to use espec,
    # test_coverage: [tool: ExCoveralls, test_task: "espec"]
  ]
end

defp deps do
  [
    {:excoveralls, "~> 0.8", only: :test}
  ]
end
```

**Note:** If you're using earlier than `elixir v1.3`, `MIX_ENV=test` or `preferred_cli_env` may be required for running mix tasks. Refer to [PR#96](https://github.com/parroty/excoveralls/pull/96) for the details.

# Usage
## Mix Tasks
- [mix coveralls](#mix-coveralls-show-coverage)
- [mix coveralls.travis](#mix-coverallstravis-post-coverage-from-travis)
- [mix coveralls.circle](#mix-coverallscircle-post-coverage-from-circle)
- [mix coveralls.semaphore](#mix-coverallssemaphore-post-coverage-from-semaphore)
- [mix coveralls.post](#mix-coverallspost-post-coverage-from-any-host)
- [mix coveralls.detail](#mix-coverallsdetail-show-coverage-with-detail)
- [mix coveralls.html](#mix-coverallshtml-show-coverage-as-html-report)

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
Usage: mix coveralls <Options>
  Used to display coverage

  <Options>
    -h (--help)         Show helps for excoveralls mix tasks

    Common options across coveralls mix tasks

    -u (--umbrella)     Show overall coverage for umbrella project.
    -v (--verbose)      Show json string for posting.

Usage: mix coveralls.detail [--filter file-name-pattern]
  Used to display coverage with detail
  [--filter file-name-pattern] can be used to limit the files to be displayed in detail.

Usage: mix coveralls.travis [--pro]
  Used to post coverage from Travis CI server.

Usage: mix coveralls.post <Options>
  Used to post coverage from local server using token.
  The token should be specified in the argument or in COVERALLS_REPO_TOKEN
  environment variable.

  <Options>
    -t (--token)        Repository token ('REPO TOKEN' of coveralls.io)
    -n (--name)         Service name ('VIA' column at coveralls.io page)
    -b (--branch)       Branch name ('BRANCH' column at coveralls.io page)
    -c (--committer)    Committer name ('COMMITTER' column at coveralls.io page)
    -m (--message)      Commit message ('COMMIT' column at coveralls.io page)
    -s (--sha)          Commit SHA (required when not using Travis)
```

### [mix coveralls.travis] Post coverage from travis
Specify `mix coveralls.travis` as the build script in the `.travis.yml` and explicitly set the `MIX_ENV` environment to `TEST`.
This task submits the result to Coveralls when the build is executed on Travis CI.

#### .travis.yml
```yml
language: elixir

elixir:
  - 1.2.0

otp_release:
  - 18.0

env:
  - MIX_ENV=test

script: mix coveralls.travis
```

If you're using [Travis Pro](https://travis-ci.com/) for a private
project, Use `coveralls.travis --pro` and ensure your coveralls.io
repo token is available via the `COVERALLS_REPO_TOKEN` environment
variable.

### [mix coveralls.circle] Post coverage from circle
Specify `mix coveralls.circle` in the `circle.yml`.
This task is for submitting the result to the coveralls server when Circle-CI build is executed.

#### circle.yml
```yml
test:
  override:
    - mix coveralls.circle
```

Ensure your coveralls.io repo token is available via the `COVERALLS_REPO_TOKEN` environment
variable.

### [mix coveralls.semaphore] Post coverage from semaphore
Specify `mix coveralls.semaphore` in the build command prompt for instructions in semaphore.
This task is for submitting the result to the coveralls server when Semaphore-CI build is executed.

#### semaphore build instructions
```
mix coveralls.semaphore
```

Ensure your coveralls.io repo token is available via the `COVERALLS_REPO_TOKEN` environment
variable.

### [mix coveralls.post] Post coverage from any host
Acquire the repository token of coveralls.io in advance, and run the `mix coveralls.post` command.
It is for submitting the result to coveralls server from any host.

The token can be specified as a mix task option (`--token`), or as an environment variable (`COVERALLS_REPO_TOKEN`).

```Shell
MIX_ENV=test mix coveralls.post --token [YOUR_TOKEN] --branch "master" --name "local host" --commiter "committer name" --sha "fd80a4c" --message "commit message"
....................................................................................................

Finished in 6.3 seconds (0.7s on load, 5.6s on tests)
100 tests, 0 failures

Randomized with seed 800810
Successfully uploaded the report to 'https://coveralls.io'.
```
For the detailed option description, check [mix coveralls --help](#mix-coveralls-show-coverage) task.

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

### [mix coveralls.html] Show coverage as HTML report
This task displays coverage information at the source-code level formatted as an HTML page.
The report follows the format inspired by HTMLCov from the Mocha testing library in JS.
Output to the shell is the same as running the command `mix coveralls`. In a similar manner to `mix coveralls.detail`, reported source code can be filtered by specifying arguments using the `--filter` flag.

```Shell
$ MIX_ENV=test mix coveralls.html
```
![HTML Report](./README/html_report.jpg?raw=true "HTML Report")

Output reports are written to `cover/excoveralls.html` by default, however, the path can be specified by overwriting the `"output_dir"` coverage option.
Custom reports can be created and utilized by defining `template_path` in `coveralls.json`. This directory should
contain an eex template named `coverage.html.eex`.

## coveralls.json
`coveralls.json` provides settings for excoveralls.

The default `coveralls.json` file is stored in `deps/excoveralls/lib/conf`, and custom `coveralls.json` files can be placed in the mix project root. The custom definition is prioritized over the default one (if definitions in the custom file are not found, then the definitions in the default file are used).

#### Stop Words
Stop words defined in `coveralls.json` will be excluded from the coverage calculation. Some kernel macros defined in Elixir are not considered "covered" by Erlang's cover library. It can be used for excluding these macros, or for any other reasons. The words are parsed as regular expression.

#### Exclude Files

If you want to exclude/ignore files from the coverage calculation add the `skip_files` key in the `coveralls.json` file. `skip_files` takes an array of file paths, for example:

```javascript
{
  "skip_files": [
    "folder_to_skip",
    "folder/file_to_skip.ex"
  ]
}
```

Note that this doesn't work directly in an umbrella project. If you need to exclude files within an app, you should create a separate `coveralls.json` at the root of the app's folder and add a `skip_files` key to _that_ file. Paths should be relative to that file, not the umbrella project.

#### Terminal Report Output
When using in umbrella projects the default report may trim files names when viewing report in terminal.

If you want to change the column width used for file names add the `file_column_width` key to the `terminal_options` key in the `coveralls.json`, for example:

```javascript
{
  "terminal_options": {
    "file_column_width": 40
  }
}
```
#### Coverage Options
- treat_no_relevant_lines_as_covered
  - By default, coverage for [files with no relevant lines] are displayed as 0% for aligning with coveralls.io behavior. But, if `treat_no_relevant_lines_as_covered` is set to `true`, it will be displayed as 100%.
- output_dir
  - The directory which the HTML report will output to. Defaulted to `cover/`.
- template_path
  - A custom path for html reports. This defaults to the htmlcov report in the excoveralls lib.
- minimum_coverage
  - When set to a number greater than 0, this setting causes the `mix coveralls` and `mix coveralls.html` tasks to exit with a status code of 1 if test coverage falls below the specified threshold (defaults to 0). This is useful to interrupt CI pipelines with strict code coverage rules. Should be expressed as a number between 0 and 100 signifying the minimum percentage of lines covered.

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
    "treat_no_relevant_lines_as_covered": true,
    "output_dir": "cover/",
    "template_path": "custom/path/to/template/",
    "minimum_coverage": 90
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


defmodule ExCoveralls.Task.Util do
  @moduledoc """
  Provides task related utilities.
  """

  def print_help_message do
    IO.puts """
Usage: mix coveralls <Options>
  Used to display coverage

  <Options>
    -h (--help)         Show helps for excoveralls mix tasks

    Common options across coveralls mix tasks

    -o (--output-dir)   Write coverage information to output dir.
    -u (--umbrella)     Show overall coverage for umbrella project.
    -v (--verbose)      Show json string for posting.

Usage: mix coveralls.detail [--filter file-name-pattern]
  Used to display coverage with detail
  [--filter file-name-pattern] can be used to limit the files to be displayed in detail.

Usage: mix coveralls.html
  Used to display coverage information at the source-code level formatted as an HTML page.

Usage: mix coveralls.travis [--pro]
  Used to post coverage from Travis CI server.

Usage: mix coveralls.github
  Used to post coverage from a GitHub Action.

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
    --build             Service number ('BUILDS' column at coveralls.io page)
    --parallel          coveralls.io 'parallel' option (See coveralls.io API Reference)
    --subdir            Git repo sub directory: This will be added to the the front of file path, use if your covered
                        file paths reside within a subfolder of the git repo. Example: If your source file path is
                        "test.ex", and your git repo root is one directory up making the file's relative path
                        "src/lib/test.ex", then the sub directory should be: "src/lib" (from coveralls.io)
    --rootdir           This will be stripped from the file path in order to resolve the relative path of this repo's
                        files. It should be the path to your git repo's root on your CI build environment. This is not
                        needed if your source file path is already relative. It's used to pull the source file from the
                        github repo, so must be exact. Example: If your source file path is "/home/runs/app/test.ex",
                        and your git repo resides in "app", then the root path should be: "/home/runs/app/" (from
                        coveralls.io)
"""
  end
end

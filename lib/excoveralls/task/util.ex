defmodule ExCoveralls.Task.Util do
  @moduledoc """
  Provides task related utilities.
  """

  def print_help_message do
    IO.puts """
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

"""
  end
end

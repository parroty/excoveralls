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

  -n (--name)         Service name ('VIA' column of coveralls page)
"""
  end
end

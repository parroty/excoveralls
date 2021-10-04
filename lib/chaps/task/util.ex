defmodule Chaps.Task.Util do
  @moduledoc """
  Provides task related utilities.
  """

  def print_help_message do
    IO.puts("""
    Usage: mix chaps <Options>
      Used to gather and display coverage

      <Options>
        -h (--help)         Show helps for chaps mix tasks

        Common options across chaps mix tasks

        -o (--output-dir)   Write coverage information to output dir.
        -u (--umbrella)     Show overall coverage for umbrella project.
        -v (--verbose)      Show json string for posting.

    Usage: mix chaps.detail [--filter file-name-pattern]
      Used to display coverage with detail
      [--filter file-name-pattern] can be used to limit the files to be displayed in detail.

    Usage: mix chaps.html
      Used to display coverage information at the source-code level formatted as an HTML page.
    """)
  end
end

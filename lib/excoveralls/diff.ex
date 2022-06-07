defmodule ExCoveralls.Diff do
  @moduledoc """
  Analyze coverage stats for the git diff.
  """

  alias ExCoveralls.Stats

  @changed_line [IO.ANSI.color(0, 5, 0)]
  @covered_line [IO.ANSI.color(1, 3, 1)]
  @missed_line [IO.ANSI.color(3, 1, 1)]
  @no_color []
  @git_diff_regex ~r/^@@[^+]+\+(\d+),?(\d+)? @@/

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options) do
    files = options[:files]

    stats
    |> Enum.filter(&Enum.member?(files, &1[:name]))
    |> Stats.source()
    |> analyze(options)
    |> print_coverage_results(options)
  end

  @doc """
  Get changed files from git-diff.
  """
  def diff_file_names(options) do
    rev = options[:from_git_rev]
    paths = options[:paths]

    case System.cmd("git", ["diff", "--name-only", rev, "HEAD", "--"] ++ paths) do
      {"", 0} ->
        Keyword.put(options, :files, [])

      {diff, 0} ->
        Keyword.put(options, :files, String.split(diff, "\n"))

      _else ->
        raise ExCoveralls.InvalidOptionError, message: "Unexpected arguments"
    end
  end

  defp analyze(%Stats.Source{} = source, options) do
    changed_ranges = get_changed_ranges(source, options[:from_git_rev])

    {sloc, misses} =
      Enum.map(changed_ranges, &Enum.slice(source.source, &1))
      |> List.flatten()
      |> Enum.reduce({0, 0}, fn line, {sloc, misses} ->
        cond do
          line.coverage == nil ->
            {sloc, misses}

          line.coverage > 0 ->
            {sloc + 1, misses}

          true ->
            {sloc + 1, misses + 1}
        end
      end)

    %{
      filename: source.filename,
      lines: source.source,
      sloc: sloc,
      misses: misses,
      changed_ranges: changed_ranges
    }
  end

  defp analyze(report, options) do
    files = Enum.map(report.files, &analyze(&1, options))

    {sloc, misses} =
      Enum.reduce(files, {0, 0}, fn file, {sloc, misses} ->
        {sloc + file.sloc, misses + file.misses}
      end)

    covered = sloc - misses

    coverage =
      if sloc != 0 do
        Float.round(100 * covered / sloc, 2)
      else
        0.0
      end

    %{files: files, sloc: sloc, covered: covered, misses: misses, coverage: coverage}
  end

  defp get_changed_ranges(source, rev) do
    {diff, 0} = System.cmd("git", ["diff", "-U0", "--no-color", rev, "HEAD", source.filename])

    diff
    |> String.split("\n")
    |> Enum.reduce([], fn str, acc ->
      case Regex.run(@git_diff_regex, str) do
        [_0, line] ->
          start = String.to_integer(line)
          [(start - 1)..(start - 1) | acc]

        [_0, line, shift] ->
          start = String.to_integer(line)
          count = String.to_integer(shift)

          if count > 0 do
            [(start - 1)..(start - 2 + count) | acc]
          else
            acc
          end

        nil ->
          acc
      end
    end)
  end

  defp print_coverage_results(report, options) do
    report.files
    |> Enum.reject(&(&1.sloc == 0))
    |> Enum.each(fn source ->
      covered = source.sloc - source.misses
      IO.puts("\nNew code coverage for #{source.filename}:\n")
      IO.puts(["      ", colorize([], "Relevant:  #{source.sloc}")])
      IO.puts(["      ", colorize([@covered_line], "Covered:   #{covered}")])
      IO.puts(["      ", colorize([@missed_line], "Missed:    #{source.misses}")])

      print_coverage_lines(source, options)

      IO.puts("\n")
    end)

    IO.puts("TOTAL\n")
    IO.puts([colorize([], "Relevant:  #{report.sloc}")])
    IO.puts([colorize([@covered_line], "Covered:   #{report.covered}")])
    IO.puts([colorize([@missed_line], "Missed:    #{report.misses}")])
    IO.puts([colorize([@no_color], "Coverage:  #{report.coverage}\n")])

    if report.coverage < options[:threshold] && report.sloc != 0 do
      message =
        "FAILED: Expected minimum coverage of #{options[:threshold]}%, got #{report.coverage}%."

      IO.puts(IO.ANSI.format([:red, :bright, message]))
      exit({:shutdown, 1})
    end
  end

  defp print_coverage_lines(source, options) do
    {diff, 0} =
      System.cmd("git", ["diff", "--no-color", options[:from_git_rev], "HEAD", source.filename])

    diff
    |> String.split("\n")
    |> Enum.each(fn str ->
      case Regex.run(@git_diff_regex, str) do
        [_0, line] ->
          start = String.to_integer(line)
          print_diff_range((start - 1)..(start - 1), source)

        [_0, line, shift] ->
          start = String.to_integer(line)
          count = String.to_integer(shift)

          if count > 0 do
            print_diff_range((start - 1)..(start - 2 + count), source)
          else
            :skip
          end

        nil ->
          :skip
      end
    end)
  end

  defp print_diff_range(range, source) do
    if Enum.any?(source.changed_ranges, &(!disjoint?(&1, range))) do
      IO.puts("\n")

      Enum.each(range, fn line_number ->
        changed? = Enum.any?(source.changed_ranges, &Enum.member?(&1, line_number))
        line = Enum.at(source.lines, line_number)
        if line, do: print_line(line_number, line, changed?)
      end)
    end
  end

  defp print_line(line_number, line, changed?) do
    status = line_status(changed?, line.coverage)

    line_color =
      case status do
        :covered -> @covered_line
        :missed -> @missed_line
        _else -> @no_color
      end

    line_num = String.pad_leading(to_string(line_number + 1), 4)

    line_num_color =
      case status do
        :regular -> @no_color
        _else -> @changed_line
      end

    IO.puts([
      line_num,
      colorize(line_num_color, " │"),
      colorize(line_color, "#{line.source}")
    ])
  end

  defp line_status(true, nil), do: :changed
  defp line_status(true, 0), do: :missed
  defp line_status(true, _coverage), do: :covered
  defp line_status(false, _coverage), do: :regular

  defp colorize(escape, string) do
    [escape, string, :reset]
    |> IO.ANSI.format_fragment(true)
    |> IO.iodata_to_binary()
  end

  defp disjoint?(one, two) do
    !Enum.any?(one, &Enum.member?(two, &1))
  end
end

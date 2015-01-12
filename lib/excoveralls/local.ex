defmodule ExCoveralls.Local do
  @moduledoc """
  Locally displays the result to screen.
  """

  @doc """
  Stores count information for calculating coverage values.
  """
  defmodule Count do
    defstruct lines: 0, relevant: 0, covered: 0
  end

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    IO.puts "----------------"
    IO.puts print_string("~-6s ~-40s ~8s ~8s ~8s", ["COV", "FILE", "LINES", "RELEVANT", "MISSED"])
    coverage(stats) |> IO.puts
    IO.puts "----------------"

    if options[:detail] == true do
      source(stats, options[:args]) |> IO.puts
    end
  end

  @doc """
  Format the source code with color for the files that matches with
  the specified patterns.
  """
  def source(stats, _patterns = nil), do: source(stats)
  def source(stats, _patterns = []),  do: source(stats)
  def source(stats, patterns) do
    Enum.filter(stats, fn(stat) -> String.contains?(stat[:name], patterns) end) |> source
  end

  def source(stats) do
    stats |> Enum.map(&format_source/1)
          |> Enum.join("\n")
  end

  defp format_source(stat) do
    "\n\e[33m--------#{stat[:name]}--------\e[m\n" <> colorize(stat)
  end

  defp colorize([{:name, _name}, {:source, source}, {:coverage, coverage}]) do
    lines = String.split(source, "\n")
    Enum.zip(lines, coverage)
      |> Enum.map(&do_colorize/1)
      |> Enum.join("\n")
  end

  defp do_colorize({line, coverage}) do
    case coverage do
      nil -> line
      0   -> "\e[31m#{line}\e[m"
      _   -> "\e[32m#{line}\e[m"
    end
  end

  @doc """
  Format the source coverage stats into string.
  """
  def coverage(stats) do
    stats = Enum.sort(stats, fn(x, y) -> x[:name] <= y[:name] end)
    count_info = Enum.map(stats, fn(stat) -> [stat, calculate_count(stat[:coverage])] end)
    Enum.join(format_body(count_info), "\n") <> "\n" <> format_total(count_info)
  end

  defp format_body(info) do
    Enum.map(info, &format_info/1)
  end

  defp format_info([stat, count]) do
    coverage = get_coverage(count)
    print_string("~5.1f% ~-40s ~8w ~8w ~8w",
      [coverage, stat[:name], count.lines, count.relevant, count.relevant - count.covered])
  end


  defp format_total(info) do
    totals   = Enum.reduce(info, %Count{}, fn([_, count], acc) -> append(count, acc) end)
    coverage = get_coverage(totals)
    print_string("[TOTAL] ~5.1f%", [coverage])
  end

  defp append(a, b) do
    %Count{
      lines: a.lines + b.lines,
      relevant: a.relevant + b.relevant,
      covered: a.covered  + b.covered
    }
  end

  defp get_coverage(count) do
    case count.relevant do
      0 -> 100.0
      _ -> (count.covered / count.relevant) * 100
    end
  end

  @doc """
  Calucate count information from thhe coverage stats.
  """
  def calculate_count(coverage) do
    do_calculate_count(coverage, 0, 0, 0)
  end

  defp do_calculate_count([], lines, relevant, covered) do
    %Count{lines: lines, relevant: relevant, covered: covered}
  end

  defp do_calculate_count([h|t], lines, relevant, covered) do
    case h do
      nil -> do_calculate_count(t, lines + 1, relevant, covered)
      0   -> do_calculate_count(t, lines + 1, relevant + 1, covered)
      n when is_number(n)
          -> do_calculate_count(t, lines + 1, relevant + 1, covered + 1)
      _   -> raise "Invalid data - #{h}"
    end
  end

  defp print_string(format, params) do
    char_list = :io_lib.format(format, params)
    List.to_string(char_list)
  end
end

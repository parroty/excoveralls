defmodule ExCoveralls.Local do
  @moduledoc """
  Locally displays the result to screen.
  """
  import ExPrintf

  @doc """
  Stores count information for calculating coverage values
  """
  defrecord Count, lines: 0, relevant: 0, covered: 0

  @doc """
  Provides an entry point for the module
  """
  def execute(stats, options // []) do
    IO.puts "----------------"
    IO.puts sprintf("%-6s %-40s %8s %8s %8s", ["COV", "FILE", "LINES", "RELEVANT", "MISSED"])
    coverage(stats) |> IO.puts
    IO.puts "----------------"

    if options[:detail] == true do
      source(stats) |> IO.puts
    end
  end

  @doc """
  Format the source code with color
  """
  def source(stats) do
    Enum.map(stats, &format_source/1) |> Enum.join("\n")
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
  Format the source coverage stats into string
  """
  def coverage(stats) do
    count_info = Enum.map(stats, fn(stat) -> [stat, calculate_count(stat[:coverage])] end)
    Enum.join(format_body(count_info), "\n") <> "\n" <> format_total(count_info)
  end

  defp format_body(info) do
    Enum.map(info, &format_info/1)
  end

  defp format_info([stat, count]) do
    coverage = get_coverage(count)
    sprintf("%5.1f%% %-40s %8d %8d %8d",
      [coverage, stat[:name], count.lines, count.relevant, count.relevant - count.covered])
  end


  defp format_total(info) do
    totals   = Enum.reduce(info, Count.new, fn([_, count], acc) -> append(count, acc) end)
    coverage = get_coverage(totals)
    sprintf("[TOTAL] %5.1f%%", [coverage])
  end

  defp append(a, b) do
    Count.new(
      lines: a.lines + b.lines,
      relevant: a.relevant + b.relevant,
      covered: a.covered  + b.covered
    )
  end

  defp get_coverage(count) do
    case count.relevant do
      0 -> 0
      _ -> (count.covered / count.relevant) * 100
    end
  end

  @doc """
  Calucate counts information from thhe coverage stats
  """
  def calculate_count(coverage) do
    do_calculate_count(coverage, 0, 0, 0)
  end

  defp do_calculate_count([], lines, relevant, covered) do
    Count.new(lines: lines, relevant: relevant, covered: covered)
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
end

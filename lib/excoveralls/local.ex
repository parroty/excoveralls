defmodule ExCoveralls.Local do
  @moduledoc """
  Locally displays the result to screen.
  """

  def execute(stats) do
    Enum.map(stats, fn(stat) -> format(stat) end)
      |> Enum.join("\n")
  end

  def format(stat) do
    counts = calculate_count(stat[:coverage])
    coverage = (counts[:covered] / counts[:relevant]) * 100
    "#{stat[:name]} #{coverage}%"
  end

  def calculate_count(counts) do
    do_calculate_count(counts, 0, 0, 0)
  end

  def do_calculate_count([], lines, relevant, covered) do
    [lines: lines, relevant: relevant, covered: covered]
  end

  def do_calculate_count([h|t], lines, relevant, covered) do
    case h do
      0   -> do_calculate_count(t, lines + 1, relevant + 1, covered)
      1   -> do_calculate_count(t, lines + 1, relevant + 1, covered + 1)
      nil -> do_calculate_count(t, lines + 1, relevant, covered)
      _   -> raise "invalid data #{h}"
    end
  end
end

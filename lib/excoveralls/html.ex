defmodule ExCoveralls.Html do
  @moduledoc """
  Generate HTML report of result.
  """
  
  alias ExCoveralls.Html.View

  @file_name "excoveralls.html"

  defmodule Line do
    @moduledoc """
    Stores count information and source for a sigle line.
    """

    defstruct coverage: nil, source: ""
  end

  defmodule Source do
    @moduledoc """
    Stores count information for a file and all source lines.
    """

    defstruct filename: "", coverage: 0, sloc: 0, hits: 0, misses: 0, source: []
  end

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    ExCoveralls.Local.print_summary(stats)

    source(stats, options[:filter]) |> generate_report
  end

  @doc """
  Format the source code as an HTML report.
  """
  def source(stats, _patterns = nil), do: source(stats)
  def source(stats, _patterns = []),  do: source(stats)
  def source(stats, patterns) do
    Enum.filter(stats, fn(stat) -> String.contains?(stat[:name], patterns) end) |> source
  end

  def source(stats) do
    stats = Enum.sort(stats, fn(x, y) -> x[:name] <= y[:name] end)
    stats |> transform_cov
  end

  defp generate_report(map) do
    IO.puts "Generating report..."
    View.render([cov: map]) |> write_file
  end

  defp output_dir do
    options = ExCoveralls.Settings.get_coverage_options
    case Dict.fetch(options, "output_dir") do
      {:ok, val} -> val
      _ -> "cover/"
    end
  end

  defp write_file(content) do
    file_path = output_dir
    unless File.exists?(file_path) do
      File.mkdir!(file_path)
    end
    File.write!(Path.expand(@file_name, file_path), content)
  end

  defp transform_cov(stats) do
    files = Enum.map(stats, &populate_file/1)
    {relevant, hits, misses} = Enum.reduce(files, {0,0,0}, &reduce_file_counts/2)
    covered = relevant - misses

    %{coverage: get_coverage(relevant, covered),
      sloc: relevant,
      hits: hits,
      misses: misses,
      files: files}
  end

  defp reduce_file_counts(%{sloc: sloc, hits: hits, misses: misses}, {s,h,m}) do
    {s+sloc, h+hits, m+misses}
  end

  defp populate_file(stat) do
    coverage = stat[:coverage]
    source = map_source(stat[:source], coverage)
    relevant = Enum.count(coverage, fn e -> e != nil end)
    hits = Enum.reduce(coverage, 0, fn e, acc -> (e || 0) + acc end)
    misses = Enum.count(coverage, fn e -> e == 0 end)
    covered = relevant - misses

    %Source{filename: stat[:name],
      coverage: get_coverage(relevant, covered),
      sloc: relevant,
      hits: hits,
      misses: misses,
      source: source}
  end

  defp map_source(source, coverage) do
    source
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.map(&(populate_source(&1,coverage)))
  end

  defp populate_source({line, i}, coverage) do
    %Line{coverage: Enum.at(coverage, i) , source: line}
  end

  defp get_coverage(relevant, covered) do
    value = case relevant do
      0 -> default_coverage_value
      _ -> (covered / relevant) * 100
    end

    if value == trunc(value) do
      trunc(value)
    else
      Float.round(value, 1)
    end
  end

  defp default_coverage_value do
    options = ExCoveralls.Settings.get_coverage_options
    case Dict.fetch(options, "treat_no_relevant_lines_as_covered") do
      {:ok, true} -> 100.0
      _           -> 0.0
    end
  end

end

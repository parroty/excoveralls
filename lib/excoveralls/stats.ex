defmodule ExCoveralls.Stats do
  @moduledoc """
  Calculate coverage stats
  """
  alias ExCoveralls.Cover

  @doc """
  Report the statistical information for he specified module.
  """
  def report(modules) do
    calculate_stats(modules)
      |> generate_coverage
      |> generate_source_info
      |> ExCoveralls.StopWords.filter
  end

  @doc """
  Calculate the statistical information for the specified list of modules.
  It uses :cover.analyse for getting the information.
  """
  def calculate_stats(modules) do
    Enum.reduce(modules, HashDict.new, fn(module, dict) ->
      {:ok, lines} = Cover.analyze(module)
      analyze_lines(lines, dict)
    end)
  end

  defp analyze_lines(lines, module_hash) do
    Enum.reduce(lines, module_hash, fn({{module, line}, count}, module_hash) ->
      add_counts(module_hash, module, line, count)
    end)
  end

  defp add_counts(module_hash, module, line, count) do
    path = Cover.module_path(module)
    count_hash = HashDict.get(module_hash, path, HashDict.new)
    HashDict.put(module_hash, path, HashDict.put(count_hash, line, count))
  end

  @doc """
  Generate coverage, based on the pre-calculated statistic information.
  """
  def generate_coverage(hash) do
    Enum.map(hash.keys, fn(file_path) ->
      total = get_source_line_count(file_path)
      {file_path, do_generate_coverage(HashDict.fetch!(hash, file_path), total, [])}
    end)
  end

  defp do_generate_coverage(_hash, 0, acc),   do: acc
  defp do_generate_coverage(hash, index, acc) do
    count = HashDict.get(hash, index, nil)

    do_generate_coverage(hash, index - 1, [count | acc])
  end

  @doc """
  Generate objects which stores source-file and coverage stats information.
  """
  def generate_source_info(coverage) do
    Enum.map(coverage, fn({file_path, stats}) ->
      [
        name: file_path,
        source: read_source(file_path),
        coverage: stats
      ]
    end)
  end

  @doc """
  Returns total line counts of the specified source file.
  """
  def get_source_line_count(file_path) do
    read_source(file_path) |> count_lines
  end

  defp count_lines(string) do
    1 + Enum.count(to_char_list(string), fn(x) -> x == ?\n end)
  end

  @doc """
  Returns the source file of the specified module.
  """
  def read_module_source(module) do
    Cover.module_path(module) |> read_source
  end

  @doc """
  Wrapper for reading the specified file
  """
  def read_source(file_path) do
    File.read!(file_path) |> trim_empty_prefix_and_suffix
  end

  def trim_empty_prefix_and_suffix(string) do
    string = Regex.replace(%r/\n\z/m, string, "")
    Regex.replace(%r/\A\n/m, string, "")
  end
end
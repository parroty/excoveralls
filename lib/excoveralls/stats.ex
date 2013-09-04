defmodule ExCoveralls.Stats do
  @moduledoc """
  Calculate coverage stats
  """
  alias ExCoveralls.Cover

  def calculate(modules) do
    calculate_stats(modules)
      |> generate_coverage
      |> generate_source_info
  end

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


  def generate_coverage(hash) do
    Enum.map(hash.keys, fn(file_path) ->
      total = get_source_line_count(file_path)
      {file_path, do_generate_coverage(HashDict.fetch!(hash, file_path), total - 1, [])}
    end)
  end

  def do_generate_coverage(_hash, 0, acc),   do: acc
  def do_generate_coverage(hash, index, acc) do
    count = HashDict.get(hash, index, nil)
    do_generate_coverage(hash, index - 1, [count | acc])
  end

  def generate_source_info(coverage) do
    Enum.map(coverage, fn({file_path, stats}) ->
      [
        name: file_path,
        source: read_source(file_path),
        coverage: stats
      ]
    end)
  end

  def get_source_line_count(file_path) do
    read_source(file_path) |> count_lines
  end

  defp count_lines(string) do
    1 + Enum.count(to_char_list(string), fn(x) -> x == ?\n end)
  end

  def read_module_source(module) do
    Cover.module_path(module) |> read_source
  end

  def read_source(file_path) do
    File.read!(file_path)
  end
end
defmodule ExCoveralls.StopWords do
  @moduledoc """
  """

  @stop_word_file __DIR__ <> ".coverallsignore"

  @doc """
  Filters out pre-defined stop words
  """
  def filter(info, words // get_stop_words) do
    Enum.map(info, fn(x) -> do_filter(x, words) end)
  end

  def do_filter([{:name, name}, {:source, source}, {:coverage, coverage}], words) do
    lines = String.split(source, "\n")
    list = Enum.zip(lines, coverage)
                           |> Enum.filter(fn(x) -> has_valid_line?(x, words) end)
                           |> List.unzip
    [source, coverage] = parse_filter_list(list)
    [name: name, source: source, coverage: coverage]
  end

  defp parse_filter_list([]),   do: ["", []]
  defp parse_filter_list([lines, coverage]), do: [Enum.join(lines, "\n"), coverage]

  defp has_valid_line?({line, coverage}, words) do
    find_stop_words(line, words) == false
  end

  defp find_stop_words(line, words) do
    Enum.any?(words, fn(word) -> String.contains?(line, word) end)
  end

  def get_stop_words do
    if File.exists?(@stop_word_file) do
      File.read!(@stop_word_file) |> String.split("\n")
    else
      []
    end
  end
end
defmodule ExCoveralls.StopWords do
  @moduledoc """
  Handles stop words for filtering the coverage results.
  """

  @stop_word_file __DIR__ <> ".coverallsignore"

  @doc """
  Filters out pre-defined stop words
  """
  def filter(info, words // get_stop_words) do
    Enum.map(info, fn(x) -> do_filter(x, words) end)
  end

  defp do_filter([{:name, name}, {:source, source}, {:coverage, coverage}], words) do
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
    Enum.any?(words, fn(word) -> line =~ word end)
  end

  @doc """
  Read stop words from the specified file.
  The words are taken as regular expression.
  """
  def get_stop_words(file // @stop_word_file) do
    if File.exists?(file) do
      File.read!(file)
        |> String.split("\n", trim: true)
        |> Enum.map(&Regex.compile!/1)
    else
      []
    end
  end
end
defmodule ExCoveralls.Settings do
  @moduledoc """
  Handles the configuration setting defined in json file.
  """

  defmodule Files do
    @file_name "coveralls.json"
    def default_file, do: "#{Path.dirname(__ENV__.file)}/../conf/#{@file_name}"
    def custom_file do
      dot_file = Path.expand("~/.excoveralls/coveralls.json")
      if File.exists?(dot_file), do: dot_file, else: "#{System.cwd}/#{@file_name}"
    end
  end

  @doc """
  Get stop words from the json file.
  The words are taken as regular expression.
  """
  def get_stop_words do
    read_config("default_stop_words", []) ++ read_config("custom_stop_words", [])
      |> Enum.map(&Regex.compile!/1)
  end

  @doc """
  Get coverage options from the json file.
  """
  def get_coverage_options do
    read_config("coverage_options", []) |> Enum.into(Map.new)
  end

  @doc """
  Get default coverage value for lines marked as not relevant.
  """
  def default_coverage_value do
    case Map.fetch(get_coverage_options(), "treat_no_relevant_lines_as_covered") do
      {:ok, true} -> 100.0
      _           -> 0.0
    end
  end

  @doc """
  Get terminal output options from the json file.
  """
  def get_terminal_options do
    read_config("terminal_options", []) |> Enum.into(Map.new)
  end

  @doc """
  Get column width to use for the report from the json file
  """
  def get_file_col_width do
    case Map.fetch(get_terminal_options(), "file_column_width") do
      {:ok, val} when is_binary(val) ->
        case Integer.parse(val) do
          :error -> 40
          {int, _} -> int
        end
      {:ok, val} when is_integer(val) -> val
      _ -> 40
    end
  end

  defp read_config_file(file_name) do
    if File.exists?(file_name) do
      case File.read!(file_name) |> JSX.decode do
        {:ok, config} -> Enum.into(config, Map.new)
        _ -> raise "Failed to parse config file as JSON : #{file_name}"
      end
    else
      Map.new
    end
  end

  @doc """
  Get skip files from the json file.
  """
  def get_skip_files do
    read_config("skip_files", [])
    |> Enum.map(&Regex.compile!/1)
  end

  @doc """
  Reads the value for the specified key defined in the json file.
  """
  def read_config(key, default \\ nil) do
    case (read_config_file(Files.custom_file) |> Map.get(key)) do
      nil    -> read_config_file(Files.default_file) |> Map.get(key, default)
      config -> config
    end
  end
end


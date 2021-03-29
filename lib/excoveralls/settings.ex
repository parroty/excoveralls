defmodule ExCoveralls.Settings do
  @moduledoc """
  Handles the configuration setting defined in exs file.
  """

  defmodule Files do
    @filename "coveralls.exs"

    def default_file, do: "#{Path.dirname(__ENV__.file)}/../conf/#{@filename}"
    def custom_file, do: Application.get_env(:excoveralls, :config_file, "#{File.cwd!}/#{@filename}")
    def dot_file, do: Path.expand("~/.excoveralls/#{@filename}")
  end

  @doc """
  Get stop words from the exs file.
  The words are taken as regular expression.
  """
  def get_stop_words do
    read_config(:default_stop_words, []) ++ read_config(:custom_stop_words, [])
      |> Enum.map(&Regex.compile!/1)
  end

  @doc """
  Get coverage options from the exs file.
  """
  def get_coverage_options do
    read_config(:coverage_options, []) |> Enum.into(Map.new)
  end

  @doc """
  Get default coverage value for lines marked as not relevant.
  """
  def default_coverage_value do
    case Map.fetch(get_coverage_options(), :treat_no_relevant_lines_as_covered) do
      {:ok, true} -> 100.0
      _           -> 0.0
    end
  end

  @doc """
  Get terminal output options from the exs file.
  """
  def get_terminal_options do
    read_config(:terminal_options, []) |> Enum.into(Map.new)
  end

  @doc """
  Get column width to use for the report from the exs file
  """
  def get_file_col_width do
    case Map.fetch(get_terminal_options(), :file_column_width) do
      {:ok, val} when is_binary(val) ->
        case Integer.parse(val) do
          :error -> 40
          {int, _} -> int
        end
      {:ok, val} when is_integer(val) -> val
      _ -> 40
    end
  end

  def get_print_files do
    case Map.fetch(get_terminal_options(), :print_files) do
      {:ok, val} when is_boolean(val) -> val
      _ -> true
    end
  end

  @doc """
  Get xml base dir
  """
  def get_xml_base_dir do
    Map.get(get_coverage_options(), :xml_base_dir, "")
  end

  @doc """
  Get skip files from the exs file.
  """
  def get_skip_files do
    read_config(:skip_files, [])
    |> Enum.map(&Regex.compile!/1)
  end

  def get_print_summary do
    read_config(:print_summary, true)
  end

  @doc """
  Reads the value for the specified key defined in the exs file.
  """
  def read_config(key, default \\ nil)

  def read_config(key, default) when is_atom(key) do
    case Map.get(config(), key) do
      nil    -> Map.get(default_config(), key, default)
      config -> config
    end
  end

  def read_config(key, default) do
    key
    |> String.to_atom()
    |> read_config(default)
  end

  def config() do
    dot_file_config = read_config_file(Files.dot_file())
    custom_file_config = read_config_file(Files.custom_file())

    Map.merge(dot_file_config, custom_file_config, fn
      _k, v1, v2 when is_list(v1) and is_list(v2) -> Enum.uniq(v1 ++ v2)
      _k, v1, v2 -> Map.merge(v1, v2)
    end)
  end

  def default_config(), do: read_config_file(Files.default_file())

  defp read_config_file(file_name) do
    if File.exists?(file_name) do
      {map, _} = Code.eval_file(file_name)
      map
    else
      Map.new
    end
  end
end

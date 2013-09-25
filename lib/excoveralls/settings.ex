defmodule ExCoveralls.Settings do
  @moduledoc """
  Handles the configuration setting defined in json file.
  """

  defmodule Files do
    @file_name "coveralls.json"
    def default_file, do: "#{Path.dirname(__FILE__)}/../conf/#{@file_name}"
    def custom_file,  do: "#{System.cwd}/#{@file_name}"
  end

  @doc """
  Get stop words from the json file.
  The words are taken as regular expression.
  """
  def get_stop_words do
    read_config("default_stop_words", []) ++ read_config("custom_stop_words", [])
      |> Enum.map(&Regex.compile!/1)
  end

  defp read_config_file(file_name) do
    if File.exists?(file_name) do
      case File.read!(file_name) |> JSEX.decode do
        {:ok, config} -> HashDict.new(config)
        _ -> raise "Failed to parse config file as JSON : #{file_name}"
      end
    else
      HashDict.new
    end
  end

  @doc """
  Reads the value for the specified key defined in the json file.
  """
  def read_config(key, default // nil) do
    case (read_config_file(Files.custom_file) |> HashDict.get(key)) do
      nil    -> read_config_file(Files.default_file) |> HashDict.get(key, default)
      config -> config
    end
  end
end
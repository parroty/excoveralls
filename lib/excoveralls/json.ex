defmodule ExCoveralls.Json do
  @moduledoc """
  Generate JSON output for results.
  """
  alias ExCoveralls.Stats

  @file_name "excoveralls.json"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    generate_json(stats, Enum.into(options, %{})) |> write_file(options)

    ExCoveralls.Local.print_summary(stats)
  end

  def generate_json(stats, _options) do
    Jason.encode!(%{
      source_files: Stats.serialize(stats)
    })
  end

  defp output_dir(output_dir) do
    cond do
      output_dir ->
        output_dir
      true ->
        options = ExCoveralls.Settings.get_coverage_options
        case Map.fetch(options, "output_dir") do
          {:ok, val} -> val
          _ -> "cover/"
        end
    end
  end

  defp output_name(name) do
    if name do
      "#{name}.json"
    else
      @file_name
    end
  end

  defp write_file(content, options) do
    output_dir = options[:output_dir]
    name = output_name(options[:export])

    file_path = output_dir(output_dir)
    unless File.exists?(file_path) do
      File.mkdir_p!(file_path)
    end
    File.write!(Path.expand(name, file_path), content)
  end

end

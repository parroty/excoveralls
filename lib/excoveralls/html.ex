defmodule ExCoveralls.Html do
  @moduledoc """
  Generate HTML report of result.
  """

  alias ExCoveralls.Html.View
  alias ExCoveralls.Stats

  @file_name "excoveralls.html"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    ExCoveralls.Local.print_summary(stats)

    Stats.source(stats, options[:filter]) |> generate_report()

    Stats.ensure_minimum_coverage(stats)
  end

  defp generate_report(map) do
    IO.puts "Generating report..."
    View.render([cov: map]) |> write_file
  end

  defp output_dir do
    options = ExCoveralls.Settings.get_coverage_options()
    case Map.fetch(options, "output_dir") do
      {:ok, val} -> val
      _ -> "cover/"
    end
  end

  defp write_file(content) do
    file_path = output_dir()
    unless File.exists?(file_path) do
      File.mkdir!(file_path)
    end
    File.write!(Path.expand(@file_name, file_path), content)
  end

end

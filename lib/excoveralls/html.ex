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

    Stats.source(stats, options[:filter]) |> generate_report(options[:output_dir])
  end

  defp generate_report(map, output_dir) do
    IO.puts("Generating report...")

    filter_full_covered =
      Map.get(ExCoveralls.Settings.get_coverage_options(), "html_filter_full_covered", false)

    View.render(cov: map, filter_full_covered: filter_full_covered) |> write_file(output_dir)
  end

  defp output_dir(output_dir) do
    cond do
      output_dir ->
        output_dir
      true ->
        options = ExCoveralls.Settings.get_coverage_options()
        case Map.fetch(options, "output_dir") do
          {:ok, val} -> val
          _ -> "cover/"
        end
    end
  end

  defp write_file(content, output_dir) do
    file_path = output_dir(output_dir)
    unless File.exists?(file_path) do
      File.mkdir_p!(file_path)
    end

    File.write!(Path.expand(@file_name, file_path), content)
    IO.puts "Saved to: #{file_path}"
  end
end

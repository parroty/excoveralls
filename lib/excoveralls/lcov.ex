defmodule ExCoveralls.Lcov do
  @moduledoc """
  Generate lcov output for results.
  """

  @file_name "lcov.info"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    generate_lcov(stats, Enum.into(options, %{})) |> write_file(options[:output_dir])

    ExCoveralls.Local.print_summary(stats)
  end

  def generate_lcov(stats, _options) do
    lcov = Enum.map(stats, fn stat -> generate_lcov_file(stat) end) |> Enum.join("\n")
    lcov <> "\n"
  end

  def generate_lcov_file(stat) do
    da =
      stat.coverage
      |> Enum.with_index(1)
      |> Enum.filter(fn {k, _v} -> k != nil end)
      |> Enum.map(fn {k, v} -> {Integer.to_string(v), Integer.to_string(k)} end)
      |> Enum.map(fn {line, count} -> "DA:" <> line <> "," <> count end)

    foundlines =
      stat.coverage
      |> Enum.filter(fn v -> v != nil end)

    lf = foundlines |> Enum.count()
    lh = foundlines |> Enum.filter(fn v -> v > 0 end) |> Enum.count()

    lines =
      ["TN:", "SF:" <> stat.name] ++
        da ++
        [
          "LF:" <> Integer.to_string(lf),
          "LH:" <> Integer.to_string(lh),
          "end_of_record"
        ]

    Enum.join(lines, "\n")
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
  end
end

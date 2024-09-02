defmodule ExCoveralls.Cobertura do
  @moduledoc """
  Generate XML Cobertura output for results.
  """

  alias ExCoveralls.Settings
  alias ExCoveralls.Stats

  @file_name "cobertura.xml"

  @doc """
  Provides an entry point for the module.
  """
  def execute(stats, options \\ []) do
    stats
    |> generate_xml(Enum.into(options, %{}))
    |> write_file(options[:output_dir])

    ExCoveralls.Local.print_summary(stats)

    Stats.ensure_minimum_coverage(stats)
  end

  defp generate_xml(stats, _options) do
    prolog = [
      "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n",
      "<!DOCTYPE coverage SYSTEM \"http://cobertura.sourceforge.net/xml/coverage-04.dtd\">\n"
    ]

    timestamp = DateTime.utc_now() |> DateTime.to_unix(:millisecond)

    # This is the version of the cobertura tool used to generate the XML
    # We are not using the tool here but the version is mandatory in the DTD schema
    # so we put the last released version (dated 2015)
    # It is only a "placeholder" to make DTD happy
    version = "2.1.1"

    complexity = "0"
    branch_rate = "0.0"
    branches_covered = "0"
    branches_valid = "0"

    {valid, covered} =
      Enum.reduce(stats, {0, 0}, fn %{coverage: lines}, {valid, covered} ->
        valid_lines = Enum.reject(lines, &is_nil/1)
        {valid + length(valid_lines), covered + Enum.count(valid_lines, &(&1 > 0))}
      end)

    line_rate = to_string(Float.floor(covered / valid, 3))
    lines_covered = to_string(covered)
    lines_valid = to_string(valid)

    mix_project_config = Mix.Project.config()

    c_paths =
      Keyword.get(mix_project_config, :erlc_paths, []) ++
        Keyword.get(mix_project_config, :elixirc_paths, [])

    c_paths =
      c_paths
      |> Enum.filter(&File.exists?/1)
      |> Enum.map(fn c_path ->
        c_path = Path.absname(c_path)

        if File.dir?(c_path) do
          c_path
        else
          Path.dirname(c_path)
        end
      end)

    sources = Enum.map(c_paths, &{:source, [to_charlist(&1)]})

    packages = generate_packages(stats, c_paths)

    root = {
      :coverage,
      [
        timestamp: timestamp,
        "line-rate": line_rate,
        "lines-covered": lines_covered,
        "lines-valid": lines_valid,
        "branch-rate": branch_rate,
        "branches-covered": branches_covered,
        "branches-valid": branches_valid,
        complexity: complexity,
        version: version
      ],
      [sources: sources, packages: packages]
    }

    :xmerl.export_simple([root], :xmerl_xml, [{:prolog, prolog}])
  end

  defp generate_packages(stats, c_paths) do
    stats
    |> Enum.reduce(%{}, fn %{name: path, source: source, coverage: lines}, acc ->
      package_name = package_name(path, c_paths)
      module = module_name(source)
      x = %{module: module, path: path, lines: lines}
      Map.update(acc, package_name, [x], &[x | &1])
    end)
    |> Enum.map(&generate_package(&1, c_paths))
  end

  defp generate_package({package_name, modules}, c_paths) do
    classes = generate_classes(modules, c_paths)

    line_rate =
      modules |> Enum.flat_map(fn %{lines: lines} -> Enum.reject(lines, &is_nil/1) end) |> rate()

    {
      :package,
      [
        name: package_name,
        "line-rate": to_string(line_rate),
        "branch-rate": "0.0",
        complexity: "0"
      ],
      [classes: classes]
    }
  end

  defp generate_classes(modules, c_paths) do
    Enum.map(modules, fn %{module: module, path: path, lines: lines} ->
      line_rate = lines |> Enum.reject(&is_nil/1) |> rate()

      lines =
        lines
        |> Enum.with_index(1)
        |> Enum.reject(fn {hits, _} -> is_nil(hits) end)
        |> Enum.map(fn {hits, line} ->
          {:line, [number: to_string(line), hits: to_string(hits), branch: "False"], []}
        end)

      {
        :class,
        [
          name: module,
          filename: relative_to(path, c_paths),
          "line-rate": to_string(line_rate),
          "branch-rate": "0.0",
          complexity: "0"
        ],
        [methods: [], lines: lines]
      }
    end)
  end

  defp relative_to(path, c_paths) do
    abspath = Path.absname(path)

    Enum.reduce_while(c_paths, path, fn c_path, path ->
      case Path.relative_to(abspath, c_path) do
        ^abspath -> {:cont, path}
        relative -> {:halt, relative}
      end
    end)
  end

  defp module_name(source) do
    with nil <- Regex.run(~r/^def(?:module|protocol|impl)\s+(.*)\s+do$/m, source, capture: :all_but_first),
         nil <- Regex.run(~r/^-module\((.*)\)\.$/m, source, capture: :all_but_first) do
     "UNKNOWN_MODULE"
    else
     [module] -> module
    end  
  end

  defp package_name(path, c_paths) do
    package_name = path |> Path.absname() |> Path.dirname()

    c_paths
    |> Enum.find_value(package_name, fn c_path ->
      if String.starts_with?(package_name, c_path) do
        String.slice(package_name, get_slice_range_for_package_name(c_path))
      else
        false
      end
    end)
    |> Path.split()
    |> Enum.join(".")
    |> to_charlist()
  end

  # TODO: Remove when we require Elixir 1.12 as minimum and inline it with range syntax
  if Version.match?(System.version(), ">= 1.12.0") do
    # We use Range.new/3 because using x..y//step would give a syntax error on Elixir < 1.12
    defp get_slice_range_for_package_name(c_path), do: Range.new(String.length(c_path) + 1, -1, 1)
  else
    defp get_slice_range_for_package_name(c_path), do: Range.new(String.length(c_path) + 1, -1)
  end

  defp rate(valid_lines) when length(valid_lines) == 0, do: 0.0

  defp rate(valid_lines) do
    Float.floor(Enum.count(valid_lines, &(&1 > 0)) / length(valid_lines), 3)
  end

  defp output_dir(output_dir) do
    cond do
      output_dir ->
        output_dir

      true ->
        options = Settings.get_coverage_options()

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

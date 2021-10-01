defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"
  @preferred_cli_env :test

  defmodule Runner do
    def run(task, args) do
      Mix.Task.run(task, args)
    end
  end

  def run(args) do
    {options, _, _} =
      OptionParser.parse(args, switches: [help: :boolean], aliases: [h: :help])

    if options[:help] do
      Chaps.Task.Util.print_help_message()
    else
      do_run(args, type: "local")
    end
  end

  @doc """
  Provides the logic to switch the parameters for Chaps.run/3.
  """
  def do_run(args, options) do
    if Mix.Project.config()[:test_coverage][:tool] != Chaps do
      raise Chaps.InvalidConfigError,
        message:
          "Please specify 'test_coverage: [tool: Chaps]' in the 'project' section of mix.exs"
    end

    switches = [
      filter: :string,
      umbrella: :boolean,
      verbose: :boolean,
      pro: :boolean,
      parallel: :boolean,
      sort: :string,
      output_dir: :string
    ]

    aliases = [f: :filter, u: :umbrella, v: :verbose, o: :output_dir]

    {args, common_options} =
      parse_common_options(args, switches: switches, aliases: aliases)

    all_options = options ++ common_options
    test_task = Mix.Project.config()[:test_coverage][:test_task] || "test"

    all_options =
      if all_options[:umbrella] do
        sub_apps = Chaps.SubApps.parse(Mix.Dep.Umbrella.loaded())

        all_options ++
          [sub_apps: sub_apps, apps_path: Mix.Project.config()[:apps_path]]
      else
        all_options
      end

    Chaps.ConfServer.start()
    Chaps.ConfServer.set(all_options ++ [args: args])
    Chaps.StatServer.start()

    Runner.run(test_task, ["--cover"] ++ args)

    if all_options[:umbrella] do
      type = options[:type] || "local"

      Chaps.StatServer.get()
      |> MapSet.to_list()
      |> get_stats(all_options)
      |> Chaps.analyze(type, options)
    end
  end

  def parse_common_options(args, common_options) do
    common_switches = Keyword.get(common_options, :switches, [])
    common_aliases = Keyword.get(common_options, :aliases, [])

    {common_options, _remaining, _invalid} =
      OptionParser.parse(args, common_options)

    # the switches that chaps supports
    supported_switches =
      Enum.map(Keyword.keys(common_switches), fn s ->
        String.replace("--#{s}", "_", "-")
      end) ++
        Enum.map(Keyword.keys(common_aliases), fn s -> "-#{s}" end)

    # Get the remaining args to pass onto cover, excluding Chaps-specific args.
    # Not using OptionParser for this because it splits things up in unfortunate ways.
    {remaining, _} =
      List.foldl(args, {[], nil}, fn arg, {acc, last} ->
        cond do
          # don't include switches for Chaps
          Enum.member?(supported_switches, arg) ->
            {acc, arg}

          # also drop any values that follow Chaps switches
          !String.starts_with?(arg, "-") &&
              Enum.member?(supported_switches, last) ->
            {acc, nil}

          # leaving just the switches and values intended for cover
          true ->
            {acc ++ [arg], nil}
        end
      end)

    sub_dir_set? = common_options[:subdir] not in [nil, ""]
    root_dir_set? = common_options[:rootdir] not in [nil, ""]

    if sub_dir_set? and root_dir_set? do
      raise Chaps.InvalidOptionError,
        message:
          "subdir and rootdir options are exclusive. please specify only one of them."
    end

    {remaining, common_options}
  end

  def get_stats(stats, options) do
    sub_dir_set? = options[:subdir] not in [nil, ""]
    root_dir_set? = options[:rootdir] not in [nil, ""]

    cond do
      sub_dir_set? ->
        stats
        |> Enum.map(fn m ->
          %{m | name: options[:subdir] <> Map.get(m, :name)}
        end)

      root_dir_set? ->
        stats
        |> Enum.map(fn m ->
          %{m | name: String.trim_leading(Map.get(m, :name), options[:rootdir])}
        end)

      true ->
        stats
    end
  end

  defmodule Detail do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details.
    """
    use Mix.Task

    @shortdoc "Display the test coverage with source detail"
    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "local", detail: true)
    end
  end

  defmodule Html do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details as an HTML report.
    """
    use Mix.Task

    @shortdoc "Display the test coverage with source detail as an HTML report"
    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "html")
    end
  end

  defmodule Xml do
    @moduledoc """
    Provides an entry point for outputting coveralls information
    as a XML file.
    """
    use Mix.Task

    @shortdoc "Output the test coverage as a XML file"
    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "xml")
    end
  end

  defmodule Json do
    @moduledoc """
    Provides an entry point for outputting coveralls information
    as a JSON file.
    """
    use Mix.Task

    @shortdoc "Output the test coverage as a JSON file"
    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "json")
    end
  end

  defmodule Lcov do
    @moduledoc """
    Provides an entry point for outputting coveralls information
    as a Lcov file.
    """
    use Mix.Task

    @shortdoc "Output the test coverage as a Lcov file"
    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "lcov")
    end
  end
end

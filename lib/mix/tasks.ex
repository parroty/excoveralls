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
    {options, _, _} = OptionParser.parse(args, switches: [help: :boolean], aliases: [h: :help])

    if options[:help] do
      ExCoveralls.Task.Util.print_help_message
    else
      do_run(args, [type: "local"])
    end
  end

  @doc """
  Provides the logic to switch the parameters for ExCoveralls.run/3.
  """
  def do_run(args, options) do
    if Mix.Project.config[:test_coverage][:tool] != ExCoveralls do
      raise ExCoveralls.InvalidConfigError,
        message: "Please specify 'test_coverage: [tool: ExCoveralls]' in the 'project' section of mix.exs"
    end

    switches = [filter: :string, umbrella: :boolean, verbose: :boolean, pro: :boolean, parallel: :boolean, sort: :string, output_dir: :string]
    aliases = [f: :filter, u: :umbrella, v: :verbose, o: :output_dir]
    {args, common_options} = parse_common_options(args, switches: switches, aliases: aliases)
    all_options = options ++ common_options
    test_task = Mix.Project.config[:test_coverage][:test_task] || "test"

    all_options =
      if all_options[:umbrella] do
        sub_apps = ExCoveralls.SubApps.parse(Mix.Dep.Umbrella.loaded)
        all_options ++ [sub_apps: sub_apps, apps_path: Mix.Project.config[:apps_path]]
      else
        all_options
      end

    ExCoveralls.ConfServer.start
    ExCoveralls.ConfServer.set(all_options ++ [args: args])
    ExCoveralls.StatServer.start

    Runner.run(test_task, ["--cover"] ++ args)

    if all_options[:umbrella] do
      type = options[:type] || "local"

      ExCoveralls.StatServer.get
      |> MapSet.to_list
      |> get_stats(all_options)
      |> ExCoveralls.analyze(type, options)
    end
  end

  def parse_common_options(args, common_options) do
    common_switches = Keyword.get(common_options, :switches, [])
    common_aliases = Keyword.get(common_options, :aliases, [])
    {common_options, _remaining, _invalid} = OptionParser.parse(args, common_options)

    # the switches that excoveralls supports
    supported_switches = Enum.map(Keyword.keys(common_switches), fn(s) -> String.replace("--#{s}", "_", "-") end)
      ++ Enum.map(Keyword.keys(common_aliases), fn(s) -> "-#{s}" end)

    # Get the remaining args to pass onto cover, excluding ExCoveralls-specific args.
    # Not using OptionParser for this because it splits things up in unfortunate ways.
    {remaining, _} = List.foldl(args, {[], nil}, fn(arg, {acc, last}) ->
      cond do
      # don't include switches for ExCoveralls
      Enum.member?(supported_switches, arg) -> {acc, arg}
      # also drop any values that follow ExCoveralls switches
      !String.starts_with?(arg, "-") && Enum.member?(supported_switches, last) -> {acc, nil}
      # leaving just the switches and values intended for cover
      true -> {acc ++ [arg], nil}
      end
    end)

    sub_dir_set? = not (common_options[:subdir] in [nil, ""])
    root_dir_set? = not (common_options[:rootdir] in [nil, ""])
    if sub_dir_set? and root_dir_set? do
      raise ExCoveralls.InvalidOptionError,
                message: "subdir and rootdir options are exclusive. please specify only one of them."
    end
    {remaining, common_options}
  end

  def get_stats(stats, options) do
    sub_dir_set? = not (options[:subdir] in [nil, ""])
    root_dir_set? = not (options[:rootdir] in [nil, ""])

    cond do
      sub_dir_set? ->
        stats
        |> Enum.map(fn m -> %{m | name: options[:subdir] <> Map.get(m, :name)} end)

      root_dir_set? ->
        stats
        |> Enum.map(fn m -> %{m | name: String.trim_leading(Map.get(m, :name), options[:rootdir])} end)
      true -> stats
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
      Mix.Tasks.Coveralls.do_run(args, [ type: "local", detail: true ])
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
      Mix.Tasks.Coveralls.do_run(args, [ type: "html" ])
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
      Mix.Tasks.Coveralls.do_run(args, [ type: "xml" ])
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
      Mix.Tasks.Coveralls.do_run(args, [ type: "json" ])
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
      Mix.Tasks.Coveralls.do_run(args, [ type: "lcov" ])
    end
  end

  defmodule Travis do
    @moduledoc """
    Provides an entry point for travis's script.
    """
    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "travis"])
    end
  end

  defmodule Github do
    @moduledoc """
    Provides an entry point for github's script.
    """
    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "github"])
    end
  end

  defmodule Gitlab do
    @moduledoc """
    Provides an entry point for gitlab's script.
    """
    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, type: "gitlab")
    end
  end

  defmodule Circle do
    @moduledoc """
    Provides an entry point for CircleCI's script.
    """
    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "circle"])
    end
  end

  defmodule Semaphore do
    @moduledoc """
    Provides an entry point for SemaphoreCI's script.
    """
    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "semaphore"])
    end
  end

  defmodule Drone do
    @moduledoc """
    Provides an entry point for DroneCI's script.
    """

    use Mix.Task

    @preferred_cli_env :test

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "drone"])
    end
  end

  defmodule Post do
    @moduledoc """
    Provides an entry point for posting test coverage to
    coveralls.io from the local server.
    """
    use Mix.Task

    @shortdoc "Post the test coverage to coveralls"
    @default_service_name "excoveralls"
    @preferred_cli_env :test

    def run(args) do
      switches = [
        filter: :string,
        umbrella: :boolean,
        verbose: :boolean,
        pro: :boolean,
        parallel: :boolean,
        rootdir: :string,
        subdir: :string,
        build: :string,
      ]
      aliases = [f: :filter, u: :umbrella, v: :verbose]
      {remaining, options} = Mix.Tasks.Coveralls.parse_common_options(
        args,
        switches: switches ++ [sha: :string, token: :string, committer: :string, branch: :string, message: :string, name: :string],
        aliases: aliases ++ [n: :name, b: :branch, c: :committer, m: :message, s: :sha, t: :token]
      )

      Mix.Tasks.Coveralls.do_run(remaining,
        [ type:         "post",
          endpoint:     Application.get_env(:excoveralls, :endpoint),
          token:        extract_token(options),
          service_name: extract_service_name(options),
          service_number: options[:build] || "",
          branch:       options[:branch] || "",
          committer:    options[:committer] || "",
          sha:          options[:sha] || "",
          message:      options[:message] || "[no commit message]",
          umbrella:     options[:umbrella],
          verbose:      options[:verbose],
          parallel:     options[:parallel],
          rootdir:      options[:rootdir] || "",
          subdir:       options[:subdir] || ""
        ])
    end

    def extract_service_name(options) do
      options[:name] || System.get_env("COVERALLS_SERVICE_NAME") || @default_service_name
    end

    def extract_token(options) do
      case options[:token] || System.get_env("COVERALLS_REPO_TOKEN") || "" do
        "" -> raise ExCoveralls.InvalidOptionError,
                      message: "Token is NOT specified in the argument nor environment variable."
        token -> token
      end
    end
  end

  defmodule Diff do
    @moduledoc """
    Provides an entry point for coverage analysis of new code
    """
    use Mix.Task

    @preferred_cli_env :test

    @impl Mix.Task
    def run(args) do
      # Use '--' to separate revisions from paths
      {cover_args, paths} = Enum.split_while(args, & &1 != "--")

      {remaining, options} = Mix.Tasks.Coveralls.parse_common_options(
        cover_args,
        switches: [from_git_rev: :string, threshold: :float]
      )

      opts = ExCoveralls.Diff.diff_file_names([
        type: "diff",
        from_git_rev: options[:from_git_rev] || "master",
        paths: List.delete(paths, "--"),
        threshold: options[:threshold] || 0.0
      ])

      Mix.Tasks.Coveralls.do_run(remaining, opts)
    end
  end
end

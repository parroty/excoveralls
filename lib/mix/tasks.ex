defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"

  defmodule Runner do
    def run(task, args) do
      Mix.Task.run(task, args)
    end
  end

  def run(args) do
    {options, _, _} = OptionParser.parse(args, aliases: [h: :help])

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

    {args, options} = parse_common_options(args, options)
    test_task = Mix.Project.config[:test_coverage][:test_task] || "test"

    Mix.env(:test)


    options =
      if options[:umbrella] do
        sub_apps = ExCoveralls.SubApps.parse(Mix.Dep.Umbrella.loaded)
        options ++ [sub_apps: sub_apps, apps_path: Mix.Project.config[:apps_path]]
      else
        options
      end

    ExCoveralls.ConfServer.start
    ExCoveralls.ConfServer.set(options ++ [args: args])
    ExCoveralls.StatServer.start

    Runner.run(test_task, ["--cover"] ++ args)

    if options[:umbrella] do
      analyze_sub_apps(options)
    end
  end

  defp parse_common_options(args, options) do
    {common_options, _remaining, unknown_args} = OptionParser.parse(args,
      strict: [umbrella: :boolean, verbose: :boolean, pro: :boolean, parallel: :boolean],
      aliases: [u: :umbrella, v: :verbose])
    {unknown_args |> Enum.map(fn({k, _}) -> k end), options ++ common_options}
  end

  defp analyze_sub_apps(options) do
    type = options[:type] || "local"
    stats = ExCoveralls.StatServer.get |> Set.to_list
    ExCoveralls.analyze(stats, type, options)
  end

  defmodule Detail do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details.
    """
    use Mix.Task

    @shortdoc "Display the test coverage with source detail"

    def run(args) do
      {parsed, _, _} = OptionParser.parse(args, aliases: [f: :filter])

      Mix.Tasks.Coveralls.do_run(args,
        [ type: "local",
          detail: true,
          filter: parsed[:filter] || [] ])
    end
  end

  defmodule Html do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details as an HTML report.
    """
    use Mix.Task

    @shortdoc "Display the test coverage with source detail as an HTML report"

    def run(args) do
      {parsed, _, _} = OptionParser.parse(args, aliases: [f: :filter])

      Mix.Tasks.Coveralls.do_run(args,
        [ type: "html",
          filter: parsed[:filter] || [] ])
    end
  end

  defmodule Json do
    @moduledoc """
    Provides an entry point for outputting coveralls information
    as a JSON file.
    """
    use Mix.Task

    @shortdoc "Output the test coverage as a JSON file"

    def run(args) do
      {parsed, _, _} = OptionParser.parse(args, aliases: [f: :filter])

      Mix.Tasks.Coveralls.do_run(args,
        [ type: "json",
          filter: parsed[:filter] || [] ])
    end
  end

  defmodule Travis do
    @moduledoc """
    Provides an entry point for travis's script.
    """
    use Mix.Task

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "travis"])
    end
  end

  defmodule Circle do
    @moduledoc """
    Provides an entry point for CircleCI's script.
    """
    use Mix.Task

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "circle"])
    end
  end

  defmodule Semaphore do
    @moduledoc """
    Provides an entry point for SemaphoreCI's script.
    """
    use Mix.Task

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "semaphore"])
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

    def run(args) do
      {options, params, _} =
        OptionParser.parse(args,
          aliases: [n: :name, b: :branch, c: :committer, m: :message, s: :sha, t: :token])

      Mix.Tasks.Coveralls.do_run(params,
        [ type:         "post",
          endpoint:     Application.get_env(:excoveralls, :endpoint),
          token:        extract_token(options),
          service_name: extract_service_name(options),
          branch:       options[:branch] || "",
          committer:    options[:committer] || "",
          sha:          options[:sha] || "",
          message:      options[:message] || "[no commit message]" ])
    end

    def extract_service_name(options) do
      options[:name] || System.get_env("COVERALLS_SERVICE_NAME") || @default_service_name
    end

    def extract_token(options) do
      case options[:token] || System.get_env("COVERALLS_REPO_TOKEN") || "" do
        "" -> raise %ExCoveralls.InvalidOptionError{
                      message: "Token is NOT specified in the argument nor environment variable."}
        token -> token
      end
    end
  end
end

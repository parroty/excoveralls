defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"

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
      raise ExCoveralls.InvalidConfigError.new(
        message: "Please specify 'test_coverage: [tool: ExCoveralls]' in the 'project' section of mix.exs")
    end

    Mix.env(:test)
    ExCoveralls.ConfServer.start
    ExCoveralls.ConfServer.set(options ++ [args: args])
    Mix.Task.run("test", ["--cover"])
  end

  defmodule Detail do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details.
    """
    use Mix.Task

    @shortdoc "Display the test coverage with source detail"

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "local", detail: true])
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

  defmodule Post do
    @moduledoc """
    Provides an entry point for posting test coverage to
    coveralls.io from the local server.
    """
    use Mix.Task

    @shortdoc "Post the test coverage to coveralls"
    @default_service_name "excoveralls"

    def run(args) do
      {options, params, _} = OptionParser.parse(args, aliases: [n: :name, b: :branch, c: :committer, m: :message])

      if Enum.count(params) <= 1 do
        Mix.Tasks.Coveralls.do_run(args,
          [ type:         "post",
            token:        extract_token(params),
            service_name: extract_service_name(options),
            branch:       options[:branch] || "",
            committer:    options[:committer] || "",
            message:      options[:message] || "[no commit message]" ])
      else
        raise ExCoveralls.InvalidOptionError.new(message: "Parameter format is invalid")
      end
    end

    def extract_service_name(options) do
      options[:name] || System.get_env("COVERALLS_SERVICE_NAME") || @default_service_name
    end

    def extract_token(params) do
      case Enum.at(params, 0) || System.get_env("COVERALLS_REPO_TOKEN") || "" do
        "" -> raise ExCoveralls.InvalidOptionError.new(message: "Token is NOT specified in the parameter or environment variable")
        token -> token
      end
    end
  end
end


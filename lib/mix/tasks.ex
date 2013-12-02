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

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, [type: "post"])
    end
  end

end


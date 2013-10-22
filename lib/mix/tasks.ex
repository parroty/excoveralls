defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"

  def run(args) do
    do_run(args, [type: "local"])
  end

  @doc """
  Provides the logic to switch the parameters for ExCoveralls.run/3.
  """
  def do_run(args, options) do
    Mix.env(:test)
    ExCoveralls.ConfServer.start
    ExCoveralls.ConfServer.set(options)
    Mix.Task.run("test", args ++ ["--cover"])
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


defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"

  def run(args) do
    do_run(args, "/../../projects/mix.local.exs")
  end

  def do_run(args, mix_file_path) do
    Mix.env(:test)
    Code.load_file(Path.dirname(__FILE__) <> mix_file_path)
    Mix.Task.run("test", args ++ ["--cover"])
    Mix.Project.pop
  end

  defmodule Detail do
    @moduledoc """
    Provides an entry point for displaying coveralls information
    with source code details.
    """
    use Mix.Task

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, "/../../projects/mix.detail.exs")
    end
  end

  defmodule Travis do
    @moduledoc """
    Provides an entry point for travis's script.
    """
    use Mix.Task

    def run(args) do
      Mix.Tasks.Coveralls.do_run(args, "/../../projects/mix.travis.exs")
    end
  end
end

# defmodule Mix.Tasks.Coveralls.Post do
#   @moduledoc """
#   Provides an entry point for posting test coverage to
#   coveralls.io from local server.
#   """
#   use Mix.Task

#   @shortdoc "Post the test coverage to coveralls"

#   def run(_) do
#     IO.puts "ExCoveralls - Post"
#   end
# end

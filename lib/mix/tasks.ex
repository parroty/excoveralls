defmodule Mix.Tasks.Coveralls do
  @moduledoc """
  Provides an entry point for displaying co
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Display the test coverage"

  def run(args) do
    Mix.env(:test)
    Code.load_file("projects/mix.local.exs")
    Mix.Task.run("test", args ++ ["--cover"])
    Mix.Project.pop
  end
end

defmodule Mix.Tasks.Coveralls.Travis do
  @moduledoc """
  Provides an entry point for travis's script.
  """
  use Mix.Task

  def run(args) do
    Mix.env(:test)
    Code.load_file("projects/mix.travis.exs")
    Mix.Task.run("test", args ++ ["--cover"])
    Mix.Project.pop
  end
end

defmodule Mix.Tasks.Coveralls.Post do
  @moduledoc """
  Provides an entry point for posting test coverage to
  coveralls.io from local server.
  """
  use Mix.Task

  @shortdoc "Post the test coverage to coveralls"

  def run(_) do
    IO.puts "ExCoveralls - Post"
  end
end

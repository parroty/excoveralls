defmodule ExCoveralls.PathReader do
  @moduledoc """
  Provide methods for base path for displaying File paths of the modules.
  It uses Mix.project path as base folder.
  """

  @doc """
  Returns the Mix.Project base path.
  """
  def base_path do
    if Version.compare("1.13.0", System.version()) == :lt do
      Enum.find(Mix.Project.config_files(), &(&1 =~ ~r/mix.exs/)) |> Path.dirname()
    else
      Path.dirname(Mix.Project.project_file())
    end
  end

  @doc """
  Expand path relative to the Mix.Project base path.
  """
  def expand_path(path) do
    Path.expand(path, base_path())
  end
end

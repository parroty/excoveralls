defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover
  alias ExCoveralls.Generator
  alias ExCoveralls.Poster

  def start(compile_path, option) do
    compile(compile_path)

    System.at_exit fn(_) ->
      File.mkdir_p!(option[:output])
      calculate(option)
    end
  end

  def compile(compile_path) do
    Cover.compile(compile_path)
  end

  def calculate(option) do
    Stats.calculate(Cover.modules)
      |> Generator.execute(option[:type])
      |> Poster.execute
  end
end

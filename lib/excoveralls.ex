defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """
  def start(compile_path, option) do
    compile(compile_path)

    System.at_exit fn(_) ->
      File.mkdir_p!(option[:output])
      calculate(option)
    end
  end

  def compile(compile_path) do
    ExCoveralls.Cover.compile(compile_path)
  end

  def calculate(option) do
    Stats.calculate(Cover.modules)
      |> ExCoveralls.Generator.execute(option[:type])
      |> ExCoveralls.Poster.execute
  end
end

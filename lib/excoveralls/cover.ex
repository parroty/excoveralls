defmodule ExCoveralls.Cover do
  @moduledoc """
  Wrapper class for Erlang's cover tool
  """

  def compile(compile_path) do
    :cover.start
    :cover.compile_beam_directory(compile_path |> to_char_list)
  end

  def modules do
    :cover.modules
  end

  @doc """
  Returns the relative file path of the specified module.
  """
  def module_path(module) do
    module.__info__(:compile)[:source]
      |> String.from_char_list!
      |> Path.relative_to(File.cwd!)
  end

  def analyze(module) do
    :cover.analyse(module, :calls, :line)
  end
end

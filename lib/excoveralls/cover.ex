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

  def module_path(module) do
    String.from_char_list!(module.__info__(:compile)[:source])
  end

  def analyze(module) do
    :cover.analyse(module, :calls, :line)
  end
end

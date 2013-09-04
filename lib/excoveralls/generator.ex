defmodule ExCoveralls.Generator do
  @moduledoc """
  Handles JSON generation which contains source coverage information.
  """
  @file_path "tmp"
  @file_name "post.json"

  def execute(coverage, type), do: do_execute(coverage, type)

  def do_execute(coverage, type) when type == "travis" do
    ExCoveralls.Travis.generate_json(coverage)
  end

  def do_execute(coverage, type) when type == "general" do
    ExCoveralls.General.generate_json(coverage)
  end
end

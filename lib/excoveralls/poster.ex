defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server
  """
  def execute(json) do
    File.mkdir_p!(@file_path)
    File.write!(Path.join([@file_path, @file_name]), json)
    System.cmd(Path.join([System.cwd, @post_cmd]))
  end
end
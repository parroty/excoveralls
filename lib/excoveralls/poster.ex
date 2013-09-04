defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server
  """
  @file_path "tmp"
  @file_name "post.json"
  @post_cmd  "post.sh"

  def execute(json) do
    File.mkdir_p!(@file_path)
    File.write!(Path.join([@file_path, @file_name]), json)
    IO.inspect System.cmd(Path.join([System.cwd, @post_cmd]))
  end
end
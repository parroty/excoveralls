defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server
  """
  @file_path "."
  @file_name "excoveralls.post.json"
  @post_cmd  "curl \"https://coveralls.io/api/v1/jobs\" -F json_file=excoveralls.post.json"

  @doc """
  Create a temporarily json file and post it to server using curl command.
  Then, remove the file after it's completed.
  """
  def execute(json) do
    path = Path.join([@file_path, @file_name])
    File.write!(path, json)
    IO.inspect System.cmd(@post_cmd)
    File.rm!(path)
  end
end
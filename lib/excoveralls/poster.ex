defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server
  """
  @file_name "excoveralls.post.json"
  @post_cmd  "curl \"https://coveralls.io/api/v1/jobs\" -F json_file=#{@file_name}"

  @doc """
  Create a temporarily json file and post it to server using curl command.
  Then, remove the file after it's completed.
  """
  def execute(json) do
    File.write!(@file_name, json)
    IO.inspect System.cmd(@post_cmd)
    File.rm!(@file_name)
  end
end
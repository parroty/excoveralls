defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server.
  """
  @file_name "excoveralls.post.json"
  @post_cmd  "curl \"https://coveralls.io/api/v1/jobs\" -F json_file=@#{@file_name}"
  @check_curl "which curl"

  @doc """
  Create a temporarily json file and post it to server using curl command.
  Then, remove the file after it's completed.
  It raises error if 'which curl' returns empty.
  """
  def execute(json) do
    if System.cmd(@check_curl) == "" do
      raise "Posting json requires curl, but it's not found."
    else
      File.write!(@file_name, json)
      IO.puts System.cmd(@post_cmd)
      File.rm!(@file_name)
    end
  end
end
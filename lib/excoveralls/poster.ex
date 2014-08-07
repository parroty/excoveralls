defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server.
  """
  @file_name "excoveralls.post.json"

  @doc """
  Create a temporarily json file and post it to server using curl command.
  Then, remove the file after it's completed.
  It raises error if 'which curl' returns empty.
  """
  def execute(json) do
    if is_cmd_available do
      File.write!(@file_name, json)
      run_command(@file_name)
      File.rm!(@file_name)
    else
      raise "Posting json requires curl, but it's not found."
    end
  end

  defp is_cmd_available do
    try do
      {_result, exit_status} = System.cmd("which", ["curl"])
      exit_status == 0
    rescue
      _ -> false
    end
  end

  defp run_command(file_name) do
    {result, _exit_status} = System.cmd("curl", ["https://coveralls.io/api/v1/jobs", "-F", "json_file=@#{file_name}"])
    IO.puts result
  end
end
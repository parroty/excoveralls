defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server.
  """
  @file_name "excoveralls.post.json"

  @doc """
  Create a temporarily json file and post it to server using hackney library.
  Then, remove the file after it's completed.
  """
  def execute(json) do
    File.write!(@file_name, json)
    send_file(@file_name)
    File.rm!(@file_name)
  end

  defp send_file(file_name) do
    :hackney.start
    response = :hackney.request(:post, "https://coveralls.io/api/v1/jobs", [],
      {:multipart, [
        {:file, file_name,
          {"form-data", [{"name", "json_file"}, {"filename", file_name}]},
          [{"Content-Type", "application/json"}]
        }
      ]}
    )
    case response do
      {:ok, status_code, _, _} when status_code in 200..299 ->
        IO.puts "Finished to post a json file"
      {:ok, status_code, _, client} ->
        {:ok, body} = :hackney.body(client)
        raise "Failed to posting a json file: status_code: #{status_code} body: #{body}"
      {:error, reason} ->
        raise "Failed to posting a json file: #{reason}"
    end
  end
end
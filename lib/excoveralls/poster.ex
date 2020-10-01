defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server.
  """
  @file_name "excoveralls.post.json.gz"

  @doc """
  Create a temporarily json file and post it to server using hackney library.
  Then, remove the file after it's completed.
  """
  def execute(json, options \\ []) do
    File.write!(@file_name, json |> :zlib.gzip())
    response = send_file(@file_name, options)
    File.rm!(@file_name)

    case response do
      {:ok, message} ->
        IO.puts(message)

      {:error, message} ->
        raise ExCoveralls.ReportUploadError, message: message
    end
  end

if Code.ensure_loaded?(:hackney) do
  defp send_file(file_name, options) do
    Application.ensure_all_started(:hackney)
    endpoint = options[:endpoint] || "https://coveralls.io"

    response =
      :hackney.request(
        :post,
        "#{endpoint}/api/v1/jobs",
        [],
        {:multipart,
         [
           {:file, file_name, {"form-data", [{"name", "json_file"}, {"filename", file_name}]},
            [{"Content-Type", "gzip/json"}]}
         ]},
        [{:recv_timeout, 10_000}]
      )

    case response do
      {:ok, status_code, _, _} when status_code in 200..299 ->
        {:ok, "Successfully uploaded the report to '#{endpoint}'."}

      {:ok, 500 = _status_code, _, _client} ->
        {:ok, "API endpoint `#{endpoint}` is not available and return internal server error! Ignoring upload"}
      {:ok, 405 = _status_code, _, _client} ->
        {:ok, "API endpoint `#{endpoint}` is not available due to maintenance! Ignoring upload"}
      {:ok, status_code, _, client} ->
        {:ok, body} = :hackney.body(client)

        {:error,
         "Failed to upload the report to '#{endpoint}' (reason: status_code = #{status_code}, body = #{
           body
         })."}

      {:error, reason}  when reason in [:timeout, :connect_timeout] ->
        {:ok, "Unable to upload the report to '#{endpoint}' due to a timeout. Not failing the build."}

      {:error, reason} ->
        {:error, "Failed to upload the report to '#{endpoint}' (reason: #{inspect(reason)})."}
    end
  end
else
  defp send_file(_, _) do
    raise """
    missing :hackney dependency

    ExCoveralls requires :hackney to post to the coveralls.io service.

    Please add :hackney to your mix.exs :deps list and run:

        mix deps.get
        mix deps.clean --build excoveralls
    """
  end
end
end

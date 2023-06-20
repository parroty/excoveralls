defmodule ExCoveralls.Poster do
  @moduledoc """
  Post JSON to coveralls server.
  """
  @file_name "excoveralls.post.json.gz"

  @doc """
  Compresses the given `json` and posts it to the coveralls server.
  """
  def execute(json, options \\ []) do
    case json |> :zlib.gzip() |> upload_zipped_json(options) do
      {:ok, message} ->
        IO.puts(message)

      {:error, message} ->
        raise ExCoveralls.ReportUploadError, message: message
    end
  end

  defp upload_zipped_json(content, options) do
    Application.ensure_all_started(:ssl)
    Application.ensure_all_started(:httpc)
    Application.ensure_all_started(:inets)

    endpoint = options[:endpoint] || "https://coveralls.io"
    host = URI.parse(endpoint).host

    multipart_boundary =
      "---------------------------" <> Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)

    body =
      [
        "--#{multipart_boundary}",
        "content-length: #{byte_size(content)}",
        "content-disposition: form-data; name=json_file; filename=#{@file_name}",
        "content-type: gzip/json",
        "",
        content,
        "--#{multipart_boundary}--"
      ]
      |> Enum.join("\r\n")

    headers = [
      {~c"Host", host},
      {~c"User-Agent", "excoveralls"},
      {~c"Content-Length", Integer.to_string(byte_size(body))},
      {~c"Accept", "*/*"}
    ]

    request = {
      String.to_charlist(endpoint) ++ ~c"/api/v1/jobs",
      headers,
      _content_type = ~c"multipart/form-data; boundary=#{multipart_boundary}",
      body
    }

    case :httpc.request(:post, request, [timeout: 10_000], sync: true) do
      {:ok, {{_protocol, status_code, _status_message}, _headers, _body}}
      when status_code in 200..299 ->
        {:ok, "Successfully uploaded the report to '#{endpoint}'."}

      {:ok, {{_protocol, 500, _status_message}, _headers, _body}} ->
        {:ok,
         "API endpoint `#{endpoint}` is not available and return internal server error! Ignoring upload"}

      {:ok, {{_protocol, 405, _status_message}, _headers, _body}} ->
        {:ok, "API endpoint `#{endpoint}` is not available due to maintenance! Ignoring upload"}

      {:ok, {{_protocol, status_code, _status_message}, _headers, body}} ->
        {:error,
         "Failed to upload the report to '#{endpoint}' (reason: status_code = #{status_code}, body = #{body})."}

      {:error, reason} when reason in [:timeout, :connect_timeout] ->
        {:ok,
         "Unable to upload the report to '#{endpoint}' due to a timeout. Not failing the build."}

      {:error, reason} ->
        {:error, "Failed to upload the report to '#{endpoint}' (reason: #{inspect(reason)})."}
    end
  end
end

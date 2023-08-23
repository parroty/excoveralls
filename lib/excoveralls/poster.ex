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
    Application.ensure_all_started(:inets)

    endpoint = options[:endpoint] || "https://coveralls.io"

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
      {~c"Host", String.to_charlist(URI.parse(endpoint).host)},
      {~c"User-Agent", ~c"excoveralls"},
      {~c"Content-Length", String.to_charlist(Integer.to_string(byte_size(body)))},
      {~c"Accept", ~c"*/*"}
    ]

    # All header names and values MUST be charlists in older OTP versions. In newer versions,
    # binaries are fine. This is hard to debug because httpc simply *hangs* on older OTP
    # versions if you use a binary value.
    if Enum.any?(headers, fn {_, val} -> not is_list(val) end) do
      raise "all header names and values must be charlists"
    end

    request = {
      String.to_charlist(endpoint) ++ ~c"/api/v1/jobs",
      headers,
      _content_type = ~c"multipart/form-data; boundary=#{multipart_boundary}",
      body
    }

    http_options =
      case Application.get_env(:excoveralls, :http_options) do
        [_ | _] = options ->
          options

        _ ->
          [
            timeout: 10_000,
            ssl:
              [
                verify: :verify_peer,
                depth: 2,
                customize_hostname_check: [
                  match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
                ]
                # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
              ] ++ cacert_option()
          ]
      end

    case :httpc.request(:post, request, http_options, sync: true, body_format: :binary) do
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

  # TODO: remove this once we depend on an Elixir version that requires OTP 25+.
  if System.otp_release() >= "25" do
    defp cacert_option do
      if Code.ensure_loaded?(CAStore) do
        [cacertfile: String.to_charlist(CAStore.file_path())]
      else
        case :public_key.cacerts_load() do
          :ok ->
            [cacerts: :public_key.cacerts_get()]

          {:error, reason} ->
            raise ExCoveralls.ReportUploadError,
              message: """
              Failed to load OS certificates. We tried to use OS certificates because we
              couldn't find the :castore library. If you want to use :castore, please add

                {:castore, "~> 1.0"}

              to your dependencies. Otherwise, make sure you can load OS certificates by
              running :public_key.cacerts_load() and checking the result. The error we
              got was:

                #{inspect(reason)}
              """
        end
      end
    end
  else
    defp cacert_option do
      if Code.ensure_loaded?(CAStore) do
        [cacertfile: String.to_charlist(CAStore.file_path())]
      else
        raise ExCoveralls.ReportUploadError,
          message: """
          Failed to use any SSL certificates. We didn't find the :castore library,
          and we couldn't use OS certificates because that requires OTP 25 or later.
          If you want to use :castore, please add

            {:castore, "~> 1.0"}

          """
      end
    end
  end
end

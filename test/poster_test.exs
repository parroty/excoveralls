defmodule PosterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    bypass = Bypass.open()
    %{bypass: bypass, endpoint: "http://localhost:#{bypass.port}"}
  end

  test "successfully posting JSON", %{bypass: bypass, endpoint: endpoint} do
    Bypass.expect(bypass, fn conn ->
      assert conn.method == "POST"
      assert {"host", "localhost"} in conn.req_headers
      Plug.Conn.resp(conn, 200, "")
    end)

    assert capture_io(fn ->
      ExCoveralls.Poster.execute("{}", endpoint: endpoint)
    end) =~ "Successfully uploaded"
  end

  test "post JSON fails", %{bypass: bypass, endpoint: endpoint} do
    Bypass.down(bypass)

    assert_raise ExCoveralls.ReportUploadError, fn ->
      ExCoveralls.Poster.execute("{}", endpoint: endpoint)
    end
  end

  test "post JSON fails due internal server error", %{bypass: bypass, endpoint: endpoint} do
    Bypass.expect(bypass, fn conn ->
      assert conn.method == "POST"
      Plug.Conn.resp(conn, 500, "")
    end)

    assert capture_io(fn ->
      assert ExCoveralls.Poster.execute("{}", endpoint: endpoint) == :ok
    end) =~ ~r/internal server error/
  end

  test "post JSON fails due to maintenance", %{bypass: bypass, endpoint: endpoint} do
    Bypass.expect(bypass, fn conn ->
      assert conn.method == "POST"
      Plug.Conn.resp(conn, 405, "")
    end)

    assert capture_io(fn ->
      assert ExCoveralls.Poster.execute("{}", endpoint: endpoint) == :ok
    end) =~ ~r/maintenance/
  end

  test "passes custom http options when configured", %{bypass: bypass, endpoint: endpoint} do
    Application.put_env(:excoveralls, :http_options, autoredirect: false)

    on_exit(fn ->
      Application.delete_env(:excoveralls, :http_options)
    end)

    Bypass.expect_once(bypass, "POST", "/api/v1/jobs", fn conn ->
      conn
      |> Plug.Conn.put_resp_header("location", Path.join(endpoint, "redirected"))
      |> Plug.Conn.resp(302, "")
    end)

    assert_raise(
      ExCoveralls.ReportUploadError,
      "Failed to upload the report to '#{endpoint}' (reason: status_code = 302, body = ).",
      fn ->
        ExCoveralls.Poster.execute("{}", endpoint: endpoint) == :ok
      end
    )
  end
end

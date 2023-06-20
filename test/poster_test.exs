defmodule PosterTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  
  setup do
    bypass = Bypass.open()
    %{bypass: bypass, endpoint: "http://localhost:#{bypass.port}/"}
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

  test "post JSON fails due internal server error",
       %{bypass: bypass, endpoint: endpoint} do
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
end

defmodule PosterTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO

  test_with_mock "post json", :hackney, [request: fn(_, _, _, _, _) -> {:ok, 200, "", ""} end] do
    assert capture_io(fn ->
      ExCoveralls.Poster.execute("json")
    end) =~ ~r/Successfully uploaded/
  end

  test_with_mock "post json fails", :hackney, [request: fn(_, _, _, _, _) -> {:error, "failed"} end] do
    assert_raise ExCoveralls.ReportUploadError, fn ->
      ExCoveralls.Poster.execute("json")
    end
  end

  test_with_mock "post json timeout", :hackney, [request: fn(_, _, _, _, _) -> {:error, :timeout} end] do
    assert capture_io(fn ->
      assert ExCoveralls.Poster.execute("json") == :ok
    end) =~ ~r/timeout/
  end
end

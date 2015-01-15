defmodule PosterTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO

  @cmd_result "dummy_result"

  test_with_mock "post json", :hackney, [start: fn -> :ok end, request: fn(_, _, _, _) -> {:ok, 200, "", ""} end] do
    assert capture_io(fn ->
      ExCoveralls.Poster.execute("json")
    end) == "Finished to post a json file\n"
  end

  test_with_mock "post json fails", :hackney, [start: fn -> :ok end, request: fn(_, _, _, _) -> {:error, "failed"} end] do
    assert_raise RuntimeError, fn ->
      ExCoveralls.Poster.execute("json")
    end
  end
end

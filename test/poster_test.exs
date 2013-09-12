defmodule PosterTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO

  @cmd_result "dummy_result"
  test_with_mock "post json", System, [cmd: fn(_) -> @cmd_result end] do
    assert capture_io(fn ->
      ExCoveralls.Poster.execute("json")
    end) == @cmd_result <> "\n"
  end

  test_with_mock "post json fails if curl not found", System, [cmd: fn("which curl") -> "" end] do
    assert_raise RuntimeError, fn ->
      ExCoveralls.Poster.execute("json")
    end
  end

end

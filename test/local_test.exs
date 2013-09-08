defmodule ExCoveralls.LocalTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias ExCoveralls.Local

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source      "test/fixtures/test.ex"
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  @invalid_counts [0, 1, nil, "invalid"]
  @invalid_source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @invalid_counts
               ]]

  test "display stats" do
    assert capture_io(fn ->
      Local.execute(@source_info)
    end) ==
      "----------------\n" <>
      "COV    FILE                                        LINES RELEVANT  COVERED\n" <>
      " 50.0% test/fixtures/test.ex                           4        2        1\n"  <>
      "[TOTAL]  50.0%\n" <>
      "----------------\n"
  end

  test "display stats fails with invalid data" do
    assert_raise RuntimeError, fn ->
      Local.format(@invalid_source_info)
    end
  end
end


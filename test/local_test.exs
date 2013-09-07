defmodule ExCoveralls.LocalTest do
  use ExUnit.Case
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
    assert Local.format(@source_info) ==
      " 50.0% test/fixtures/test.ex                           4        2        1"
  end

  test "display stats fails with invalid data" do
    assert_raise RuntimeError, fn ->
      Local.format(@invalid_source_info)
    end
  end
end


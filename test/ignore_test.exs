defmodule ExCoveralls.IgnoreTest do
  use ExUnit.Case
  alias ExCoveralls.Ignore

  @content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-start
    def test_ignored do
    end
    #coveralls-ignore-stop
  end
  """
  @counts      [0, 0, 0, nil, 0, 0, nil, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "filter ignored lines returns valid list" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, 0, 0])
  end
end

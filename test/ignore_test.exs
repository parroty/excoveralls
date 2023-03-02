defmodule ExCoveralls.IgnoreTest do
  use ExUnit.Case
  alias ExCoveralls.Ignore

  @block_content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-start
    def test_ignored do
    end
    #coveralls-ignore-stop
  end
  """
  @block_counts      [0, 0, 0, nil, 0, 0, nil, 0, 0]
  @block_source_info [%{name: "test/fixtures/test.ex",
                 source: @block_content,
                 coverage: @block_counts
               }]

  @single_line_content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-next-line
    def test_ignored do
    end
    def test_not_ignored do
    end
  end
  """
  @single_line_counts      [0, 0, 0, nil, 0, 0, 0, 0, 0, 0]
  @single_line_source_info [%{name: "test/fixtures/test.ex",
                 source: @single_line_content,
                 coverage: @single_line_counts
               }]

  @mixed_content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-start
    def test_ignored do
    #coveralls-ignore-next-line
    end
    #coveralls-ignore-stop
    def test_not_ignored do
    end
  end
  """
  @mixed_counts      [0, 0, 0, nil, 0, nil, 0, nil, 0, 0, 0, 0]
  @mixed_source_info [%{name: "test/fixtures/test.ex",
                 source: @mixed_content,
                 coverage: @mixed_counts
               }]

  test "filter ignored lines with start/stop block returns valid list" do
    info = Ignore.filter(@block_source_info) |> Enum.at(0)
    assert(info[:source]   == @block_content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, 0, 0])
  end

  test "filter ignored lines with next-line returns valid list" do
    info = Ignore.filter(@single_line_source_info) |> Enum.at(0)
    assert(info[:source]   == @single_line_content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, 0, 0, 0, 0, 0])
  end

  test "filter ignored lines with next-line inside start/stop block returns valid list" do
    info = Ignore.filter(@mixed_source_info) |> Enum.at(0)
    assert(info[:source]   == @mixed_content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, nil, 0, 0, 0, 0])
  end
end

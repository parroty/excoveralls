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

  test "filter ignored lines with start/stop block returns valid list" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, 0, 0])
    assert(info[:warnings] == [])
  end

  @content     """
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
  @counts      [0, 0, 0, nil, 0, 0, 0, 0, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "filter ignored lines with next-line returns valid list" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, 0, 0, 0, 0, 0])
    assert(info[:warnings] == [])
  end

  @content     """
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
  @counts      [0, 0, 0, nil, 0, nil, 0, nil, 0, 0, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "filter ignored lines with next-line inside start/stop block produces warning" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, nil, 0, 0, 0, 0])
    assert(info[:warnings] == [{5, "redundant ignore-next-line inside ignore block"}])
  end

  @content     """
  defmodule Test do
    #coveralls-ignore-next-line
    #coveralls-ignore-next-line
  end
  """
  @counts      [0, nil, nil, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "filter ignored lines with next-line right after next-line produces warning" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, nil, nil, nil, 0])
    assert(info[:warnings] == [{2, "duplicated ignore-next-line"}])
  end
  
  @content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-start
    def test do
    end
    #coveralls-ignore-stop
    def test_not_ignored do
    end
    #coveralls-ignore-start
    def test_missing_stop
    end
  end
  """
  @counts     [0, 0, 0, nil, 0, 0, nil, 0, 0, nil, 0, 0, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "start marker without a stop marker produces warning" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, 0, 0, nil, nil, nil, nil, nil])
     assert(info[:warnings] == [{9, "ignore-start without a corresponding ignore-stop"}])
  end

  @content     """
  defmodule Test do
    def test do
    end
    #coveralls-ignore-start
    def test do
    end
    #coveralls-ignore-start
    def test_ignore
    end
    #coveralls-ignore-stop
  end
  """
  @counts     [0, 0, 0, nil, 0, 0, nil, 0, 0, nil, 0, 0]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "start marker followed by another start marker produces warning" do
    info = Ignore.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [0, 0, 0, nil, nil, nil, nil, nil, nil, nil, 0, 0])
    assert(info[:warnings] == [{6, "unexpected ignore-start or missing previous ignore-stop"}])
  end
end

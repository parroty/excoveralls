defmodule ExCoveralls.StopWordsTest do
  use ExUnit.Case
  alias ExCoveralls.StopWords

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test "filter stop words returns valid list" do
    info = StopWords.filter(@source_info, ["defmodule", "end"]) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, 1, nil, nil, nil])
  end

  test "filter stop words returns empty" do
    info = StopWords.filter(@source_info, ["defmodule", "end", "def"]) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, nil, nil, nil, nil])
  end

  test "filter stop words works on regular expression" do
    info = StopWords.filter(@source_info, [~r/^def/]) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, 1, nil, nil, nil])
  end

  test "filter stop words with default file" do
    info = StopWords.filter(@source_info) |> Enum.at(0)
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, 1, nil, nil, nil])
  end
end

defmodule ExCoveralls.StopWordsTest do
  use ExUnit.Case
  alias ExCoveralls.StopWords

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @coverage    [{"test/fixtures/test.ex", @counts}]
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test "filter stop words returns valid list" do
    info = StopWords.filter(@source_info, ["defmodule", "end"]) |> Enum.first
    assert(info[:source]   == "  def test do\n")
    assert(info[:coverage] == [1, nil])
  end

  test "filter stop words returns empty" do
    info = StopWords.filter(@source_info, ["defmodule", "end", "def"]) |> Enum.first
    assert(info[:source]   == "")
    assert(info[:coverage] == [nil])
  end

end

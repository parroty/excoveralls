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

  test "filter stop words on regular expression" do
    info = StopWords.filter(@source_info, [%r/^def/]) |> Enum.first
    assert(info[:source]   == "  def test do\n  end\nend\n")
    assert(info[:coverage] == [1, nil, nil, nil])
  end

  test "get stop words from valid file" do
    assert(StopWords.get_stop_words("test/fixtures/stop_words1") == [%r/words1/, %r/words2/, %r/words3/])
  end

  test "get stop words returns empty list for non-existent fiel" do
    assert(StopWords.get_stop_words("xxx_invalid_file_xxx") == [])
  end
end

defmodule ExCoveralls.StopWordsTest do
  use ExUnit.Case
  alias ExCoveralls.StopWords

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil, nil]
  @coverage    [{"test/fixtures/test.ex", @counts}]
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test "filter stop words returns valid list" do
    info = StopWords.filter(@source_info, ["defmodule", "end"]) |> Enum.first
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, 1, nil, nil, nil])
  end

  test "filter stop words returns empty" do
    info = StopWords.filter(@source_info, ["defmodule", "end", "def"]) |> Enum.first
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, nil, nil, nil, nil])
  end

  test "filter stop words works on regular expression" do
    info = StopWords.filter(@source_info, [%r/^def/]) |> Enum.first
    assert(info[:source]   == @content)
    assert(info[:coverage] == [nil, 1, nil, nil, nil])
  end

  test "get stop words words" do
    assert(StopWords.get_stop_words("test/fixtures/stop_words1") == [%r/words1/, %r/words2/, %r/words3/])
  end

  test "get stop words skips empty line in the file" do
    assert(StopWords.get_stop_words("test/fixtures/stop_words2") == [%r/words1/, %r/words3/])
  end

  test "get stop words returns empty list for non-existent file" do
    assert(StopWords.get_stop_words("xxx_invalid_file_xxx") == [])
  end

  test "get default stop word file" do
    assert(StopWords.default_stop_word_file |> Path.relative_to_cwd == ".coverallsignore")
  end
end

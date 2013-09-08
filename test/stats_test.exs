defmodule ExCoveralls.StatsTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover

  @stats       [{{Stats, 1}, 0}, {{Stats, 2}, 1}]
  @modules     [Stats]
  @source      "test/fixtures/test.ex"
  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @count_hash  HashDict.new([{1, 0}, {2, 1}])
  @module_hash HashDict.new([{"test/fixtures/test.ex", @count_hash}])
  @counts      [0, 1, nil, nil]
  @coverage    [{"test/fixtures/test.ex", @counts}]
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test_with_mock "calculate stats", Cover, [analyze: fn(_) -> {:ok, @stats} end, module_path: fn(_) -> @source end] do
    assert(Stats.calculate_stats([Stats]) == @module_hash)
  end

  test_with_mock "get source line count", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.get_source_line_count(@source) == 5)
  end

  test "filter stop words returns value" do
    info = Stats.filter_stop_words(@source_info, ["defmodule", "end"]) |> Enum.first
    assert(info[:source]   == "  def test do")
    assert(info[:coverage] == [1])
  end

  test "filter stop words return empty" do
    info = Stats.filter_stop_words(@source_info, ["defmodule", "end", "def"]) |> Enum.first
    assert(info[:source]   == "")
    assert(info[:coverage] == [])
  end

  test "read source file" do
    assert(Stats.read_source(@source) == @content)
  end

  test_with_mock "generate coverage", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.generate_coverage(@module_hash) == @coverage)
  end

  test_with_mock "generate source info", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.generate_source_info(@coverage) == @source_info)
  end
end

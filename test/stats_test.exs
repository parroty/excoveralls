defmodule ExCoveralls.StatsTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover
  alias ExCoveralls.Settings

  @stats           [{{Stats, 1}, 0}, {{Stats, 2}, 1}]
  @source          "test/fixtures/test.ex"
  @content         "defmodule Test do\n  def test do\n  end\nend\n"
  @trimmed         "defmodule Test do\n  def test do\n  end\nend"
  @count_hash      Enum.into([{1, 0}, {2, 1}], Map.new)
  @module_hash     Enum.into([{"test/fixtures/test.ex", @count_hash}], Map.new)
  @counts          [0, 1, nil, nil]
  @coverage        [{"test/fixtures/test.ex", @counts}]
  @source_info     [%{name: "test/fixtures/test.ex",
                     source: @trimmed,
                     coverage: @counts
                   }]
  @fixture_default Path.dirname(__ENV__.file) <> "/fixtures/default.json"
  @fixture_custom  Path.dirname(__ENV__.file) <> "/fixtures/skip_files.json"

  @invalid_counts [0, 1, nil, "invalid"]
  @invalid_source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @invalid_counts
               }]

  @empty_counts [nil, nil, nil, nil]
  @empty_source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @empty_counts
               }]

  @source_result %{
    coverage: 50,
    files: [
      %ExCoveralls.Stats.Source{
        coverage: 50,
        filename: "test/fixtures/test.ex",
        hits: 1,
        misses: 1,
        sloc: 2,
        source: [
          %ExCoveralls.Stats.Line{coverage: 0, source: "defmodule Test do"},
          %ExCoveralls.Stats.Line{coverage: 1, source: "  def test do"},
          %ExCoveralls.Stats.Line{coverage: nil, source: "  end"},
          %ExCoveralls.Stats.Line{coverage: nil, source: "end"}]}],
    hits: 1,
    misses: 1,
    sloc: 2}

  @fractional_counts [0, 1, 1, nil, nil]
  @fractional_source_info [[name: "test/fixtures/test.ex",
                     source: @trimmed,
                     coverage: @fractional_counts
                   ]]

  test_with_mock "calculate stats", Cover, [analyze: fn(_) -> {:ok, @stats} end, module_path: fn(_) -> @source end] do
    assert(Stats.calculate_stats([Stats]) == @module_hash)
  end

  test_with_mock "get source line count", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.get_source_line_count(@source) == 4)
  end

  test_with_mock "read module source", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.read_module_source(Stats) == @trimmed)
  end

  test "read source file" do
    assert(Stats.read_source(@source) == @trimmed)
  end

  test_with_mock "generate coverage", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.generate_coverage(@module_hash) == @coverage)
  end

  test_with_mock "generate source info", Cover, [module_path: fn(_) -> @source end] do
    assert(Stats.generate_source_info(@coverage) == @source_info)
  end

  test_with_mock "append sub app name", Cover, [module_path: fn(_) -> @source end] do
    stats = Stats.append_sub_app_name(@source_info, "subapp", "apps")
    assert(List.first(stats)[:name] == "apps/subapp/test/fixtures/test.ex")
  end

  test "trim empty suffix and prefix" do
    assert(Stats.trim_empty_prefix_and_suffix("\naaa\nbbb\n") == "aaa\nbbb")
  end
  @fixture_default Path.dirname(__ENV__.file) <> "/fixtures/default.json"

  test_with_mock "skip files", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_custom end,
                    dot_file:  fn -> "__invalid__" end] do
    assert Stats.skip_files(@source_info) == []
  end

  test "display source information" do
    assert(Stats.source(@source_info) == @source_result)
  end

  test "display source information with nil filter" do
    assert(Stats.source(@source_info, nil) == @source_result)
  end

  test "display source information with empty filter" do
    assert(Stats.source(@source_info, []) == @source_result)
  end

  test "display source information with pattern filter" do
    assert(Stats.source(@source_info, ["test.ex"]) == @source_result)
  end

  test "display stats information fails with invalid data" do
    assert_raise ArithmeticError, fn ->
      Stats.source(@invalid_source_info)
    end
  end

  test "Empty (no relevant lines) file is calculated as 0.0%" do
    results = Stats.source(@empty_source_info)
    assert(results.coverage == 0)
  end

  test_with_mock "Empty (no relevant lines) file with treat_no_relevant_lines_as_covered option is calculated as 100.0%",
    ExCoveralls.Settings, [default_coverage_value: fn -> 100 end] do

    results = Stats.source(@empty_source_info)
    assert(results.coverage == 100)
  end

  test "coverage stats are rounded to one decimal place" do
    results = Stats.source(@fractional_source_info)
    assert(results.coverage == 66.7)
  end

  describe "update_stats/2" do
    @test_path_1 "apps/umbrella1_app1/lib/umbrella1_app1.ex"
    @test_path_2 "apps/umbrella1_app2/lib/umbrella1_app2.ex"
    @test_stats [
      %{
        coverage: [],
        name: @test_path_1,
        source: "dummy_source2"
      },
      %{
        coverage: [],
        name: @test_path_2,
        source: "dummy_source1"
      }
    ]

    test "subdir is added to filepath" do
      result =
        Stats.update_paths(@test_stats, [rootdir: "", subdir: "umbrella1/"])
        |> Enum.map(fn m -> assert String.starts_with?(m[:name], "umbrella1/") end)
        |> Enum.all?(fn v -> v end)
      assert result
    end

    test "rootdir is removed from filepath" do
      result =
        Stats.update_paths(@test_stats, [rootdir: "apps/", subdir: ""])
        |> Enum.map(fn m -> assert String.starts_with?(m[:name], "umbrella1_app") end)
        |> Enum.all?(fn v -> v end)
      assert result
    end

    test "filepath is untouched when no options for rootdir/subdir" do
      result =
        Stats.update_paths(@test_stats, [rootdir: "", subdir: ""])
        |> Enum.map(fn m -> assert String.starts_with?(m[:name], "apps/umbrella1_app") end)
        |> Enum.all?(fn v -> v end)
      assert result
    end

    test "filepath is untouched when options for rootdir/subdir does not exist" do
      result =
        Stats.update_paths(@test_stats, [])
        |> Enum.map(fn m -> assert String.starts_with?(m[:name], "apps/umbrella1_app") end)
        |> Enum.all?(fn v -> v end)
      assert result
    end
  end
end

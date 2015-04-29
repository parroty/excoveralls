defmodule ExCoveralls.LocalTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
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

  @empty_counts [nil, nil, nil, nil]
  @empty_source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @empty_counts
               ]]
  @empty_result "" <>
      "  0.0% test/fixtures/test.ex                           4        0        0\n[TOTAL]   0.0%"

  @stats_result "" <>
      "----------------\n" <>
      "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
      " 50.0% test/fixtures/test.ex                           4        2        1\n"  <>
      "[TOTAL]  50.0%\n" <>
      "----------------\n"

  @source_result "" <>
      "\n\e[33m--------test/fixtures/test.ex--------\e[m\n" <>
      "\e[31mdefmodule Test do\e[m\n\e[32m  def test do\e[m\n" <>
      "  end\n" <>
      "end"

  test "display source information" do
    assert(Local.source(@source_info) =~ @source_result)
  end

  test "display source information with empty filter" do
    assert(Local.source(@source_info, []) =~ @source_result)
  end

  test "display source information with pattern filter" do
    assert(Local.source(@source_info, ["test.ex"]) =~ @source_result)
  end

  test "display stats information" do
    assert capture_io(fn ->
      Local.execute(@source_info)
    end) =~ @stats_result
  end

  test "display stats information with detail option" do
    assert capture_io(fn ->
      Local.execute(@source_info, [detail: true])
    end) =~ @stats_result <> @source_result <> "\n"
  end

  test "display stats information fails with invalid data" do
    assert_raise RuntimeError, fn ->
      Local.coverage(@invalid_source_info)
    end
  end

  test "Empty (no relevant lines) file is calculated as 0.0%" do
    assert String.ends_with?(Local.coverage(@empty_source_info), "[TOTAL]   0.0%")
  end

  test_with_mock "Empty (no relevant lines) file with treat_no_relevant_lines_as_covered option is calculated as 100.0%",
    ExCoveralls.Settings, [get_coverage_options: fn -> %{"treat_no_relevant_lines_as_covered" => true} end] do

    assert String.ends_with?(Local.coverage(@empty_source_info), "[TOTAL] 100.0%")
  end
end

defmodule ExCoveralls.HtmlTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Html

  @file_name "excoveralls.html"
  @file_size 20155
  @test_output_dir "cover_test/"
  @test_template_path "lib/templates/html/htmlcov/"

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

  @stats_result "" <>
    "----------------\n" <>
    "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
    " 50.0% test/fixtures/test.ex                           4        2        1\n"  <>
    "[TOTAL]  50.0%\n" <>
    "----------------\n"

  @empty_result %{
    coverage: 0,
    files: [
      %ExCoveralls.Html.Source{
        coverage: 0,
        filename: "test/fixtures/test.ex",
        hits: 0,
        misses: 0,
        sloc: 0,
        source: [
          %ExCoveralls.Html.Line{coverage: nil, source: "defmodule Test do"},
          %ExCoveralls.Html.Line{coverage: nil, source: "  def test do"},
          %ExCoveralls.Html.Line{coverage: nil, source: "  end"},
          %ExCoveralls.Html.Line{coverage: nil, source: "end"},
          %ExCoveralls.Html.Line{coverage: nil, source: ""}]}],
    hits: 0,
    misses: 0,
    sloc: 0}

  @source_result %{
    coverage: 50,
    files: [
      %ExCoveralls.Html.Source{
        coverage: 50,
        filename: "test/fixtures/test.ex",
        hits: 1,
        misses: 1,
        sloc: 2,
        source: [
          %ExCoveralls.Html.Line{coverage: 0, source: "defmodule Test do"},
          %ExCoveralls.Html.Line{coverage: 1, source: "  def test do"},
          %ExCoveralls.Html.Line{coverage: nil, source: "  end"},
          %ExCoveralls.Html.Line{coverage: nil, source: "end"},
          %ExCoveralls.Html.Line{coverage: nil, source: ""}]}],
    hits: 1,
    misses: 1,
    sloc: 2}

  test "display source information" do
    assert(Html.source(@source_info) == @source_result)
  end

  test "display source information with nil filter" do
    assert(Html.source(@source_info, nil) == @source_result)
  end

  test "display source information with empty filter" do
    assert(Html.source(@source_info, []) == @source_result)
  end

  test "display source information with pattern filter" do
    assert(Html.source(@source_info, ["test.ex"]) == @source_result)
  end

  setup do
    path = Path.expand(@file_name, @test_output_dir)

    # Assert does not exist prior to write
    assert(File.exists?(path) == false)
    on_exit fn ->
      if File.exists?(path) do
        # Ensure removed after test
        File.rm!(path)
        File.rmdir!(@test_output_dir)
      end
    end

    {:ok, report: path}
  end

  test_with_mock "generate stats information", %{report: report}, ExCoveralls.Settings, [],
    [get_coverage_options: fn -> %{"output_dir" => @test_output_dir, "template_path" => @test_template_path} end] do

    assert capture_io(fn ->
      Html.execute(@source_info)
    end) =~ @stats_result

    assert(File.read!(report) =~ "id='test/fixtures/test.ex'")
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

  test "display stats information fails with invalid data" do
    assert_raise ArithmeticError, fn ->
      Html.source(@invalid_source_info)
    end
  end

  test "Empty (no relevant lines) file is calculated as 0.0%" do
    results = Html.source(@empty_source_info)
    assert(results.coverage == 0)
  end

  test_with_mock "Empty (no relevant lines) file with treat_no_relevant_lines_as_covered option is calculated as 100.0%",
    ExCoveralls.Settings, [get_coverage_options: fn -> %{"treat_no_relevant_lines_as_covered" => true} end] do

    results = Html.source(@empty_source_info)
    assert(results.coverage == 100)
  end
end

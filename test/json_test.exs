defmodule ExCoveralls.JsonTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Json

  @file_name "excoveralls.json"
  @file_size 136
  @test_output_dir "cover_test/"

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
      %ExCoveralls.Stats.Source{
        coverage: 0,
        filename: "test/fixtures/test.ex",
        hits: 0,
        misses: 0,
        sloc: 0,
        source: [
          %ExCoveralls.Stats.Line{coverage: nil, source: "defmodule Test do"},
          %ExCoveralls.Stats.Line{coverage: nil, source: "  def test do"},
          %ExCoveralls.Stats.Line{coverage: nil, source: "  end"},
          %ExCoveralls.Stats.Line{coverage: nil, source: "end"},
          %ExCoveralls.Stats.Line{coverage: nil, source: ""}]}],
    hits: 0,
    misses: 0,
    sloc: 0}

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
          %ExCoveralls.Stats.Line{coverage: nil, source: "end"},
          %ExCoveralls.Stats.Line{coverage: nil, source: ""}]}],
    hits: 1,
    misses: 1,
    sloc: 2}

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

  test_with_mock "generate json file", %{report: report}, ExCoveralls.Settings, [],
    [get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end, get_file_col_width: fn -> 40 end] do

    assert capture_io(fn ->
      Json.execute(@source_info)
    end) =~ @stats_result

    assert(File.read!(report) =~ ~s({"source_files":[{"name":"test/fixtures/test.ex","source":"defmodule Test do\\n  def test do\\n  end\\nend\\n","coverage":[0,1,null,null]}]}))
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

end


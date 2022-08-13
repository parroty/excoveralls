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
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts
               }]

  @stats_result "" <>
    "----------------\n" <>
    "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
    " 50.0% test/fixtures/test.ex                           4        2        1\n"  <>
    "[TOTAL]  50.0%\n" <>
    "----------------\n"

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
      [
        get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end,
        get_file_col_width: fn -> 40 end,
        get_print_summary: fn -> true end,
        get_print_files: fn -> true end
      ] do

    assert capture_io(fn ->
      Json.execute(@source_info)
    end) =~ @stats_result

    assert(File.read!(report) =~ ~s({"source_files":[{"coverage":[0,1,null,null],"name":"test/fixtures/test.ex","source":"defmodule Test do\\n  def test do\\n  end\\nend\\n"}]}))
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

  test "generate json file with output_dir parameter", %{report: report} do
    assert capture_io(fn ->
      Json.execute(@source_info, [output_dir: @test_output_dir])
    end) =~ @stats_result

    assert(File.read!(report) =~ ~s({"source_files":[{"coverage":[0,1,null,null],"name":"test/fixtures/test.ex","source":"defmodule Test do\\n  def test do\\n  end\\nend\\n"}]}))
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

  test_with_mock "exit status code is 1 when actual coverage does not reach the minimum",
      ExCoveralls.Settings, [
        get_coverage_options: fn -> coverage_options(100) end,
        get_file_col_width: fn -> 40 end,
        get_print_summary: fn -> true end,
        get_print_files: fn -> true end
      ] do
    output = capture_io(fn ->
      assert catch_exit(Json.execute(@source_info)) == {:shutdown, 1}
    end)
    assert String.contains?(output, "FAILED: Expected minimum coverage of 100%, got 50%.")
  end

  test_with_mock "exit status code is 0 when actual coverage reaches the minimum",
      ExCoveralls.Settings, [
        get_coverage_options: fn -> coverage_options(49.9) end,
        get_file_col_width: fn -> 40 end,
        get_print_summary: fn -> true end,
        get_print_files: fn -> true end
      ] do
    assert capture_io(fn ->
      Json.execute(@source_info)
    end) =~ @stats_result
  end

  defp coverage_options(minimum_coverage) do
    %{
      "minimum_coverage" => minimum_coverage,
      "output_dir" => @test_output_dir,
    }
  end
end

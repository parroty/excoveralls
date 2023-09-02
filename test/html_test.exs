defmodule ExCoveralls.HtmlTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Html

  @file_name "excoveralls.html"
  @file_size 20375
  @test_output_dir "cover_test/"
  @test_template_path "lib/templates/html/htmlcov/"

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
    ExCoveralls.ConfServer.clear()
    path = Path.expand(@file_name, @test_output_dir)

    # Assert does not exist prior to write
    assert(File.exists?(path) == false)
    on_exit fn ->
      if File.exists?(path) do
        # Ensure removed after test
        File.rm!(path)
        File.rmdir!(@test_output_dir)
      end
      
      ExCoveralls.ConfServer.clear()
    end

    {:ok, report: path}
  end

  test "generate stats information with output_dir parameter", %{report: report} do
    assert capture_io(fn ->
      Html.execute(@source_info, [output_dir: @test_output_dir])
    end) =~ @stats_result

    assert(File.read!(report) =~ "id='test/fixtures/test.ex'")
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

  test_with_mock "generate stats information", %{report: report}, ExCoveralls.Settings, [],
      [
        get_coverage_options: fn -> %{"output_dir" => @test_output_dir, "template_path" => @test_template_path} end,
        get_file_col_width: fn -> 40 end,
        get_print_summary: fn -> true end,
        get_print_files: fn -> true end
      ] do
    assert capture_io(fn ->
      Html.execute(@source_info)
    end) =~ @stats_result

    assert(File.read!(report) =~ "id='test/fixtures/test.ex'")
    %{size: size} = File.stat! report
    assert(size == @file_size)
  end

end

defmodule ExCoveralls.JsonTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Json

  @file_name "excoveralls"
  @file_size 136
  @test_output_dir "cover_test/"

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts,
                  warnings: []
               }]

  @stats_result "" <>
    "----------------\n" <>
    "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
    " 50.0% test/fixtures/test.ex                           4        2        1\n"  <>
    "[TOTAL]  50.0%\n" <>
    "----------------\n"

  setup do
    on_entry = fn name, path -> 
      ExCoveralls.ConfServer.clear()
      path = Path.expand("#{name}.json", path)

      # Assert does not exist prior to write
      assert(File.exists?(path) == false)

      path
    end
    on_exit = fn path, dir ->
      if File.exists?(path) do
        # Ensure removed after test
        File.rm!(path)
        File.rmdir!(dir)
      end

      ExCoveralls.ConfServer.clear()
    end

    {:ok, on_entry: on_entry, on_exit: on_exit}
  end

  test_with_mock "generate json file", %{on_entry: on_entry, on_exit: on_exit}, ExCoveralls.Settings, [],
      [
        get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end,
        get_file_col_width: fn -> 40 end,
        get_print_summary: fn -> true end,
        get_print_files: fn -> true end
      ] do
    report = on_entry.(@file_name, @test_output_dir)

    assert capture_io(fn ->
      Json.execute(@source_info)
    end) =~ @stats_result

    assert(
      %{
        "source_files" => [
          %{
            "coverage" => [0, 1, nil, nil],
            "name" => "test/fixtures/test.ex",
            "source" => "defmodule Test do\n  def test do\n  end\nend\n"
          }
        ]
      } = Jason.decode!(File.read!(report)))
    %{size: size} = File.stat! report
    assert(size == @file_size)

    on_exit.(report, @test_output_dir)
  end

  test "generate json file with output_dir parameter", %{on_entry: on_entry, on_exit: on_exit} do
    report = on_entry.(@file_name, "coverme")
    assert capture_io(fn ->
      Json.execute(@source_info, [output_dir: "coverme"])
    end) =~ @stats_result

    assert(
      %{
        "source_files" => [
          %{
            "coverage" => [0, 1, nil, nil],
            "name" => "test/fixtures/test.ex",
            "source" => "defmodule Test do\n  def test do\n  end\nend\n"
          }
        ]
      } = Jason.decode!(File.read!(report)))
    %{size: size} = File.stat! report
    assert(size == @file_size)

    on_exit.(report, "coverme")
  end

  test "generate json file with custom filename", %{on_entry: on_entry, on_exit: on_exit} do
    report = on_entry.("custom", @test_output_dir)

    assert capture_io(fn ->
      Json.execute(@source_info, [output_dir: @test_output_dir])
    end) =~ @stats_result

    assert(
      %{
        "source_files" => [
          %{
            "coverage" => [0, 1, nil, nil],
            "name" => "test/fixtures/test.ex",
            "source" => "defmodule Test do\n  def test do\n  end\nend\n"
          }
        ]
      } = Jason.decode!(File.read!(report)))
    %{size: size} = File.stat! report
    assert(size == @file_size)

    on_exit.(report, @test_output_dir)
  end
end

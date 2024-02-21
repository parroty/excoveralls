defmodule ExCoveralls.CoberturaTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Cobertura

  @file_name "cobertura.xml"
  @test_output_dir "cover_test/"

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts,
                  warnings: []
               }]

  @stats_result "" <>
                  "----------------\n" <>
                  "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
                  " 50.0% test/fixtures/test.ex                           4        2        1\n" <>
                  "[TOTAL]  50.0%\n" <>
                  "----------------\n"

  setup do
    ExCoveralls.ConfServer.clear()
    path = Path.expand(@file_name, @test_output_dir)

    # Assert does not exist prior to write
    assert(File.exists?(path) == false)

    on_exit(fn ->
      if File.exists?(path) do
        # Ensure removed after test
        File.rm!(path)
        File.rmdir!(@test_output_dir)
      end

      ExCoveralls.ConfServer.clear()
    end)

    {:ok, report: path}
  end

  test_with_mock "generate cobertura file", %{report: report}, ExCoveralls.Settings, [],
    get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end,
    get_file_col_width: fn -> 40 end,
    get_print_summary: fn -> true end,
    get_print_files: fn -> true end do
    assert capture_io(fn -> Cobertura.execute(@source_info) end) =~ @stats_result

    assert {:ok, xml_map} =
             report |> File.read!() |> SAXMap.from_string(ignore_attribute: {false, "@"})

    assert %{
             "coverage" => %{
               "@branch-rate" => "0.0",
               "@branches-covered" => "0",
               "@branches-valid" => "0",
               "@complexity" => "0",
               "@line-rate" => "0.5",
               "@lines-covered" => "1",
               "@lines-valid" => "2",
               "@timestamp" => _,
               "@version" => "2.1.1",
               "content" => %{
                 "packages" => %{
                   "content" => %{
                     "package" => %{
                       "@branch-rate" => "0.0",
                       "@complexity" => "0",
                       "@line-rate" => "0.5",
                       "@name" => "",
                       "content" => %{
                         "classes" => %{
                           "content" => %{
                             "class" => %{
                               "@branch-rate" => "0.0",
                               "@complexity" => "0",
                               "@filename" => "test.ex",
                               "@line-rate" => "0.5",
                               "@name" => "Test",
                               "content" => %{
                                 "lines" => %{
                                   "content" => %{
                                     "line" => [
                                       %{
                                         "@branch" => "False",
                                         "@hits" => "0",
                                         "@number" => "1",
                                         "content" => nil
                                       },
                                       %{
                                         "@branch" => "False",
                                         "@hits" => "1",
                                         "@number" => "2",
                                         "content" => nil
                                       }
                                     ]
                                   }
                                 },
                                 "methods" => %{"content" => nil}
                               }
                             }
                           }
                         }
                       }
                     }
                   }
                 },
                 "sources" => %{
                   "content" => %{
                     "source" => [
                       %{"content" => source1},
                       %{"content" => source2}
                     ]
                   }
                 }
               }
             }
           } = xml_map

    assert String.ends_with?(source1, "/lib")
    assert String.ends_with?(source2, "/test/fixtures")
  end

  test "generate cobertura file with output_dir parameter", %{report: report} do
    assert capture_io(fn -> Cobertura.execute(@source_info, output_dir: @test_output_dir) end) =~
             @stats_result

    assert {:ok, xml_map} =
             report |> File.read!() |> SAXMap.from_string(ignore_attribute: {false, "@"})

    assert %{
             "coverage" => %{
               "@branch-rate" => "0.0",
               "@branches-covered" => "0",
               "@branches-valid" => "0",
               "@complexity" => "0",
               "@line-rate" => "0.5",
               "@lines-covered" => "1",
               "@lines-valid" => "2",
               "@timestamp" => _,
               "@version" => "2.1.1",
               "content" => %{
                 "packages" => %{
                   "content" => %{
                     "package" => %{
                       "@branch-rate" => "0.0",
                       "@complexity" => "0",
                       "@line-rate" => "0.5",
                       "@name" => "",
                       "content" => %{
                         "classes" => %{
                           "content" => %{
                             "class" => %{
                               "@branch-rate" => "0.0",
                               "@complexity" => "0",
                               "@filename" => "test.ex",
                               "@line-rate" => "0.5",
                               "@name" => "Test",
                               "content" => %{
                                 "lines" => %{
                                   "content" => %{
                                     "line" => [
                                       %{
                                         "@branch" => "False",
                                         "@hits" => "0",
                                         "@number" => "1",
                                         "content" => nil
                                       },
                                       %{
                                         "@branch" => "False",
                                         "@hits" => "1",
                                         "@number" => "2",
                                         "content" => nil
                                       }
                                     ]
                                   }
                                 },
                                 "methods" => %{"content" => nil}
                               }
                             }
                           }
                         }
                       }
                     }
                   }
                 },
                 "sources" => %{
                   "content" => %{
                     "source" => [
                       %{"content" => source1},
                       %{"content" => source2}
                     ]
                   }
                 }
               }
             }
           } = xml_map

    assert String.ends_with?(source1, "/lib")
    assert String.ends_with?(source2, "/test/fixtures")
  end

  test_with_mock "generate cobertura file with defprotocol", _, ExCoveralls.Settings, [],
    get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end,
    get_file_col_width: fn -> 40 end,
    get_print_summary: fn -> true end,
    get_print_files: fn -> true end do
    content = "defprotocol TestProtocol do\n  def test(value)\nend\n"
    counts = [0, 1, nil, nil]
    source_info = [%{name: "test/fixtures/test_protocol.ex",
                     source: content,
                     coverage: counts,
                     warnings: []
                  }]

    stats_result =
      "" <>
        "----------------\n" <>
        "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
        " 50.0% test/fixtures/test_protocol.ex                  4        2        1\n" <>
        "[TOTAL]  50.0%\n" <>
        "----------------\n"

    assert capture_io(fn -> Cobertura.execute(source_info) end) =~ stats_result
  end

  test_with_mock "generate cobertura file with defimpl", _, ExCoveralls.Settings, [],
    get_coverage_options: fn -> %{"output_dir" => @test_output_dir} end,
    get_file_col_width: fn -> 40 end,
    get_print_summary: fn -> true end,
    get_print_files: fn -> true end do
    content = "defimpl TestProtocol, for: Integer do\n  def test(value), do: \"integer!\" \nend\n"
    counts = [0, 1, nil, nil]
    source_info = [%{name: "test/fixtures/test_impl.ex",
                     source: content,
                     coverage: counts,
                     warnings: []
                  }]

    stats_result =
      "" <>
        "----------------\n" <>
        "COV    FILE                                        LINES RELEVANT   MISSED\n" <>
        " 50.0% test/fixtures/test_impl.ex                      4        2        1\n" <>
        "[TOTAL]  50.0%\n" <>
        "----------------\n"

    assert capture_io(fn -> Cobertura.execute(source_info) end) =~ stats_result
  end
end

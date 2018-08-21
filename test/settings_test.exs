defmodule Excoveralls.SettingsTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Settings

  @fixture_default Path.dirname(__ENV__.file) <> "/fixtures/default.json"
  @fixture_custom  Path.dirname(__ENV__.file) <> "/fixtures/custom.json"
  @fixture_dotfile  Path.dirname(__ENV__.file) <> "/fixtures/dotfile.json"
  @fixture_invalid Path.dirname(__ENV__.file) <> "/fixtures/invalid.json"
  @fixture_not_covered Path.dirname(__ENV__.file) <> "/fixtures/no_relevant_lines_not_covered.json"
  @fixture_covered Path.dirname(__ENV__.file) <> "/fixtures/no_relevant_lines_are_covered.json"
  @fixture_column_default Path.dirname(__ENV__.file) <> "/fixtures/terminal_options1.json"
  @fixture_column_integer Path.dirname(__ENV__.file) <> "/fixtures/terminal_options2.json"
  @fixture_no_summary Path.dirname(__ENV__.file) <> "/fixtures/no_summary.json"

  test "returns default file path" do
    assert(Settings.Files.default_file
           |> Path.relative_to(File.cwd!) == "lib/excoveralls/../conf/coveralls.json")
  end

  test "returns custom file path" do
    assert(Settings.Files.custom_file
           |> Path.relative_to(File.cwd!) == "coveralls.json")
  end

  test "returns custom file path from config file" do
    Application.put_env(:excoveralls, :config_file, "custom_coveralls.json")

    assert(Settings.Files.custom_file
           |> Path.relative_to(File.cwd!) == "custom_coveralls.json")

    Application.delete_env(:excoveralls, :config_file)
  end

  test_with_mock "read config defined in default file", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_custom end,
                    dot_file: fn -> @fixture_dotfile end] do
    assert(Settings.read_config("default_stop_words") == ["a", "b"])
  end

  test_with_mock "read config defined in custom file", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_custom end,
                     dot_file: fn -> "__invalid__" end] do
    assert(Settings.read_config("custom_stop_words") == ["aa", "bb"])
  end

  test_with_mock "get stop words returns merged default and custom stop words", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_custom end,
                     dot_file: fn -> "__invalid__" end] do
    assert(Settings.get_stop_words == [~r"a", ~r"b", ~r"aa", ~r"bb"])
  end

  test_with_mock "get coverage options returns options as Dict", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_custom end,
                     dot_file: fn -> "__invalid__" end] do
    assert(inspect(Settings.get_coverage_options) == "%{\"f\" => true}")
  end

  test_with_mock "get terminal width for file column", Settings.Files,
                  [default_file: fn -> @fixture_column_default end,
                   custom_file:  fn -> @fixture_column_integer end,
                    dot_file: fn -> @fixture_dotfile end] do
    assert(inspect(Settings.get_file_col_width) == "40")
  end

  test_with_mock "read config returns nil when default file is not found", Settings.Files,
                   [default_file: fn -> "__invalid__" end,
                    custom_file:  fn -> "__invalid__" end,
                     dot_file: fn -> "__invalid__" end] do
    assert(Settings.read_config("custom_stop_words", []) == [])
  end

  test_with_mock "read config returns default value when custom file is not found", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> "__invalid__" end,
                     dot_file: fn -> @fixture_dotfile end] do
    assert(Settings.read_config("default_stop_words") == ["a", "b"])
  end

  test_with_mock "read config fails if JSON file is invalid", Settings.Files,
                   [default_file: fn -> @fixture_default end,
                    custom_file:  fn -> @fixture_invalid end,
                     dot_file: fn -> @fixture_dotfile end] do
    assert_raise RuntimeError, fn ->
      Settings.read_config("default_stop_words")
    end
  end

  test_with_mock "default coverage value returns 100 when treating irrelevant lines as covered",
    Settings.Files, [
      default_file: fn -> @fixture_default end,
      custom_file:  fn -> @fixture_covered end,
                   dot_file: fn -> @fixture_dotfile end
    ] do
    assert Settings.default_coverage_value == 100
  end

  test_with_mock "default coverage value returns 0 when treating irrelevant lines as not covered",
                 Settings.Files, [
                   default_file: fn -> @fixture_default end,
                   custom_file:  fn -> @fixture_not_covered end,
                   dot_file: fn -> @fixture_dotfile end
                 ] do
    assert Settings.default_coverage_value == 0
  end

  test_with_mock "merges dotfile config with custom config",
    Settings.Files, [
      default_file: fn -> @fixture_default end,
      custom_file:  fn -> @fixture_custom end,
      dot_file: fn -> @fixture_dotfile end
    ] do
    assert Settings.default_coverage_value == 0
    assert Settings.get_stop_words()== [~r/a/, ~r/b/, ~r/cc/, ~r/dd/, ~r/aa/, ~r/bb/]
  end

  test_with_mock "print_summary is true by default",
    Settings.Files, [
      default_file: fn -> "__invalid__" end,
      custom_file:  fn -> "__invalid__" end,
      dot_file: fn -> "__invalid__" end
    ] do

    assert Settings.get_print_summary
  end

  test_with_mock "print_summary can be set to false",
    Settings.Files, [
      default_file: fn -> "__invalid__" end,
      custom_file:  fn -> @fixture_no_summary end,
      dot_file: fn -> "__invalid__" end
    ] do

    refute Settings.get_print_summary
  end

end


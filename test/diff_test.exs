defmodule ExCoveralls.DiffTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO
  alias ExCoveralls.Diff

  @content "defmodule Test do\n  def test do\n    called\n    not_called\n  end\n  def test2, do: nil\nend\n"
  @counts [0, 0, 1, 0, nil, nil]
  @filename "test/fixtures/test.ex"
  @source_info [%{name: @filename, source: @content, coverage: @counts}]
  @git_diff "@@ +3,2 @@\n\n@@ -4 +4 @@"

  test "prints coverage info" do
    options = [threshold: 0.0, files: [@filename]]

    with_mock(System, cmd: fn "git", ["diff" | _rest] -> {@git_diff, 0} end) do
      output = capture_io(fn -> Diff.execute(@source_info, options) end)
      assert output =~ @filename
      assert output =~ "3\e[38;5;46m │\e[0m\e[38;5;71m    called\e[0m"
      assert output =~ "4\e[38;5;46m │\e[0m\e[38;5;131m    not_called\e[0m"
    end
  end

  test "exits with code 1 when coverage is less than minimum" do
    options = [threshold: 100.0, files: [@filename]]

    result =
      catch_exit(
        with_mock(System, cmd: fn "git", ["diff" | _rest] -> {@git_diff, 0} end) do
          output =
            capture_io(fn ->
              Diff.execute(@source_info, options)
            end)

          assert String.contains?(output, "FAILED: Expected minimum coverage of 100%, got 50%.")
        end
      )

    assert result == {:shutdown, 1}
  end
end

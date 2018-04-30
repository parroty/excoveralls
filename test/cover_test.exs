defmodule CoverTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias ExCoveralls.Cover

  test "module path returns relative path" do
    assert(Cover.module_path(ExCoveralls) == "lib/excoveralls.ex")
  end

  test "has_compile_info?/1 with uncompiled module raises warning and returns false" do
    assert capture_io(:stderr, fn ->
      refute Cover.has_compile_info?(Foo)
    end) =~ "[warning] skipping the module 'Elixir.Foo' because source information for the module is not available."
  end

  test "has_compile_info?/1 with missing source file raises warning and returns false" do
    assert Cover.has_compile_info?(TestMissing)

    path = Cover.module_path(TestMissing)
    backup_path = "test/fixtures/test_missing.bkp"
    on_exit({:clean_up, backup_path}, fn ->
      File.copy!(backup_path, path)
      File.rm!(backup_path)
    end)

    File.copy!(path, backup_path)
    File.rm!(path)
    refute File.exists?(path)

    assert capture_io(:stderr, fn ->
      refute Cover.has_compile_info?(TestMissing)
    end) =~ "[warning] skipping the module 'Elixir.TestMissing' because source information for the module is not available."
  end

  test "has_compile_info?/1 with existing source returns true" do
    assert Cover.has_compile_info?(TestMissing)
  end
end

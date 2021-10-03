defmodule ExCoveralls.PathReaderTest do
  use ExUnit.Case, async: false
  alias ExCoveralls.PathReader

  test "gets project base path" do
    assert(PathReader.base_path() == File.cwd!())
  end

  test "expand path" do
    assert(PathReader.expand_path("test") == File.cwd!() <> "/test")
  end

  test "use the application config when it is available" do
    Application.put_env(:excoveralls, :base_path, "/base/path")
    assert("/base/path" != File.cwd!())
    assert(PathReader.base_path() == "/base/path")
  after
    Application.delete_env(:excoveralls, :base_path)
  end
end

defmodule Chaps.PathReaderTest do
  use ExUnit.Case
  alias Chaps.PathReader

  test "gets project base path" do
    assert(PathReader.base_path == File.cwd!)
  end

  test "expand path" do
    assert(PathReader.expand_path("test") == File.cwd! <> "/test")
  end
end

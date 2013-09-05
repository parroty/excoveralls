defmodule CoverTest do
  use ExUnit.Case
  alias ExCoveralls.Cover

  test "module path returns relative path" do
    assert(Cover.module_path(ExCoveralls) == "lib/excoveralls.ex")
  end
end

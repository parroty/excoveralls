defmodule ExCoverallsTest do
  use ExUnit.Case
  import Mock

  @stats "dummy stats"

  test_with_mock "analyze travis", ExCoveralls.Travis, [execute: fn(_,_) -> end] do
    ExCoveralls.analyze(@stats, "travis", [])
    assert called ExCoveralls.Travis.execute(@stats,[])
  end

  test_with_mock "analyze local", ExCoveralls.Local, [execute: fn(_,_) -> end] do
    ExCoveralls.analyze(@stats, "local", [])
    assert called ExCoveralls.Local.execute(@stats,[])
  end

  test_with_mock "analyze general", ExCoveralls.Post, [execute: fn(_,_) -> end] do
    ExCoveralls.analyze(@stats, "post", [])
    assert called ExCoveralls.Post.execute(@stats, [])
  end

  test "analyze undefined type" do
    assert_raise RuntimeError, fn ->
      ExCoveralls.analyze(@stats, "Undefined Type", [])
    end
  end
end

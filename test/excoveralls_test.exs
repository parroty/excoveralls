defmodule ExCoverallsTest do
  use ExUnit.Case
  import Mock

  @stats "dummy stats"

  test_with_mock "analyze travis", ExCoveralls.Travis, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "travis", [])
    assert called ExCoveralls.Travis.execute(@stats,[])
  end

  test_with_mock "analyze circle", ExCoveralls.Circle, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "circle", [])
    assert called ExCoveralls.Circle.execute(@stats,[])
  end

  test_with_mock "analyze semaphore", ExCoveralls.Semaphore, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "semaphore", [])
    assert called ExCoveralls.Semaphore.execute(@stats,[])
  end

  test_with_mock "analyze drone", ExCoveralls.Drone, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "drone", [])
    assert called ExCoveralls.Drone.execute(@stats,[])
  end

  test_with_mock "analyze local", ExCoveralls.Local, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "local", [])
    assert called ExCoveralls.Local.execute(@stats,[])
  end

  test_with_mock "analyze html", ExCoveralls.Html, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "html", [])
    assert called ExCoveralls.Html.execute(@stats,[])
  end

  test_with_mock "analyze json", ExCoveralls.Json, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "json", [])
    assert called ExCoveralls.Json.execute(@stats,[])
  end

  test_with_mock "analyze general", ExCoveralls.Post, [execute: fn(_,_) -> nil end] do
    ExCoveralls.analyze(@stats, "post", [])
    assert called ExCoveralls.Post.execute(@stats, [])
  end

  test "analyze undefined type" do
    assert_raise RuntimeError, fn ->
      ExCoveralls.analyze(@stats, "Undefined Type", [])
    end
  end
end

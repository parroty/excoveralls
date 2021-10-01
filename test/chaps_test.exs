defmodule ChapsTest do
  use ExUnit.Case
  import Mock

  @stats "dummy stats"

  test_with_mock "analyze travis", Chaps.Travis, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "travis", [])
    assert called Chaps.Travis.execute(@stats,[])
  end

  test_with_mock "analyze circle", Chaps.Circle, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "circle", [])
    assert called Chaps.Circle.execute(@stats,[])
  end

  test_with_mock "analyze github", Chaps.Github, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "github", [])
    assert called Chaps.Github.execute(@stats,[])
  end

  test_with_mock "analyze gitlab", Chaps.Gitlab, execute: fn _, _ -> nil end do
    Chaps.analyze(@stats, "gitlab", [])
    assert called(Chaps.Gitlab.execute(@stats, []))
  end

  test_with_mock "analyze semaphore", Chaps.Semaphore, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "semaphore", [])
    assert called Chaps.Semaphore.execute(@stats,[])
  end

  test_with_mock "analyze drone", Chaps.Drone, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "drone", [])
    assert called Chaps.Drone.execute(@stats,[])
  end

  test_with_mock "analyze local", Chaps.Local, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "local", [])
    assert called Chaps.Local.execute(@stats,[])
  end

  test_with_mock "analyze html", Chaps.Html, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "html", [])
    assert called Chaps.Html.execute(@stats,[])
  end

  test_with_mock "analyze json", Chaps.Json, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "json", [])
    assert called Chaps.Json.execute(@stats,[])
  end

  test_with_mock "analyze general", Chaps.Post, [execute: fn(_,_) -> nil end] do
    Chaps.analyze(@stats, "post", [])
    assert called Chaps.Post.execute(@stats, [])
  end

  test "analyze undefined type" do
    assert_raise RuntimeError, fn ->
      Chaps.analyze(@stats, "Undefined Type", [])
    end
  end
end

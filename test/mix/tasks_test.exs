Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case
  import Mock

  test_with_mock "local", Mix.Task, [run: fn(_, _) -> nil end] do
    assert(Mix.Tasks.Coveralls.run([]) == ExCoveralls.Local.Mixfile)
    assert(called Mix.Task.run("test", ["--cover"]))
  end

  test_with_mock "detail", Mix.Task, [run: fn(_, _) -> nil end] do
    assert(Mix.Tasks.Coveralls.Detail.run([]) == ExCoveralls.Detail.Mixfile)
    assert(called Mix.Task.run("test", ["--cover"]))
  end

  test_with_mock "travis", Mix.Task, [run: fn(_, _) -> nil end] do
    assert(Mix.Tasks.Coveralls.Travis.run([]) == ExCoveralls.Travis.Mixfile)
    assert(called Mix.Task.run("test", ["--cover"]))
  end

  test_with_mock "post", Mix.Task, [run: fn(_, _) -> nil end] do
    assert(Mix.Tasks.Coveralls.Post.run([]) == ExCoveralls.Post.Mixfile)
    assert(called Mix.Task.run("test", ["--cover"]))
  end

end

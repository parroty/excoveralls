Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case
  import Mock

  # backup the original config
  setup do
    ExCoveralls.ConfServer.start
    {:ok, from_setup: ExCoveralls.ConfServer.get}
  end

  # restore the original config
  teardown meta do
    ExCoveralls.ConfServer.set(meta[:from_setup])
  end

  test_with_mock "local", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local"])
  end

  test_with_mock "detail", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Detail.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", detail: true])
  end

  test_with_mock "travis", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Travis.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "travis"])
  end

  test_with_mock "post", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Post.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "post"])
  end
end

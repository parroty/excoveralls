Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case
  import Mock
  import ExUnit.CaptureIO

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
    assert(ExCoveralls.ConfServer.get == [type: "local", args: []])
  end

  test "local with help option" do
    assert capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--help"])
    end) != ""
  end

  test_with_mock "detail", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Detail.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", detail: true, args: []])
  end

  test_with_mock "travis", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Travis.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "travis", args: []])
  end

  test_with_mock "post", Mix.Task, [run: fn(_, _) -> nil end] do
    org_token = System.get_env("COVERALLS_REPO_TOKEN") || ""
    org_name  = System.get_env("COVERALLS_SERVICE_NAME") || ""

    System.put_env("COVERALLS_REPO_TOKEN", "dummy_token")
    System.put_env("COVERALLS_SERVICE_NAME", "dummy_service_name")

    Mix.Tasks.Coveralls.Post.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", token: "dummy_token", service_name: "dummy_service_name", args: []])

    System.put_env("COVERALLS_REPO_TOKEN", org_token)
    System.put_env("COVERALLS_SERVICE_NAME", org_name)
  end

  test "post fails with invalid param param" do
    assert_raise ExCoveralls.InvalidOptionError, fn ->
      Mix.Tasks.Coveralls.Post.run(["aaa", "bbb"])
    end
  end

  test "extract service name by param" do
    assert Mix.Tasks.Coveralls.Post.extract_service_name([name: "local_param"]) == "local_param"
  end

  test_with_mock "extract service name by environment variable", System, [get_env: fn(_) -> "local_env" end] do
    assert Mix.Tasks.Coveralls.Post.extract_service_name([]) == "local_env"
  end

  test_with_mock "extract service name by default", System, [get_env: fn(_) -> nil end] do
    assert Mix.Tasks.Coveralls.Post.extract_service_name([]) == "local"
  end

  test "extract token by param" do
    assert Mix.Tasks.Coveralls.Post.extract_token(["param_token"]) == "param_token"
  end

  test_with_mock "extract token by environment variable", System, [get_env: fn(_) -> "token_env" end] do
    assert Mix.Tasks.Coveralls.Post.extract_token([]) == "token_env"
  end

  test_with_mock "extract token by default raise error", System, [get_env: fn(_) -> nil end] do
    assert_raise ExCoveralls.InvalidOptionError, fn ->
      Mix.Tasks.Coveralls.Post.extract_token([])
    end
  end

end

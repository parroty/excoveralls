Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case, async: false
  import Mock
  import ExUnit.CaptureIO

  # backup and restore the original config
  setup_all do
    ExCoveralls.ConfServer.start
    ExCoveralls.StatServer.start

    value = ExCoveralls.ConfServer.get
    on_exit(value, fn ->
      ExCoveralls.ConfServer.set(value)
      ExCoveralls.StatServer.stop
      :ok
    end)
    :ok
  end

  # clear the config each time
  setup do
    ExCoveralls.ConfServer.clear
    :ok
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

  test_with_mock "local with umbrella option", Mix.Task, [run: fn(_, _) -> nil end] do
    capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--umbrella"])
      assert(called Mix.Task.run("test", ["--cover"]))
      assert(ExCoveralls.ConfServer.get ==
        [type: "local", umbrella: true, sub_apps: [], args: []])
    end)
  end

  test_with_mock "detail", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Detail.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", detail: true, filter: [], args: []])
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

    args = ["-b", "branch", "-c", "committer", "-m", "message"]
    Mix.Tasks.Coveralls.Post.run(args)
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", endpoint: nil, token: "dummy_token",
              service_name: "dummy_service_name", branch: "branch",
              committer: "committer", message: "message", args: []])

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
    assert Mix.Tasks.Coveralls.Post.extract_service_name([]) == "excoveralls"
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

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
        [type: "local", umbrella: true, sub_apps: [], apps_path: nil, args: []])
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

  test_with_mock "travis --pro", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Travis.run(["--pro"])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "travis", pro: true, args: []])
  end

  test_with_mock "circle", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Circle.run([])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "circle", args: []])
  end

  test_with_mock "circle --parallel", Mix.Task, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Circle.run(["--parallel"])
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "circle", parallel: true, args: []])
  end

  test_with_mock "post with env vars", Mix.Task, [run: fn(_, _) -> nil end] do
    org_token = System.get_env("COVERALLS_REPO_TOKEN") || ""
    org_name  = System.get_env("COVERALLS_SERVICE_NAME") || ""

    System.put_env("COVERALLS_REPO_TOKEN", "dummy_token")
    System.put_env("COVERALLS_SERVICE_NAME", "dummy_service_name")

    args = ["-b", "branch", "-c", "committer", "-m", "message", "-s", "asdf"]
    Mix.Tasks.Coveralls.Post.run(args)
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", endpoint: nil, token: "dummy_token",
              service_name: "dummy_service_name", branch: "branch",
              committer: "committer", sha: "asdf", message: "message", args: []])

    System.put_env("COVERALLS_REPO_TOKEN", org_token)
    System.put_env("COVERALLS_SERVICE_NAME", org_name)
  end

  test_with_mock "post without env vars", Mix.Task, [run: fn(_, _) -> nil end] do
    org_token = System.get_env("COVERALLS_REPO_TOKEN")
    org_name  = System.get_env("COVERALLS_SERVICE_NAME")

    System.delete_env("COVERALLS_REPO_TOKEN")
    System.delete_env("COVERALLS_SERVICE_NAME")

    args = ["-t", "token"]
    Mix.Tasks.Coveralls.Post.run(args)
    assert(called Mix.Task.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", endpoint: nil, token: "token",
              service_name: "excoveralls", branch: "",
              committer: "", sha: "", message: "[no commit message]", args: []])

    if org_token != nil do
      System.put_env("COVERALLS_REPO_TOKEN", org_token)
    end
    if org_name != nil do
      System.put_env("COVERALLS_SERVICE_NAME", org_name)
    end
  end

  test "extract service name by param" do
    assert Mix.Tasks.Coveralls.Post.extract_service_name([name: "local_param"]) == "local_param"
  end

  test "extract service name by environment variable" do
    org_name = System.get_env("COVERALLS_SERVICE_NAME")
    System.put_env("COVERALLS_SERVICE_NAME", "local_env")

    assert Mix.Tasks.Coveralls.Post.extract_service_name([]) == "local_env"

    if org_name != nil do
      System.put_env("COVERALLS_SERVICE_NAME", org_name)
    else
      System.delete_env("COVERALLS_SERVICE_NAME")
    end
  end

  test "extract service name by default" do
    org_name = System.get_env("COVERALLS_SERVICE_NAME")
    System.delete_env("COVERALLS_SERVICE_NAME")

    assert Mix.Tasks.Coveralls.Post.extract_service_name([]) == "excoveralls"

    if org_name != nil do
      System.put_env("COVERALLS_SERVICE_NAME", org_name)
    end
  end

  test "extract token by param" do
    assert Mix.Tasks.Coveralls.Post.extract_token(token: "param_token") == "param_token"
  end

  test "extract token by environment variable" do
    org_name = System.get_env("COVERALLS_REPO_TOKEN")
    System.put_env("COVERALLS_REPO_TOKEN", "token_env")

    assert Mix.Tasks.Coveralls.Post.extract_token([]) == "token_env"

    if org_name != nil do
      System.put_env("COVERALLS_REPO_TOKEN", org_name)
    else
      System.delete_env("COVERALLS_REPO_TOKEN")
    end
  end

  test "extract token by default raise error" do
    org_name = System.get_env("COVERALLS_REPO_TOKEN")
    System.delete_env("COVERALLS_REPO_TOKEN")

    assert_raise ExCoveralls.InvalidOptionError, fn ->
      Mix.Tasks.Coveralls.Post.extract_token([])
    end

    if org_name != nil do
      System.put_env("COVERALLS_REPO_TOKEN", org_name)
    end
  end
end

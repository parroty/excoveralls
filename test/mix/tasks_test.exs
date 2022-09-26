Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case, async: false
  import Mock
  import ExUnit.CaptureIO
  alias Mix.Tasks.Coveralls.Runner

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

  test_with_mock "local", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", args: []])
  end

  test "local with help option" do
    assert capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--help"])
    end) != ""
  end

  test_with_mock "local with umbrella option", Runner, [run: fn(_, _) -> nil end] do
    capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--umbrella"])
      assert(called Runner.run("test", ["--cover"]))
      assert(ExCoveralls.ConfServer.get ==
        [type: "local", umbrella: true, sub_apps: [], apps_path: nil, args: []])
    end)
  end

  test_with_mock "--no-start propagates to mix task", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.run(["--no-start"])
    assert(called Runner.run("test", ["--cover", "--no-start"]))
  end

  test_with_mock "--unknown_arg withvalue", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.run(["--unknown_arg withvalue", "--second"])
    assert(called Runner.run("test", ["--cover", "--unknown_arg withvalue", "--second"]))
  end

  test_with_mock "--include remote", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.run(["--include", "remote"])
    assert(called Runner.run("test", ["--cover", "--include", "remote"]))
  end

  test_with_mock "doesn't pass through coveralls args", Runner, [run: fn(_, _) -> nil end] do
    capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--include", "remote", "-x", "--unknown", "value", "--verbose", "-u", "--filter", "x"])
      assert(called Runner.run("test", ["--cover", "--include", "remote", "-x", "--unknown", "value"]))
    end)
  end

  test_with_mock "detail", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Detail.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", detail: true, args: []])
  end

  test_with_mock "detail and filter", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Detail.run(["--filter", "x"])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "local", detail: true, filter: "x", args: []])
  end

  test_with_mock "html", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Html.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "html", args: []])
  end

  test_with_mock "json", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Json.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "json", args: []])
  end

  test_with_mock "travis", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Travis.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "travis", args: []])
  end

  test_with_mock "travis --pro", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Travis.run(["--pro"])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "travis", pro: true, args: []])
  end

  test_with_mock "circle", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Circle.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "circle", args: []])
  end

  test_with_mock "circle --parallel", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Circle.run(["--parallel"])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "circle", parallel: true, args: []])
  end

  test_with_mock "semaphore", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Semaphore.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "semaphore", args: []])
  end

  test_with_mock "github", Runner, [run: fn(_, _) -> nil end] do
    Mix.Tasks.Coveralls.Github.run([])
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get == [type: "github", args: []])
  end

  test_with_mock "gitlab", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.Gitlab.run([])
    assert(called(Runner.run("test", ["--cover"])))
    assert(ExCoveralls.ConfServer.get() == [type: "gitlab", args: []])
  end

  test_with_mock "post with env vars", Runner, [run: fn(_, _) -> nil end] do
    org_token = System.get_env("COVERALLS_REPO_TOKEN") || ""
    org_name  = System.get_env("COVERALLS_SERVICE_NAME") || ""

    System.put_env("COVERALLS_REPO_TOKEN", "dummy_token")
    System.put_env("COVERALLS_SERVICE_NAME", "dummy_service_name")

    args = ["-b", "branch", "-c", "committer", "-m", "message", "-s", "asdf", "--rootdir", "umbrella0/", "--subdir", "", "--build", "1"]
    Mix.Tasks.Coveralls.Post.run(args)
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", endpoint: nil, token: "dummy_token",
              service_name: "dummy_service_name", service_number: "1", branch: "branch",
              committer: "committer", sha: "asdf", message: "message",
              umbrella: nil, verbose: nil, parallel: nil, rootdir: "umbrella0/", subdir: "", args: []])

    System.put_env("COVERALLS_REPO_TOKEN", org_token)
    System.put_env("COVERALLS_SERVICE_NAME", org_name)
  end

  test_with_mock "post without env vars", Runner, [run: fn(_, _) -> nil end] do
    org_token = System.get_env("COVERALLS_REPO_TOKEN")
    org_name  = System.get_env("COVERALLS_SERVICE_NAME")

    System.delete_env("COVERALLS_REPO_TOKEN")
    System.delete_env("COVERALLS_SERVICE_NAME")

    args = ["-t", "token"]
    Mix.Tasks.Coveralls.Post.run(args)
    assert(called Runner.run("test", ["--cover"]))
    assert(ExCoveralls.ConfServer.get ==
             [type: "post", endpoint: nil, token: "token",
              service_name: "excoveralls", service_number: "", branch: "",
              committer: "", sha: "", message: "[no commit message]",
              umbrella: nil, verbose: nil, parallel: nil, rootdir: "", subdir: "", args: []])

    if org_token != nil do
      System.put_env("COVERALLS_REPO_TOKEN", org_token)
    end
    if org_name != nil do
      System.put_env("COVERALLS_SERVICE_NAME", org_name)
    end
  end

  test "non standard post arguments propagates to runner" do
    with_mocks([
      {
        Runner,
        [],
        [run: fn(_, _) -> nil end]
      },
      {
        ExCoveralls.Poster,
        [],
        [execute: fn(_, _) -> :ok end]
      }
    ]) do
      non_standard_args = ["--no-start", "--include integration"]
      post_args = ["--token", "token", "-s", "asdf", "--umbrella"] ++ non_standard_args

      Mix.Tasks.Coveralls.Post.run(post_args)

      assert(called Runner.run("test", ["--cover" | non_standard_args]))
      assert(ExCoveralls.ConfServer.get()[:umbrella])
    end
  end

  describe "options and arguments check for post" do
    test_with_mock "post with default switches",
      ExCoveralls.Poster, [execute: fn(_, _) -> :ok end] do
        non_standard_args = ["--non_standard"]

        post_args = [
          "--token", "a_token",
          "--sha", "asdf",
          "--name", "a_name",
          "--build", "build_num",
          "--committer", "My Name",
          "--branch", "my_branch",
          "--message", "commit message",
          "--umbrella"
        ]
        post_args_with_subdir = post_args ++ ["--subdir", "sub_dir/"] ++ non_standard_args
        Mix.Tasks.Coveralls.Post.run(post_args_with_subdir)

        excoveralls_config = ExCoveralls.ConfServer.get()

        assert(excoveralls_config[:token] == "a_token")
        assert(excoveralls_config[:sha] == "asdf")
        assert(excoveralls_config[:service_name] == "a_name")
        assert(excoveralls_config[:service_number] == "build_num")
        assert(excoveralls_config[:subdir] == "sub_dir/")
        assert(excoveralls_config[:committer] == "My Name")
        assert(excoveralls_config[:branch] == "my_branch")
        assert(excoveralls_config[:message] == "commit message")
        assert(excoveralls_config[:umbrella])
        assert(excoveralls_config[:args] == ["--non_standard"])

        post_args_with_rootdir = post_args ++ ["--rootdir", "root_dir/"] ++ non_standard_args
        Mix.Tasks.Coveralls.Post.run(post_args_with_rootdir)

        excoveralls_config = ExCoveralls.ConfServer.get()

        assert(excoveralls_config[:rootdir] == "root_dir/")
    end

    test_with_mock "subdir and rootdir options are exclusive",
      ExCoveralls.Poster, [execute: fn(_, _) -> :ok end] do

        post_args = [
          "--token", "a_token",
          "--subdir", "subdir/",
          "--rootdir", "rootdir"
        ]

        assert_raise ExCoveralls.InvalidOptionError, fn ->
          Mix.Tasks.Coveralls.Post.run(post_args)
        end
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

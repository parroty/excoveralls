Code.require_file("../../test_helper.exs", __DIR__)

defmodule Mix.Tasks.CoverallsTest do
  use ExUnit.Case, async: false
  import Mock
  import ExUnit.CaptureIO
  alias Mix.Tasks.Coveralls.Runner

  # backup and restore the original config
  setup_all do
    Chaps.ConfServer.start()
    Chaps.StatServer.start()

    value = Chaps.ConfServer.get()

    on_exit(value, fn ->
      Chaps.ConfServer.set(value)
      Chaps.StatServer.stop()
      :ok
    end)

    :ok
  end

  # clear the config each time
  setup do
    Chaps.ConfServer.clear()
    :ok
  end

  test_with_mock "local", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.run([])
    assert(called(Runner.run("test", ["--cover"])))
    assert(Chaps.ConfServer.get() == [type: "local", args: []])
  end

  test "local with help option" do
    assert capture_io(fn ->
             Mix.Tasks.Coveralls.run(["--help"])
           end) != ""
  end

  test_with_mock "local with umbrella option", Runner, run: fn _, _ -> nil end do
    capture_io(fn ->
      Mix.Tasks.Coveralls.run(["--umbrella"])
      assert(called(Runner.run("test", ["--cover"])))

      assert(
        Chaps.ConfServer.get() ==
          [
            type: "local",
            umbrella: true,
            sub_apps: [],
            apps_path: nil,
            args: []
          ]
      )
    end)
  end

  test_with_mock "--no-start propagates to mix task", Runner,
    run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.run(["--no-start"])
    assert(called(Runner.run("test", ["--cover", "--no-start"])))
  end

  test_with_mock "--unknown_arg withvalue", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.run(["--unknown_arg withvalue", "--second"])

    assert(
      called(
        Runner.run("test", ["--cover", "--unknown_arg withvalue", "--second"])
      )
    )
  end

  test_with_mock "--include remote", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.run(["--include", "remote"])
    assert(called(Runner.run("test", ["--cover", "--include", "remote"])))
  end

  test_with_mock "doesn't pass through coveralls args", Runner,
    run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.run([
      "--include",
      "remote",
      "-x",
      "--unknown",
      "value",
      "--verbose",
      "-u",
      "--filter",
      "x"
    ])

    assert(
      called(
        Runner.run("test", [
          "--cover",
          "--include",
          "remote",
          "-x",
          "--unknown",
          "value"
        ])
      )
    )
  end

  test_with_mock "detail", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.Detail.run([])
    assert(called(Runner.run("test", ["--cover"])))
    assert(Chaps.ConfServer.get() == [type: "local", detail: true, args: []])
  end

  test_with_mock "detail and filter", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.Detail.run(["--filter", "x"])
    assert(called(Runner.run("test", ["--cover"])))

    assert(
      Chaps.ConfServer.get() == [
        type: "local",
        detail: true,
        filter: "x",
        args: []
      ]
    )
  end

  test_with_mock "html", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.Html.run([])
    assert(called(Runner.run("test", ["--cover"])))
    assert(Chaps.ConfServer.get() == [type: "html", args: []])
  end

  test_with_mock "json", Runner, run: fn _, _ -> nil end do
    Mix.Tasks.Coveralls.Json.run([])
    assert(called(Runner.run("test", ["--cover"])))
    assert(Chaps.ConfServer.get() == [type: "json", args: []])
  end

  describe "get_stats/2" do
    @test_path_1 "apps/umbrella1_app1/lib/umbrella1_app1.ex"
    @test_path_2 "apps/umbrella1_app2/lib/umbrella1_app2.ex"
    @test_stats [
      %{
        coverage: [],
        name: @test_path_1,
        source: "dummy_source2"
      },
      %{
        coverage: [],
        name: @test_path_2,
        source: "dummy_source1"
      }
    ]

    test "subdir is added to filepath" do
      result =
        Mix.Tasks.Coveralls.get_stats(@test_stats,
          rootdir: "",
          subdir: "umbrella1/"
        )
        |> Enum.map(fn m ->
          assert String.starts_with?(m[:name], "umbrella1/")
        end)
        |> Enum.all?(fn v -> v end)

      assert result
    end

    test "rootdir is removed from filepath" do
      result =
        Mix.Tasks.Coveralls.get_stats(@test_stats, rootdir: "apps/", subdir: "")
        |> Enum.map(fn m ->
          assert String.starts_with?(m[:name], "umbrella1_app")
        end)
        |> Enum.all?(fn v -> v end)

      assert result
    end

    test "filepath is untouched when no options for rootdir/subdir" do
      result =
        Mix.Tasks.Coveralls.get_stats(@test_stats, rootdir: "", subdir: "")
        |> Enum.map(fn m ->
          assert String.starts_with?(m[:name], "apps/umbrella1_app")
        end)
        |> Enum.all?(fn v -> v end)

      assert result
    end

    test "filepath is untouched when options for rootdir/subdir does not exist" do
      result =
        Mix.Tasks.Coveralls.get_stats(@test_stats, [])
        |> Enum.map(fn m ->
          assert String.starts_with?(m[:name], "apps/umbrella1_app")
        end)
        |> Enum.all?(fn v -> v end)

      assert result
    end
  end
end

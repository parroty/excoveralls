defmodule ExCoveralls.DroneTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Drone

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  setup do
    # Capture existing values
    orig_vars = ~w(DRONE_PULL_REQUEST DRONE_COMMIT_MESSAGE DRONE_COMMIT_AUTHOR DRONE_COMMIT_SHA DRONE_BRANCH DRONE_BUILD_NUMBER COVERALLS_REPO_TOKEN)
    |> Enum.map(fn var -> {var, System.get_env(var)} end)

    on_exit fn ->
      # Reset env vars
      for {k, v} <- orig_vars do
        if v != nil do
          System.put_env(k, v)
        else
          System.delete_env(k)
        end
      end
    end

    # No additional context
    {:ok, []}
  end

  test_with_mock "execute", ExCoveralls.Poster, [execute: fn(_) -> "result" end] do
    assert(Drone.execute(@source_info,[]) == "result")
  end

  test "generate json for drone" do
    json = Drone.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/service_number/)
    assert(json =~ ~r/source_files/)
    assert(json =~ ~r/git/)
  end

  test "generate from env vars" do
    System.put_env("DRONE_BRANCH", "branch")
    System.put_env("DRONE_PULL_REQUEST", "39")
    System.put_env("DRONE_COMMIT_MESSAGE", "Initial commit")
    System.put_env("DRONE_COMMIT_AUTHOR", "username")
    System.put_env("DRONE_COMMIT_SHA", "sha1")
    System.put_env("DRONE_BUILD_NUMBER", "0")
    System.put_env("COVERALLS_REPO_TOKEN", "token")

    {:ok, payload} = Jason.decode(Drone.generate_json(@source_info))
    %{"git" =>
      %{"branch" => branch,
        "head" => %{"committer_name" => committer_name,
                  "id" => id}}} = payload
    
    assert(payload["service_pull_request"] == "39")
    assert(branch == "branch")
    assert(id == "sha1")
    assert(committer_name == "username")
    assert(payload["service_number"] == "0")
    assert(payload["repo_token"] == "token")
  end

  test "submits as `drone`" do
    parsed = Drone.generate_json(@source_info) |> Jason.decode!
    assert(%{ "service_name" => "drone" } = parsed)
  end
end

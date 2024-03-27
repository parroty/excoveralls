defmodule ExCoveralls.SemaphoreTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Semaphore

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts,
                  warnings: []
               }]

  setup do
    # Capture existing values
    orig_vars =
      ~w(SEMAPHORE_GIT_PR_NUMBER SEMAPHORE_GIT_SHA SEMAPHORE_GIT_BRANCH SEMAPHORE_JOB_ID COVERALLS_REPO_TOKEN)
      |> Enum.map(fn var -> {var, System.get_env(var)} end)

    on_exit(fn ->
      # Reset env vars
      for {k, v} <- orig_vars do
        if v != nil do
          System.put_env(k, v)
        else
          System.delete_env(k)
        end
      end
    end)

    # No additional context
    {:ok, []}
  end

  test_with_mock "execute", ExCoveralls.Poster, execute: fn _ -> "result" end do
    assert(Semaphore.execute(@source_info, []) == "result")
  end

  test "generate json for semaphore" do
    json = Semaphore.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/service_number/)
    assert(json =~ ~r/source_files/)
    assert(json =~ ~r/git/)
  end

  test "submits as `semaphore-ci` by default" do
    parsed = Semaphore.generate_json(@source_info) |> Jason.decode!()
    assert(%{"service_name" => "semaphore"} = parsed)
  end

  test "generate from env vars" do
    System.put_env("SEMAPHORE_GIT_PR_NUMBER", "39")
    System.put_env("SEMAPHORE_GIT_SHA", "sha1")
    System.put_env("SEMAPHORE_GIT_BRANCH", "branch")
    System.put_env("SEMAPHORE_JOB_ID", "0")
    System.put_env("COVERALLS_REPO_TOKEN", "token")

    {:ok, payload} = Jason.decode(Semaphore.generate_json(@source_info))
    %{"git" => %{"branch" => branch, "head" => %{"id" => id}}} = payload

    assert(payload["service_pull_request"] == "39")
    assert(branch == "branch")
    assert(id == "sha1")
    assert(payload["service_number"] == "0")
    assert(payload["repo_token"] == "token")
  end
end

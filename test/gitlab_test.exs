defmodule ExCoveralls.GitlabTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Gitlab

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex", source: @content, coverage: @counts}]

  setup do
    # Capture existing values
    orig_vars =
      ~w(CI_MERGE_REQUEST_ID CI_EXTERNAL_PULL_REQUEST_IID CI_COMMIT_TITLE CI_COMMIT_SHA CI_COMMIT_BRANCH CI_JOB_ID CI_NODE_INDEX CI_PIPELINE_ID COVERALLS_REPO_TOKEN)
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
    assert(Gitlab.execute(@source_info, []) == "result")
  end

  test "generate json for gitlab" do
    json = Gitlab.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/service_number/)
    assert(json =~ ~r/source_files/)
    assert(json =~ ~r/git/)
  end

  test "submits as `gitlab-ci` by default" do
    parsed = Gitlab.generate_json(@source_info) |> Jason.decode!()
    assert(%{"service_name" => "gitlab-ci"} = parsed)
  end

  test "generate from env vars" do
    System.put_env("CI_EXTERNAL_PULL_REQUEST_IID", "39")
    System.put_env("CI_COMMIT_TITLE", "This is the title")
    System.put_env("CI_COMMIT_SHA", "sha1")
    System.put_env("CI_COMMIT_BRANCH", "branch")
    System.put_env("CI_PIPELINE_ID", "0")
    System.put_env("COVERALLS_REPO_TOKEN", "token")

    {:ok, payload} = Jason.decode(Gitlab.generate_json(@source_info))

    %{"git" => %{"branch" => branch, "head" => %{"message" => message, "id" => id}}} = payload

    assert payload["service_pull_request"] == "39"
    assert branch == "branch"
    assert id == "sha1"
    assert message == "This is the title"
    assert payload["service_number"] == "0"
    assert payload["repo_token"] == "token"
  end
end

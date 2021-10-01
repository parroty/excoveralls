defmodule Chaps.GithubTest do
  use ExUnit.Case, async: false
  import Mock
  alias Chaps.Github

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [
    %{name: "test/fixtures/test.ex", source: @content, coverage: @counts}
  ]
  setup do
    # No additional context
    github_event_path = System.get_env("GITHUB_EVENT_PATH")
    github_sha = System.get_env("GITHUB_SHA")
    github_event_name = System.get_env("GITHUB_EVENT_NAME")
    github_ref = System.get_env("GITHUB_REF")
    github_token = System.get_env("GITHUB_TOKEN")

    System.put_env("GITHUB_EVENT_PATH", "test/fixtures/github_event.json")
    System.put_env("GITHUB_SHA", "sha1")
    System.put_env("GITHUB_EVENT_NAME", "pull_request")
    System.put_env("GITHUB_REF", "branch")
    System.put_env("GITHUB_TOKEN", "token")

    on_exit(fn ->
      recover_env("GITHUB_EVENT_PATH", github_event_path)
      recover_env("GITHUB_SHA", github_sha)
      recover_env("GITHUB_EVENT_NAME", github_event_name)
      recover_env("GITHUB_REF", github_ref)
      recover_env("GITHUB_TOKEN", github_token)
    end)

    {:ok, []}
  end

  defp recover_env(key, value) do
    if value != nil do
      System.put_env(key, value)
    else
      System.delete_env(key)
    end
  end

  test_with_mock "execute", Chaps.Poster, execute: fn _ -> "result" end do
    assert(Github.execute(@source_info, []) == "result")
  end

  test "when is not a pull request" do
    System.put_env("GITHUB_EVENT_NAME", "anything")
    {:ok, payload} = Jason.decode(Github.generate_json(@source_info))

    assert(payload["repo_token"] == "token")
    assert(payload["service_job_id"] == "sha1")
    assert(payload["service_name"] == "github")
    assert(payload["service_pull_request"] == nil)
  end

  test "generate from env vars" do
    {:ok, payload} = Jason.decode(Github.generate_json(@source_info))

    assert(payload["repo_token"] == "token")

    assert(
      payload["service_job_id"] ==
        "7c90516a3ac9f43ab6cf46ec5668b4430a3af103-PR-206"
    )

    assert(payload["service_name"] == "github")
    assert(payload["service_pull_request"] == "206")
  end
end

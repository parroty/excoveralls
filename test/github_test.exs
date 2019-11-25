defmodule ExCoveralls.GithubTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Github

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex", source: @content, coverage: @counts}]
  setup do
    # No additional context
    System.put_env("GITHUB_EVENT_PATH", "test/fixtures/github_event.json")
    System.put_env("GITHUB_SHA", "sha1")
    System.put_env("GITHUB_EVENT_NAME", "pull_request")
    System.put_env("GITHUB_REF", "branch")
    System.put_env("GITHUB_TOKEN", "token")
    {:ok, []}
  end

  test_with_mock "execute", ExCoveralls.Poster, execute: fn _ -> "result" end do
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
    assert(payload["service_job_id"] == "PR-206-7c90516")
    assert(payload["service_name"] == "github")
    assert(payload["service_pull_request"] == "206")
  end
end

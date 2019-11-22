defmodule ExCoveralls.CircleTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Circle

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts
               }]

  setup do
    # Capture existing values
    orig_vars = ~w(CI_PULL_REQUEST CIRCLE_USERNAME CIRCLE_SHA1 CIRCLE_BRANCH CIRCLE_BUILD_NUM COVERALLS_REPO_TOKEN)
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
    assert(Circle.execute(@source_info,[]) == "result")
  end

  test "generate json for circle" do
    json = Circle.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/service_number/)
    assert(json =~ ~r/source_files/)
    assert(json =~ ~r/git/)
  end

  test "submits as `circle-ci` by default" do
    parsed = Circle.generate_json(@source_info) |> Jason.decode!
    assert(%{ "service_name" => "circle-ci" } = parsed)
  end

  test "generate from env vars" do
    System.put_env("CI_PULL_REQUEST", "https://github.com/parroty/excoveralls/pull/39")
    System.put_env("CIRCLE_USERNAME", "username")
    System.put_env("CIRCLE_SHA1", "sha1")
    System.put_env("CIRCLE_BRANCH", "branch")
    System.put_env("CIRCLE_BUILD_NUM", "0")
    System.put_env("COVERALLS_REPO_TOKEN", "token")

    {:ok, payload} = Jason.decode(Circle.generate_json(@source_info))
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

end

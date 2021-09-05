defmodule ExCoveralls.TravisTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Travis

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               }]

  test_with_mock "execute", ExCoveralls.Poster, [execute: fn(_) -> "result" end] do
    assert(Travis.execute(@source_info,[]) == "result")
  end

  test "generate json for travis" do
    json = Travis.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/source_files/)
  end

  test "generate from env vars" do
    System.put_env("TRAVIS_BRANCH", "branch")
    {:ok, payload} = Jason.decode(Travis.generate_json(@source_info))
    %{"git" =>
      %{"branch" => branch}
    } = payload
    assert(branch == "branch")
  end

  test "submits as `travis-ci` by default" do
    parsed = Travis.generate_json(@source_info) |> Jason.decode!
    assert(%{ "service_name" => "travis-ci" } = parsed)
  end

  test "can be overridden to submit as `travis-pro`" do
    parsed = Travis.generate_json(@source_info, %{ pro: true, another_key: 3 }) |> Jason.decode!
    assert(%{ "service_name" => "travis-pro" } = parsed)
    assert("repo_token" in Map.keys(parsed))
  end
end

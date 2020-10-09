defmodule ExCoveralls.CirrusTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Cirrus

  @content "defmodule Test do\n  def test do\n  end\nend\n"
  @counts [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex", source: @content, coverage: @counts}]

  setup do
    # Capture existing values
    orig_vars =
      ~w(CIRRUS_BRANCH CIRRUS_BUILD_ID CIRRUS_CHANGE_IN_REPO CIRRUS_CHANGE_MESSAGE COVERALLS_REPO_TOKEN)
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
    assert(Cirrus.execute(@source_info, []) == "result")
  end

  test "generate json for cirrus" do
    json = Cirrus.generate_json(@source_info)
    assert(json =~ ~r/service_job_id/)
    assert(json =~ ~r/service_name/)
    assert(json =~ ~r/source_files/)
    assert(json =~ ~r/git/)
  end

  test "generate from env vars" do
    System.put_env("CIRRUS_BRANCH", "branch")
    System.put_env("CIRRUS_BUILD_ID", "id")
    System.put_env("CIRRUS_CHANGE_MESSAGE", "Initial commit")
    System.put_env("CIRRUS_CHANGE_IN_REPO", "sha1")
    System.put_env("COVERALLS_REPO_TOKEN", "token")

    {:ok, payload} = Jason.decode(Cirrus.generate_json(@source_info))
    %{"git" => %{"branch" => branch, "head" => %{"message" => message, "id" => id}}} = payload

    assert(branch == "branch")
    assert(id == "sha1")
    assert(message == "Initial commit")
    assert(payload["service_job_id"] == "id")
    assert(payload["repo_token"] == "token")
  end

  test "submits as `cirrus`" do
    parsed = Cirrus.generate_json(@source_info) |> Jason.decode!()
    assert(%{"service_name" => "cirrus"} = parsed)
  end
end

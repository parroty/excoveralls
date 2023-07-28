defmodule ExCoveralls.PostTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Post

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source_info [%{name: "test/fixtures/test.ex",
                  source: @content,
                  coverage: @counts
               }]

  test_with_mock "execute", ExCoveralls.Poster, [execute: fn(_, _) -> "result" end] do
    original_token = System.get_env("COVERALLS_REPO_TOKEN")
    System.put_env("COVERALLS_REPO_TOKEN", "dummy_token")

    assert(Post.execute(@source_info, []) == "result")

    if original_token != nil do
      System.put_env("COVERALLS_REPO_TOKEN", original_token)
    end
  end

  test "generate json" do
    json =
      Post.generate_json(@source_info, [
        token: "1234567890",
        service_name: "local",
        service_number: "build_num_1",
        branch: "",
        committer: "",
        message: "",
        sha: "",
        flagname: "arbitrary_value"
      ])

    assert Jason.decode!(json) == %{
      "flag_name" => "arbitrary_value",
      "git" => %{
        "branch" => "",
        "head" => %{"committer_name" => "", "id" => "", "message" => ""}
      },
      "parallel" => nil,
      "repo_token" => "1234567890",
      "service_name" => "local",
      "service_number" => "build_num_1",
      "source_files" => [
        %{
          "coverage" => [0, 1, nil, nil],
          "name" => "test/fixtures/test.ex",
          "source" => "defmodule Test do\n  def test do\n  end\nend\n"
        }
      ]
    }
  end
end

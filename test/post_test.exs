defmodule ExCoveralls.PostTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Post
  alias ExCoveralls.Utils

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source      "test/fixtures/test.ex"
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test_with_mock "execute", ExCoveralls.Poster, [execute: fn(_) -> "result" end] do
    original_token = System.get_env("COVERALLS_REPO_TOKEN")
    System.put_env("COVERALLS_REPO_TOKEN", "dummy_token")

    assert(Post.execute(@source_info) == "result")

    if original_token != nil do
      System.put_env("COVERALLS_REPO_TOKEN", original_token)
    end
  end

  test_with_mock "generate json", System, [get_env:
      fn(x) -> case x do
           "COVERALLS_SERVICE_NAME" -> "local"
           "COVERALLS_REPO_TOKEN" -> "1234567890"
         end
      end, cmd: fn(_) -> "" end] do

    assert(Post.generate_json(@source_info) ==
       "{\"repo_token\":\"1234567890\"," <>
         "\"service_name\":\"local\"," <>
         "\"source_files\":" <>
           "[{\"name\":\"test/fixtures/test.ex\"," <>
             "\"source\":\"defmodule Test do\\n  def test do\\n  end\\nend\\n\"," <>
             "\"coverage\":[0,1,null,null]}]}")
  end

  test_with_mock "service name returns env", System, [get_env: fn(_) -> "servicename" end] do
    assert(Post.service_name == "servicename")
  end

  test_with_mock "service name returns default if env not set", System, [get_env: fn(_) -> nil end] do
    assert(Post.service_name == "local")
  end

  test_with_mock "repo token returns env", System, [get_env: fn(_) -> "token" end] do
    assert(Post.get_repo_token == "token")
  end

  test_with_mock "repo token raise exception if env not set", System, [get_env: fn(_) -> nil end] do
    assert_raise RuntimeError, fn ->
      Post.get_repo_token
    end
  end

end


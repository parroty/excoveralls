defmodule ExCoveralls.GeneratorTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.General
  alias ExCoveralls.Utils

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source      "test/fixtures/test.ex"
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test_with_mock "generate json", System, [get_env:
      fn(x) -> case x do
           "EXCOVERALLS_SERVICE_NAME" -> "local"
           "COVERALLS_REPO_TOKEN" -> "1234567890"
         end
      end] do

    assert(General.execute(@source_info) ==
       "{\"repo_token\":\"1234567890\"," <>
         "\"service_name\":\"local\"," <>
         "\"source_files\":" <>
           "[{\"name\":\"test\\/fixtures\\/test.ex\"," <>
             "\"source\":\"defmodule Test do\\n  def test do\\n  end\\nend\\n\"," <>
             "\"coverage\":[0,1,null,null]}]}")
  end
end


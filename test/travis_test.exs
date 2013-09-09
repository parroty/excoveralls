defmodule ExCoveralls.TravisTest do
  use ExUnit.Case
  import Mock
  alias ExCoveralls.Travis

  @content     "defmodule Test do\n  def test do\n  end\nend\n"
  @counts      [0, 1, nil, nil]
  @source      "test/fixtures/test.ex"
  @source_info [[name: "test/fixtures/test.ex",
                 source: @content,
                 coverage: @counts
               ]]

  test_with_mock "execute", ExCoveralls.Poster, [execute: fn(_) -> "result" end] do
    assert(Travis.execute(@source_info) == "result")
  end

  test "generate json for travis" do
    json = Travis.generate_json(@source_info)
    assert(json =~ %r/service_job_id/)
    assert(json =~ %r/service_name/)
    assert(json =~ %r/source_files/)
  end

end


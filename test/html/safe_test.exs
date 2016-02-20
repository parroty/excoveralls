defmodule ExCoveralls.Html.SafeTest do
  use ExUnit.Case

  alias ExCoveralls.Html.Safe

  test "escapes characters" do
    escaped = Safe.html_escape("<>&\"'")
    assert(escaped == "&lt;&gt;&amp;&quot;&#39;")
  end
end

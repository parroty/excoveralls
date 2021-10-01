defmodule Chaps.Html.SafeTest do
  use ExUnit.Case

  alias Chaps.Html.Safe

  test "escapes characters" do
    escaped = Safe.html_escape("<>&\"'")
    assert(escaped == "&lt;&gt;&amp;&quot;&#39;")
  end
end

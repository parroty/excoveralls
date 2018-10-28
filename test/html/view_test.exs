defmodule ExCoveralls.Html.ViewTest do
  use ExUnit.Case

  alias ExCoveralls.Html.View

  @path "lib/templates/html/htmlcov/"
  @template "coverage.html.eex"

  test "#template_path" do
    path = View.PathHelper.template_path(@template)
    assert(path == Path.expand(@template, @path))
  end

  test "#partial" do
    partial = View.partial("_style.html.eex")
    assert(partial =~ ~r/<style>.+<\/style>/s)
  end

  test "#safe" do
    safe = View.safe("<span>Safe</span>")
    assert(safe == "&lt;span&gt;Safe&lt;/span&gt;")
  end

  test "#coverage_class" do
    [h,m,l,t,n] = [View.coverage_class(75),
                   View.coverage_class(50),
                   View.coverage_class(25),
                   View.coverage_class(0),
                   View.coverage_class(0, 0)]

    assert(h == "high")
    assert(m == "medium")
    assert(l == "low")
    assert(t == "terrible")
    assert(n == "none")
  end
end

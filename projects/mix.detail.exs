defmodule ExCoveralls.Detail.Mixfile do
  use Mix.Project

  def project do
    Keyword.merge(Mix.project, [test_coverage: [tool: ExCoveralls, type: "local", detail: true]])
  end
end

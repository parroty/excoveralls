defmodule ExCoveralls.Travis.Mixfile do
  use Mix.Project

  def project do
    Keyword.merge(Mix.project, [test_coverage: [tool: ExCoveralls, type: "travis"]])
  end
end

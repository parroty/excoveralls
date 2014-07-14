defmodule ExCoveralls.Mixfile do
  use Mix.Project

  def project do
    [ app: :excoveralls,
      version: "0.3.0",
      elixir: "~> 0.14.0",
      deps: deps(Mix.env),
      description: description,
      package: package,
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps(:test) do
    deps(:dev)
  end

  def deps(:dev) do
    deps(:prod) ++
      [ {:mock, github: "parroty/mock", ref: "version" } ]
  end

  def deps(:prod) do
    [ {:jsex, "~> 2.0"} ]
  end

  defp description do
    """
    Coverage report tool for Elixir with coveralls.io integration.
    """
  end

  defp package do
    [ contributors: ["parroty"],
      license: ["MIT"],
      links: [ { "GitHub", "https://github.com/parroty/excoveralls" } ] ]
  end
end

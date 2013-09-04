defmodule ExCoveralls.Mixfile do
  use Mix.Project

  def project do
    [ app: :excoveralls,
      version: "0.0.1",
      elixir: "~> 0.10.3-dev",
      deps: deps,
      env: [
        coveralls: [test_coverage: test_coveralls]
      ]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:json, github: "cblage/elixir-json"},
      {:mock, ">= 0.0.3", github: "parroty/mock"}
    ]
  end

  ## Returns the option for coveralls module
  defp test_coveralls do
    [output: "ebin", tool: ExCoveralls]
  end
end

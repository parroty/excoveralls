defmodule ExCoveralls.Mixfile do
  use Mix.Project

  def project do
    [ app: :excoveralls,
      version: "0.1.5",
      elixir: "~> 0.10.3-dev",
      deps: deps(Mix.env)
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
      [
        {:mock, ">= 0.0.3", github: "parroty/mock"}
      ]
  end

  def deps(:prod) do
    [
      {:jsex, github: "parroty/jsex", branch: "fix"},
      {:exprintf, github: "parroty/exprintf"}
    ]
  end
end

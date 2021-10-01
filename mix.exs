defmodule Chaps.Mixfile do
  use Mix.Project

  @source_url "https://github.com/parroty/chaps"

  def project do
    [
      app: :chaps,
      version: "0.14.2",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      test_coverage: [tool: Chaps],
      preferred_cli_env:
        cli_env_for(:test, [
          "chaps",
          "chaps.detail",
          "chaps.html",
          "chaps.json"
        ])
    ]
  end

  defp cli_env_for(env, tasks) do
    Enum.reduce(tasks, [], &Keyword.put(&2, String.to_atom(&1), env))
  end

  def application do
    [extra_applications: [:eex, :tools]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fixtures/test_missing.ex"]
  defp elixirc_paths(_), do: ["lib"]

  def deps do
    [
      {:jason, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:meck, "~> 0.8", only: :test},
      {:mock, "~> 0.3.6", only: :test}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      assets: "assets",
      extras: ["README.md", "CHANGELOG.md": [title: "Changelog"]]
    ]
  end

  defp description do
    """
    Coverage report tool for Elixir with coveralls.io integration.
    """
  end

  defp package do
    [
      maintainers: ["parroty"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => @source_url <> "/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end
end

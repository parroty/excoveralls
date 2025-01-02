defmodule Chaps.Mixfile do
  use Mix.Project

  @source_url "https://github.com/NFIBrokerage/chaps"
  @version_file Path.join(__DIR__, ".version")
  @external_resource @version_file
  @version (case Regex.run(~r/^v([\d\.\w-]+)/, File.read!(@version_file),
                   capture: :all_but_first
                 ) do
              [version] -> version
              nil -> "0.0.0"
            end)

  def project do
    [
      app: :chaps,
      version: @version,
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
      {:nimble_options, "~> 1.0"},
      {:jason, "~> 1.0", optional: true},
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
    100% code coverage testing tool forked from parroty/excoveralls
    """
  end

  defp package do
    [
      maintainers: ["mike-davis"],
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README.md .version LICENSE),
      links: %{
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end
end

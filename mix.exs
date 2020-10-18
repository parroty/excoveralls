defmodule ExCoveralls.Mixfile do
  use Mix.Project

  def project do
    [ app: :excoveralls,
      version: "0.13.3",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: cli_env_for(:test, [
        "coveralls", "coveralls.detail", "coveralls.html", "coveralls.json", "coveralls.post",
      ])
    ]
  end

  defp cli_env_for(env, tasks) do
    Enum.reduce(tasks, [], fn(key, acc) -> Keyword.put(acc, :"#{key}", env) end)
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:eex, :tools]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/fixtures/test_missing.ex"]
  defp elixirc_paths(_), do: ["lib"]

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:mock, "~> 0.2", only: :test},
      {:meck, "~> 0.8", only: :test},
      {:jason, "~> 1.0"},
      {:hackney, "~> 1.16"},
      {:ex_doc, "~> 0.21.0", only: :dev}
    ]
  end

  defp description do
    """
    Coverage report tool for Elixir with coveralls.io integration.
    """
  end

  defp package do
    [ maintainers: ["parroty"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/parroty/excoveralls"} ]
  end
end

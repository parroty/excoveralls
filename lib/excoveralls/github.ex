defmodule ExCoveralls.Github do
  @moduledoc """
  Handles GitHub Actions integration with coveralls.
  """
  alias ExCoveralls.Poster

  def execute(stats, options) do
    json = generate_json(stats, Enum.into(options, %{}))

    if options[:verbose] do
      IO.puts(json)
    end

    Poster.execute(json)
  end

  def generate_json(stats, _options \\ %{}) do
    Jason.encode!(%{
      source_files: stats,
      service_name: "github",
      repo_token: get_repo_token(),
      # parallel: true?,
      git: %{
        id: get_sha(),
        branch: get_branch()
      },
      service_job_id: get_job_id()
    })
    |> IO.inspect(label: "posting this JSON")
  end

  defp get_job_id do
    System.get_env("TRAVIS_JOB_ID") # << -- what to replace this with?
  end

  defp get_repo_token do
    case System.get_env("COVERALLS_REPO_TOKEN") do
      nil ->
        raise RuntimeError,
              "The Coveralls `repo_token` must be provided in an environment variable named `COVERALLS_REPO_TOKEN`."

      token ->
        token
    end
  end

  defp get_sha do
    System.get_env("GITHUB_SHA")
  end

  defp get_branch do
    # System.get_env("TRAVIS_BRANCH") # << -- what to replace this with?
    System.get_env("GITHUB_REF")
    # NOTE: I don't think this is the desired result.
    # This appears to be the *target* branch in a pull request,
    # not the branch being merged in.
  end
end

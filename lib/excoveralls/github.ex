defmodule ExCoveralls.GitHub do
  @moduledoc """
  Handles GitHub Actions integration with coveralls.
  """
  alias ExCoveralls.Poster

  def execute(stats, options) do
    json = generate_json(stats, Enum.into(options, %{}))
    if options[:verbose] do
      IO.puts json
    end
    Poster.execute(json)
  end

  def generate_json(stats, _options \\ %{}) do
    Jason.encode!(%{
      service_job_id: get_job_id(),
      service_name: "github-actions",
      source_files: stats,
      git: generate_git_info()
    })
  end

  defp get_job_id do
    System.get_env("TRAVIS_JOB_ID") # << -- what to replace this with?
  end

  defp get_repo_token do
    System.get_env("COVERALLS_REPO_TOKEN") # << -- from secrets instead?
  end

  defp get_branch do
    {branch, 0} = System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])
    String.trim(branch)
  end

  defp generate_git_info do
    %{branch: get_branch()}
  end
end

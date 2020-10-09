defmodule ExCoveralls.Cirrus do
  @moduledoc """
  Handles cirrus-ci integration with coveralls.
  """
  alias ExCoveralls.Poster

  def execute(stats, options) do
    json = generate_json(stats, Enum.into(options, %{}))
    if options[:verbose] do
      IO.puts json
    end
    Poster.execute(json)
  end

  def generate_json(stats, options \\ %{})
  def generate_json(stats, _options) do
    Jason.encode!(%{
      service_job_id: get_job_id(),
      service_name: "cirrus",
      repo_token: get_repo_token(),
      source_files: stats,
      git: generate_git_info()
    })
  end

  defp generate_git_info do
    %{head: %{
       message: get_message(),
       id: get_sha()
      },
      branch: get_branch()
    }
  end

  defp get_branch do
    System.get_env("CIRRUS_BRANCH")
  end

  defp get_job_id do
    System.get_env("CIRRUS_BUILD_ID")
  end

  defp get_sha do
    System.get_env("CIRRUS_CHANGE_IN_REPO")
  end

  defp get_message do
    System.get_env("CIRRUS_CHANGE_MESSAGE")
  end

  defp get_repo_token do
    System.get_env("COVERALLS_REPO_TOKEN")
  end
end

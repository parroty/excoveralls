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

  def generate_json(stats, options \\ %{})

  def generate_json(stats, _options) do
    Jason.encode!(%{
      git: git_info(),
      repo_token: get_env("COVERALLS_REPO_TOKEN"),
      service_job_id: job_data().job_id,
      service_name: "github",
      service_pull_request: job_data().pr,
      source_files: stats
    })
  end
  
  defp get_env(env) do
    env
    |> System.get_env
  end

  defp job_data() do
    get_env("GITHUB_EVENT_NAME")
    |> case do
      "pull_request" ->
        %{pr: get_pr_id(), job_id: "#{get_env("GITHUB_SHA")}-PR-#{get_pr_id()}"}
      _ ->
        %{pr: nil, job_id: get_env("GITHUB_SHA")}
    end
  end

  defp get_pr_id do
    get_env("GITHUB_EVENT_PATH")
    |> File.read!()
    |> Jason.decode!()
    |> Map.get("number")
    |> Integer.to_string
  end


  defp git_info do
    %{
      head: %{
        id: get_env("GITHUB_SHA"),
      },
      branch: get_env("GITHUB_REF")
    }
  end
end

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

  def generate_json(stats, options) do
    %{
      repo_token: System.get_env("GITHUB_TOKEN"),
      service_name: "github",
      source_files: stats,
      parallel: options[:parallel],
      git: git_info()
    }
    |> Map.merge(job_data())
    |> Jason.encode!()
  end

  defp job_data() do
    case System.get_env("GITHUB_EVENT_NAME") do
      "pull_request" ->
        pr_sha =
          get_sha("pull_request")
          |> sha_resume()

        %{
          service_pull_request: get_pr_id(),
          service_job_id: "PR-#{get_pr_id()}-#{pr_sha}"
        }

      event ->
        sha =
          get_sha(event)
          |> sha_resume()

        %{service_job_id: sha}
    end
  end

  defp get_pr_id do
    event_info()
    |> get_in(["number"])
    |> Integer.to_string()
  end

  defp get_committer_name do
    event_info()
    |> get_in(["sender", "login"])
  end

  defp get_sha("pull_request") do
    event_info()
    |> get_in(["pull_request", "head", "sha"])
  end

  defp get_sha(_) do
    System.get_env("GITHUB_SHA")
  end

  defp get_message("pull_request") do
    {message, _} = System.cmd("git", ["log", get_sha("pull_request"), "-1", "--pretty=format:%s"])
    message
  end

  defp get_message(_) do
    {message, _} = System.cmd("git", ["log", "-1", "--pretty=format:%s"])
    message
  end

  defp event_info do
    System.get_env("GITHUB_EVENT_PATH")
    |> File.read!()
    |> Jason.decode!()
  end

  defp git_info do
    event = System.get_env("GITHUB_EVENT_NAME")

    %{
      head: %{
        id: get_sha(event),
        committer_name: get_committer_name(),
        message: get_message(event)
      },
      branch: get_branch()
    }
  end

  defp sha_resume(sha) do
    sha
    |> String.slice(0..6)
  end

  defp get_branch do
    System.get_env("GITHUB_REF")
  end
end

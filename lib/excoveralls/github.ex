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
    Jason.encode!(%{
      repo_token: get_repo_token(),
      service_name: "github",
      service_job_id: get_job_id(),
      service_number: get_build_num(),
      service_pull_request: get_pull_request(),
      source_files: stats,
      git: generate_git_info(),
      parallel: options[:parallel]
    })
  end

  defp get_pull_request do
    System.get_env("GITHUB_EVENT_NAME")
    |> case do
      "pull_request" ->
        get_number()

      _ ->
        nil
    end
  end

  defp generate_git_info do
    %{
      head: %{
        committer_name: get_committer(),
        message: get_message!(),
        id: get_job_id()
      },
      branch: get_branch()
    }
  end

  defp get_repo_token do
    System.get_env("COVERALLS_REPO_TOKEN")
  end

  defp get_sha do
    System.get_env("GITHUB_SHA")
  end

  defp get_build_num do
    System.get_env("GITHUB_ACTION")
  end

  defp get_branch do
    "GITHUB_REF"
    |> System.get_env()
  end

  defp get_job_id do
    System.get_env("GITHUB_EVENT_NAME")
    |> case do
      "pull_request" ->
        "#{get_sha()}-PR-#{get_number()}"

      _ ->
        get_sha()
    end
  end

  defp get_message! do
    case System.cmd("git", ["log", "-1", "--pretty=format:%s"]) do
      {message, _} -> message
      _ -> "[no commit message]"
    end
  end

  defp get_committer do
    get_action()
    |> Map.fetch!("pull_request")
    |> Map.fetch!("head")
    |> Map.fetch!("user")
    |> Map.fetch!("login")
  end

  defp get_number do
    get_action()
    |> Map.fetch!("number")
    |> Integer.to_string()
  end

  defp get_action do
    "GITHUB_EVENT_PATH"
    |> System.get_env()
    |> File.read!()
    |> Jason.decode!()
  end
end

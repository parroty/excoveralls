defmodule ExCoveralls.Travis do
  @moduledoc """
  Handles travis-ci integration with coveralls.
  """
  alias ExCoveralls.Poster

  def execute(stats) do
    json = generate_json(stats)
    if options[:verbose] do
      IO.puts JSX.prettify!(json)
    end
    Poster.execute(json)
  end

  def generate_json(stats) do
    JSX.encode!([
      service_job_id: get_job_id,
      service_name: "travis-ci",
      source_files: stats
    ])
  end

  defp get_job_id do
    System.get_env("TRAVIS_JOB_ID")
  end
end

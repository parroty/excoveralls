defmodule ExCoveralls.Travis do
  @moduledoc """
  Handles travis-ci integration with coveralls.
  """
  alias ExCoveralls.Utils

  def generate_json(source_info) do
    JSON.encode!([
      service_job_id: get_job_id,
      service_name: "travis-ci",
      source_files: source_info
    ])
  end

  def get_job_id do
    System.get_env("TRAVIS_JOB_ID")
  end

end
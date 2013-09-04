defmodule ExCoveralls.Travis do
  @moduledoc """
  Handles travis-ci integration with coveralls.
  """

  def generate_json(source_info) do
    JSON.encode!([
      service_job_id: get_job_id,
      service_name: "travis-ci",
      source_files: source_info
    ])
  end

  def get_job_id do
    String.from_char_list!(:os.getenv("TRAVIS_JOB_ID"))
  end

end
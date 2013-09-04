defmodule ExCoveralls.General do
  @moduledoc """
  Handles general-purpose CI integration with coveralls.
  """
  @default_name "local"

  def generate_json(source_info) do
    JSON.encode!([
      repo_token: Cover.get_repo_token,
      service_name: service_name,
      source_files: source_info
    ])
  end

  defp service_name do
    getenv("EXCOVERALLS_SERVICE_NAME", @default_name)
  end

  def get_job_id do
    getenv("TRAVIS_JOB_ID")
  end

  defp getenv(name, default // []) do
    String.from_char_list!(:os.getenv(name) || default)
  end
end
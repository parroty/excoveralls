defmodule ExCoveralls.General do
  @moduledoc """
  Handles general-purpose CI integration with coveralls.
  """
  alias ExCoveralls.Utils
  @default_name 'local'

  def generate_json(source_info) do
    JSON.encode!([
      repo_token: get_repo_token,
      service_name: service_name,
      source_files: source_info
    ])
  end

  defp service_name do
    Utils.getenv("EXCOVERALLS_SERVICE_NAME", @default_name)
  end

  def get_repo_token do
    Utils.getenv("COVERALLS_REPO_TOKEN")
  end
end
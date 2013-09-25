defmodule ExCoveralls.Post do
  @moduledoc """
  Handles general-purpose CI integration with coveralls.
  """
  alias ExCoveralls.Utils
  alias ExCoveralls.Poster

  @default_name "local"

  def execute(stats) do
    generate_json(stats) |> Poster.execute
  end

  def generate_json(source_info) do
    JSEX.encode!([
      repo_token: get_repo_token,
      service_name: service_name,
      source_files: source_info
    ])
  end

  def service_name do
    System.get_env("COVERALLS_SERVICE_NAME") || @default_name
  end

  def get_repo_token do
    System.get_env("COVERALLS_REPO_TOKEN") || raise "COVERALLS_REPO_TOKEN is not defined."
  end
end
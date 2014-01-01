defmodule ExCoveralls.Post do
  @moduledoc """
  Handles general-purpose CI integration with coveralls.
  """
  alias ExCoveralls.Poster

  def execute(stats, options) do
    generate_json(stats, options) |> Poster.execute
  end

  def generate_json(source_info, options) do
    JSEX.encode!([
      repo_token: options[:token],
      service_name: options[:service_name],
      source_files: source_info
    ])
  end
end
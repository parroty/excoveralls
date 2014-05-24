defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover
  alias ExCoveralls.ConfServer
  alias ExCoveralls.Travis
  alias ExCoveralls.Local
  alias ExCoveralls.Post

  @type_travis  "travis"
  @type_local   "local"
  @type_post    "post"

  @doc """
  This method will be called from mix to trigger coverage analysis.
  """
  def start(compile_path, _opts) do
    Cover.compile(compile_path)
    fn() ->
      execute(ConfServer.get)
    end
  end

  defp execute(options) do
    Stats.report(Cover.modules)
      |> analyze(options[:type], options)
  end

  @doc """
  Logic for posting from travis-ci server
  """
  def analyze(stats, @type_travis, _options) do
    Travis.execute(stats)
  end

  @doc """
  Logic for local stats display, without posting server
  """
  def analyze(stats, @type_local, options) do
    Local.execute(stats, options)
  end

  @doc """
  Logic for posting from general CI server with token.
  """
  def analyze(stats, @type_post, options) do
    Post.execute(stats, options)
  end

  def analyze(_stats, _type, _options) do
    raise "Undefined type is specified for ExCoveralls"
  end
end

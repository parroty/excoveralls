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
  This method will be called from mix.
  (either run or start depending on elixir version)
  """
  def run(compile_path, _opts, callback) do
    Cover.compile(compile_path)
    callback.()
    execute(ConfServer.get)
  end

  @doc """
  This method will be called from mix.
  (either run or start depending on elixir version)
  """
  def start(compile_path, _opts) do
    Cover.compile(compile_path)
    System.at_exit fn(_) ->
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
  def analyze(stats, @type_post, _options) do
    Post.execute(stats)
  end

  def analyze(_stats, _type, _options) do
    raise "Undefined type is specified for ExCoveralls"
  end
end

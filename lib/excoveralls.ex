defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover
  alias ExCoveralls.Generator
  alias ExCoveralls.Poster

  @type_travis  "travis"
  @type_local   "local"
  @type_general "general"

  @doc """
  This method will be called from mix
  """
  def start(compile_path, options) do
    Cover.compile(compile_path)
    System.at_exit fn(_) ->
      execute(options)
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
    ExCoveralls.Travis.execute(stats)
  end

  @doc """
  Logic for local stats display, without posting server
  """
  def analyze(stats, @type_local, options) do
    ExCoveralls.Local.execute(stats, options)
  end

  @doc """
  Logic for posting from general CI server with token
  """
  def analyze(stats, @type_general, _options) do
    ExCoveralls.General.execute(stats)
  end

  def analyze(_stats, _type, _options) do
    raise "Undefined type is specified for ExCoveralls"
  end
end

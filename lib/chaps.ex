defmodule Chaps do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """

  alias Chaps.{Cover, ConfServer, StatServer, Stats}

  @type_to_output_module %{
    "local" => Chaps.Local,
    "html" => Chaps.Html,
    "json" => Chaps.Json,
    "xml" => Chaps.Xml,
    "lcov" => Chaps.Lcov
  }

  @doc """
  This method will be called from mix to trigger coverage analysis.
  """
  def start(compile_path, _opts) do
    Cover.compile(compile_path)

    fn ->
      execute(ConfServer.get(), compile_path)
    end
  end

  def execute(options, compile_path) do
    stats = Cover.modules() |> Stats.report() |> Enum.map(&Enum.into(&1, %{}))

    if options[:umbrella] do
      store_stats(stats, options, compile_path)
    else
      analyze(stats, options[:type] || "local", options)
    end
  end

  defp store_stats(stats, options, compile_path) do
    {sub_app_name, _sub_app_path} =
      Chaps.SubApps.find(options[:sub_apps], compile_path)

    stats = Stats.append_sub_app_name(stats, sub_app_name, options[:apps_path])
    Enum.each(stats, fn stat -> StatServer.add(stat) end)
  end

  @doc """
  Logic for posting
  """
  def analyze(stats, type, options) do
    module =
      Map.get(@type_to_output_module, type) ||
        raise "Undefined type (#{type}) is specified for Chaps"

    module.execute(stats, options)
  end
end

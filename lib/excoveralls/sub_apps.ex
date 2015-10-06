defmodule ExCoveralls.SubApps do
  @moduledoc """
  Handles information of sub apps of umbrella projects.
  """

  def find(sub_apps, compile_path) do
    Enum.find(sub_apps, {nil, nil}, fn({_sub_app, path}) ->
      String.starts_with?(compile_path, path)
    end)
  end

  def parse(deps) do
    Enum.map(deps, fn(dep) ->
      {dep.app, dep.opts[:build]}
    end)
  end
end
defmodule ExCoveralls.SubAppsTest do
  use ExUnit.Case
  alias ExCoveralls.SubApps

  @subapps [
    %Mix.Dep{app: :subapp0, deps: [], extra: [], from: nil, manager: :mix,
      opts: [path: "apps/subapp0",
        dest: "/Users/dummy/excoveralls/apps/subapp0",
        from_umbrella: true, env: :dev,
        build: "/Users/dummy/excoveralls/_build/dev/lib/subapp0"],
      requirement: nil, scm: Mix.SCM.Path, status: {:ok, "0.0.1"},
      top_level: false},
   %Mix.Dep{app: :subapp1, deps: [],
     opts: [path: "apps/subapp1",
       dest: "/Users/dummy/excoveralls/apps/subapp1",
       from_umbrella: true, env: :dev,
       build: "/Users/dummy/excoveralls/_build/dev/lib/subapp1"],
     requirement: nil, scm: Mix.SCM.Path, status: {:ok, "0.0.1"},
     top_level: false}
  ]

  @parsed_subapps [
      subapp1: "/Users/dummy/excoveralls/_build/dev/lib/subapp1",
      subapp0: "/Users/dummy/excoveralls/_build/dev/lib/subapp0"
  ]

  test "parse returns sub apps" do
    assert SubApps.parse(@subapps) == @parsed_subapps
  end

  test "find returns value" do
    compile_path = "/Users/dummy/excoveralls/_build/dev/lib/subapp0/ebin"
    {name, _path} = SubApps.find(@parsed_subapps, compile_path)
    assert(name == :subapp0)
  end
end

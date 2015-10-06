defmodule ExCoveralls.StatServerTest do
  use ExUnit.Case, async: false
  alias ExCoveralls.StatServer

  setup do
    StatServer.start
    on_exit fn ->
      StatServer.stop
    end
  end

  test "get returns added values" do
    StatServer.add(:key1)
    StatServer.add(:key2)

    keys = StatServer.get |> Set.to_list |> Enum.sort
    assert(keys == [:key1, :key2])
  end
end

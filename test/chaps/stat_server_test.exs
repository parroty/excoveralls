defmodule Chaps.StatServerTest do
  use ExUnit.Case, async: false
  alias Chaps.StatServer

  setup do
    StatServer.start
    on_exit fn ->
      StatServer.stop
    end
  end

  test "get returns added values" do
    StatServer.add(:key1)
    StatServer.add(:key2)

    keys = StatServer.get |> MapSet.to_list |> Enum.sort
    assert(keys == [:key1, :key2])
  end
end

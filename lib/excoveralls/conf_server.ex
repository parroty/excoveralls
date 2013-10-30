defmodule ExCoveralls.ConfServer do
  use ExActor, export: :singleton

  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)
end

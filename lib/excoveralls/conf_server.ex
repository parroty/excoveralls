defmodule ExCoveralls.ConfServer do
  use ExActor, export: :some_registered_name

  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)
end

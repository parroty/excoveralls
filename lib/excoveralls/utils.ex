defmodule ExCoveralls.Utils do
  @moduledoc """
  Provides utility methods
  """
  def getenv(name, default // []) do
    String.from_char_list!(:os.getenv(name) || default)
  end

end

defmodule ExCoveralls.Cover do
  @moduledoc """
  Wrapper class for Erlang's cover tool.
  """

  @doc """
  Compile the beam files for coverage analysis.
  """
  def compile(compile_path) do
    :cover.stop
    {:ok, pid} = :cover.start()

    # Silence analyse import messages emitted by cover
    {:ok, string_io} = StringIO.open("")
    Process.group_leader(pid, string_io)

    :cover.compile_beam_directory(compile_path |> string_to_charlist)
  end

  @doc """
  Returns the relative file path of the specified module.
  """
  def module_path(module) do
    module.module_info(:compile)[:source]
    |> List.to_string
    |> Path.relative_to(ExCoveralls.PathReader.base_path)
  end

  @doc "Wrapper for :cover.modules"
  def modules do
    :cover.modules |> Enum.filter(&has_compile_info?/1)
  end

  def import(base_path) do
    Path.wildcard("#{base_path}/*.coverdata") |> Enum.map(&to_charlist/1) |> Enum.each(&:cover.import/1)
  end

  def export(path) do
    path |> to_charlist() |>  :cover.export()
  end

  def has_compile_info?(module) do
    with info when not is_nil(info) <- module.module_info(:compile),
         path when not is_nil(path) <- Keyword.get(info, :source) do
      file_exist?(module, path)
    else
      _e ->
        log_missing_source(module)
        false
    end
  rescue
    _e ->
      log_missing_source(module)
      false
  end

  @doc "Wrapper for :cover.analyse"
  def analyze(module) do
    :cover.analyse(module, :calls, :line)
  end

  if Version.compare(System.version, "1.3.0") == :lt do
    defp string_to_charlist(string), do: String.to_char_list(string)
  else
    defp string_to_charlist(string), do: String.to_charlist(string)
  end

  defp file_exist?(module, path) do
    if File.exists?(path) do
      true
    else
      log_missing_file(module, path)
      false
    end
  end

  defp log_missing_source(module) do
    IO.puts :stderr, "[warning] skipping the module '#{module}' because source information for the module is not available."
  end

  defp log_missing_file(module, path) do
    IO.puts :stderr, "[warning] skipping the module '#{module}' because source file with '#{path}' path does not exist"
  end
end

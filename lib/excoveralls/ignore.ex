defmodule ExCoveralls.Ignore do
  @moduledoc """
  Handles comments to start/stop ignoring lines from coverage.
  """

  @doc """
  Filters out lines between start and end comment.
  """
  def filter(info) do
    Enum.map(info, &do_filter/1)
  end

  defp do_filter(%{name: name, source: source, coverage: coverage}) do
    lines = String.split(source, "\n")
    list = Enum.zip(lines, coverage)
           |> Enum.map_reduce(:no_ignore, &check_and_swap/2)
           |> elem(0)
           |> List.zip
           |> Enum.map(&Tuple.to_list(&1))

    [source, coverage] = parse_filter_list(list)
    %{name: name, source: source, coverage: coverage}
  end

  defp check_and_swap({line, coverage}, ignore) do
    {
      coverage_for_line({line, coverage}, ignore),
      ignore_next?(line, ignore)
    }
  end

  defp parse_filter_list([]),   do: ["", []]
  defp parse_filter_list([lines, coverage]), do: [Enum.join(lines, "\n"), coverage]

  defp coverage_for_line({line, coverage}, ignore) do
    if ignore == :no_ignore do
      {line, coverage}
    else
      {line, nil}
    end
  end

  defp ignore_next?(line, ignore) do
    case Regex.run(~r/coveralls-ignore-(start|stop|next-line)/, line, capture: :all_but_first) do
      ["start"] -> :ignore_block
      ["stop"] -> :no_ignore
      ["next-line"] ->
        case ignore do
          :ignore_block -> ignore
          _sth -> :ignore_line
        end
      _sth ->
        case ignore do
          :ignore_line -> :no_ignore
          _sth -> ignore
        end
    end
  end

end

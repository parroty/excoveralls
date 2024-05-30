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

  defmodule State do
    defstruct ignore_mode: :no_ignore,
              coverage: [],
              coverage_buffer: [],
              warnings: [],
              last_marker_index: nil
  end

  defp do_filter(%{name: name, source: source, coverage: coverage}) do
    source_lines = String.split(source, "\n")

    processing_result =
      Enum.zip(source_lines, coverage)
      |> Enum.with_index()
      |> Enum.reduce(%State{}, &process_line/2)
      |> process_end_of_file()

    updated_coverage = processing_result.coverage |> List.flatten() |> Enum.reverse()
    warnings = Enum.sort_by(processing_result.warnings, &elem(&1, 0))
    %{name: name, source: source, coverage: updated_coverage, warnings: warnings}
  end

  defp process_line({{source_line, coverage_line}, index}, state) do
    case detect_ignore_marker(source_line) do
      :none -> process_regular_line(coverage_line, index, state)
      :start -> process_start_marker(coverage_line, index, state)
      :stop -> process_stop_marker(coverage_line, index, state)
      :next_line -> process_next_line_marker(coverage_line, index, state)
    end
  end

  defp detect_ignore_marker(line) do
    case Regex.run(~r/coveralls-ignore-(start|stop|next-line)/, line, capture: :all_but_first) do
      ["start"] -> :start
      ["stop"] -> :stop
      ["next-line"] -> :next_line
      _sth -> :none
    end
  end

  defp process_regular_line(
         coverage_line,
         _index,
         state = %{ignore_mode: :no_ignore, coverage_buffer: []}
       ) do
    %{state | coverage: [coverage_line | state.coverage]}
  end

  defp process_regular_line(_coverage_line, _index, state = %{ignore_mode: :ignore_line}) do
    %{state | ignore_mode: :no_ignore, coverage: [nil | state.coverage]}
  end

  defp process_regular_line(_coverage_line, _index, state = %{ignore_mode: :ignore_block}) do
    %{state | coverage: [nil | state.coverage]}
  end

  defp process_start_marker(
         _coverage_line,
         index,
         state = %{ignore_mode: :no_ignore}
       ) do
    %{
      state
      | ignore_mode: :ignore_block,
        coverage: [nil | state.coverage],
        last_marker_index: index
    }
  end

  defp process_start_marker(_coverage_line, index, state = %{ignore_mode: :ignore_block}) do
    warning = {index, "unexpected ignore-start or missing previous ignore-stop"}

    %{
      state
      | coverage: [nil | state.coverage],
        warnings: [warning | state.warnings],
        last_marker_index: index
    }
  end

  defp process_start_marker(_coverage_line, index, state = %{ignore_mode: :ignore_line}) do
    warning = {state.last_marker_index, "redundant ignore-next-line right before an ignore-start"}

    %{
      state
      | ignore_mode: :ignore_block,
        coverage: [nil | state.coverage],
        warnings: [warning | state.warnings],
        last_marker_index: index
    }
  end

  defp process_stop_marker(_coverage_line, index, state = %{ignore_mode: :ignore_block}) do
    %{
      state
      | ignore_mode: :no_ignore,
        coverage: [nil | state.coverage],
        last_marker_index: index
    }
  end

  defp process_stop_marker(_coverage_line, index, state) do
    warning = {index, "unexpected ignore-stop or missing previous ignore-start"}

    %{
      state
      | ignore_mode: :no_ignore,
        coverage: [nil | state.coverage],
        warnings: [warning | state.warnings],
        last_marker_index: index
    }
  end

  defp process_next_line_marker(
         _coverage_line,
         index,
         state = %{ignore_mode: :no_ignore}
       ) do
    %{
      state
      | ignore_mode: :ignore_line,
        coverage: [nil | state.coverage],
        last_marker_index: index
    }
  end

  defp process_next_line_marker(
         _coverage_line,
         index,
         state = %{ignore_mode: :ignore_block}
       ) do
    warning = {index, "redundant ignore-next-line inside ignore block"}

    %{
      state
      | coverage: [nil | state.coverage],
        warnings: [warning | state.warnings]
    }
  end

  defp process_next_line_marker(
         _coverage_line,
         index,
         state = %{ignore_mode: :ignore_line}
       ) do
    warning = {index, "duplicated ignore-next-line"}

    %{
      state
      | coverage: [nil | state.coverage],
        warnings: [warning | state.warnings],
        last_marker_index: index
    }
  end

  defp process_end_of_file(state = %{ignore_mode: :ignore_block}) do
    warning =
      {state.last_marker_index, "ignore-start without a corresponding ignore-stop"}

    %{state | warnings: [warning | state.warnings]}
  end

  defp process_end_of_file(state), do: state
end

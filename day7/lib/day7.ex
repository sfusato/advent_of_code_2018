defmodule Day7 do
  @moduledoc """
  Documentation for Day7.
  """
  def part_1(input) do
    input
    |> parse_and_map()
    |> sort()
    |> execute_instructions()
  end

  def part_2(input, no_workers \\ 5) do
    input
    |> parse_and_map()
    |> sort()
    |> workers_execute_instructions([], 0, no_workers)
  end

  @doc """
      iex> Day7.parse_and_map(
      ...> \"""
      ...> Step C must be finished before step A can begin.
      ...> Step C must be finished before step F can begin.
      ...> Step A must be finished before step B can begin.
      ...> Step A must be finished before step D can begin.
      ...> Step B must be finished before step E can begin.
      ...> Step D must be finished before step E can begin.
      ...> Step F must be finished before step E can begin.
      ...> \""")
      [
        {"A", ["C"]},
        {"B", ["A"]},
        {"C", []},
        {"D", ["A"]},
        {"E", ["F", "D", "B"]},
        {"F", ["C"]}
      ]

  """

  def parse_and_map(input) do
    input
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.reduce(%{}, fn row, acc ->
      [dependency, step] =
        String.split(row, ["Step ", " must be finished before step ", " can begin."], trim: true)

      acc
      |> Map.update(dependency, [], & &1)
      |> Map.update(step, [dependency], &[dependency | &1])
    end)
    |> Map.to_list()
  end

  @doc """
      iex> Day7.sort([{"B", ["A"]}, {"A", ["C"]}, {"C", []}, {"F", ["C"]}, {"D", ["A"]}, {"E", ["B", "D", "F"]}])
      [
        {"C", []},
        {"A", ["C"]},
        {"B", ["A"]},
        {"D", ["A"]},
        {"F", ["C"]},
        {"E", ["B", "D", "F"]}
      ]
  """

  def sort([]), do: []

  def sort(dependency_map) do
    dependency_map
    |> Enum.sort_by(&{length(elem(&1, 1)), elem(&1, 0)})
  end

  @doc """
      iex> Day7.execute_instructions([{"C", []}, {"A", ["C"]}, {"B", ["A"]}, {"D", ["A"]}, {"F", ["C"]}, {"E", ["B", "D", "F"]}])
      "CABDFE"
  """
  def execute_instructions(dependency_map), do: execute_instructions(dependency_map, [])

  def execute_instructions([], instructions_order),
    do: instructions_order |> Enum.reverse() |> Enum.join()

  def execute_instructions([{step, []} | rest], acc) do
    rest
    |> remove_executed_step(step)
    |> sort()
    |> execute_instructions([step | acc])
  end

  @doc """
      iex> Day7.remove_executed_step([{"B", ["A"]}, {"A", ["C"]}, {"C", []}, {"F", ["C"]}, {"D", ["A"]}, {"E", ["B", "D", "F"]}], "A")
      [{"B", []}, {"A", ["C"]}, {"C", []}, {"F", ["C"]}, {"D", []}, {"E", ["B", "D", "F"]}]
  """
  def remove_executed_step(steps, step) do
    steps
    |> Enum.map(fn {key, steps} ->
      {key, Enum.filter(steps, fn s -> s != step end)}
    end)
  end

  # Part 2
  def workers_execute_instructions([], [], total_time, _no_workers), do: total_time

  def workers_execute_instructions(steps, workers, total_time, no_workers)
      when length(workers) == no_workers do
    {workers, steps} = go_to_work(workers, steps)

    workers_execute_instructions(steps, workers, total_time + 1, no_workers)
  end

  def workers_execute_instructions(steps, workers, total_time, no_workers)
      when length(workers) != no_workers do
    available_workers = no_workers - length(workers)
    available_steps = steps |> Enum.filter(fn {_worker, step} -> step == [] end) |> Enum.count()
    steps_worked_on = min(available_workers, available_steps)

    {work_to_do, rest} = Enum.split(steps, steps_worked_on)
    work_to_do = Enum.map(work_to_do, fn {step, _} -> step end)

    current_workers =
      work_to_do
      |> Enum.map(fn worker ->
        [codepoint | _] = worker |> to_charlist()
        {worker, codepoint - 4}
      end)

    workers = current_workers ++ workers

    {workers, rest} = go_to_work(workers, rest)
    workers_execute_instructions(rest, workers, total_time + 1, no_workers)
  end

  def go_to_work(workers, work) do
    workers =
      workers
      |> Enum.map(fn {step, time_left} -> {step, time_left - 1} end)

    work =
      workers
      |> Enum.reduce(
        work,
        fn
          {step, 0}, acc -> remove_executed_step(acc, step) |> sort()
          _, acc -> acc
        end
      )

    workers =
      workers
      |> Enum.filter(fn
        {_, 0} -> false
        _ -> true
      end)

    {workers, work}
  end
end

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
end

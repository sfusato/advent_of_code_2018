defmodule Day12 do
  defmodule Pots do
    defstruct current_state: [], spread_rules: %{}, leftmost: 0
  end

  @moduledoc """
  Documentation for Day12.
  """
  def part_1(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> grow_pots_generations(20)
    |> Map.take([:current_state, :leftmost])
    |> compute_sum()
  end

  def part_2(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> grow_pots_generations(5_000)
    |> Map.take([:current_state, :leftmost])
    |> compute_sum()
  end

  def parse_input(input) do
    [initial_state, spread_rules] =
      input
      |> String.split(["initial state: ", "\r\n\r\n"], trim: true)

    build_state_map(%Pots{}, initial_state)
    |> build_spread_rules_map(spread_rules)
  end

  def build_state_map(state, initial_state) do
    initial_state =
      initial_state
      |> String.graphemes()

    %Pots{state | current_state: initial_state, leftmost: 0}
  end

  def build_spread_rules_map(state, spread_rules) do
    spread_rules =
      spread_rules
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, " => ", trim: true))
      |> Enum.reduce(%{}, fn [pattern, result], acc ->
        pattern = pattern |> String.graphemes()
        Map.put(acc, pattern, result)
      end)

    %Pots{state | spread_rules: spread_rules}
  end

  def grow_pots_generations(state, generations) do
    grow_pots_generations(state, generations, 0)
  end

  def grow_pots_generations(state, done, done), do: state

  def grow_pots_generations(state, generations, count) do
    state
    |> grow_pots()
    |> grow_pots_generations(generations, count + 1)
  end

  def grow_pots(
        %Pots{
          current_state: current_state,
          spread_rules: spread_rules,
          leftmost: leftmost
        } = state
      ) do
    current_state = [".", ".", ".", "." | current_state]
    {next_generation, leftmost} = pass_one_generation(current_state, spread_rules, leftmost - 3)

    %Pots{state | current_state: next_generation, leftmost: leftmost}
  end

  def pass_one_generation(current_state, spread_rules, leftmost) do
    pass_one_generation(:first, current_state, spread_rules, [], leftmost)
  end

  def pass_one_generation(nil, [".", ".", ".", ".", "."], _, acc, leftmost) do
    {Enum.reverse(acc), leftmost}
  end

  def pass_one_generation(:first, [l2, l1, c, r1, r2 | tail], spread_rules, acc, leftmost) do
    case Map.fetch(spread_rules, [l2, l1, c, r1, r2]) do
      {:ok, pot} ->
        pass_one_generation(nil, [l1, c, r1, r2 | tail], spread_rules, [pot | acc], leftmost + 1)

      :error ->
        pass_one_generation(:first, [l1, c, r1, r2 | tail], spread_rules, acc, leftmost + 1)
    end
  end

  def pass_one_generation(nil, [l2, l1, c, r1, r2], spread_rules, acc, leftmost) do
    case Map.fetch(spread_rules, [l2, l1, c, r1, r2]) do
      {:ok, pot} ->
        pass_one_generation(nil, [l1, c, r1, r2, "."], spread_rules, [pot | acc], leftmost)

      :error ->
        pass_one_generation(nil, [l1, c, r1, r2, "."], spread_rules, ["." | acc], leftmost)
    end
  end

  def pass_one_generation(nil, [l2, l1, c, r1, r2 | tail], spread_rules, acc, leftmost) do
    pot = Map.get(spread_rules, [l2, l1, c, r1, r2], ".")

    pass_one_generation(nil, [l1, c, r1, r2 | tail], spread_rules, [pot | acc], leftmost)
  end

  def compute_sum(%{current_state: current_state, leftmost: leftmost}) do
    current_state
    |> Enum.reduce({0, leftmost}, fn
      ".", {sum, index} -> {sum, index + 1}
      "#", {sum, index} -> {sum + index, index + 1}
    end)
    |> elem(0)
  end
end

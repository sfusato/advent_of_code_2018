defmodule Day12 do
  defmodule Pots do
    defstruct current_state: MapSet.new(), spread_rules: MapSet.new()
  end

  @moduledoc """
  Documentation for Day12.
  """
  def part_1(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> pass_generations(20)
    |> count_total()
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
      |> Enum.with_index()
      |> Enum.filter(&match?({"#", _}, &1))
      |> Enum.map(&elem(&1, 1))
      |> MapSet.new()

    %Pots{state | current_state: initial_state}
  end

  def build_spread_rules_map(state, spread_rules) do
    spread_rules =
      spread_rules
      |> String.split("\r\n", trim: true)
      |> Enum.map(&String.split(&1, " => ", trim: true))
      |> Enum.reduce(MapSet.new(), fn
        [pattern, "#"], acc ->
          pattern = pattern |> String.graphemes()
          MapSet.put(acc, pattern)

        [_pattern, "."], acc ->
          acc
      end)

    %Pots{state | spread_rules: spread_rules}
  end

  def pass_generations(state, generations) do
    pass_generations(state, 0, generations)
  end

  def pass_generations(state, equal, equal), do: state

  def pass_generations(state, count, total) do
    state
    |> grow_pots()
    |> pass_generations(count + 1, total)
  end

  def grow_pots(%Pots{current_state: current_state, spread_rules: spread_rules}) do
    {leftmost, rightmost} = Enum.min_max(current_state)

    new_state =
      (leftmost - 4)..(rightmost + 4)
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.filter(fn indices ->
        plants =
          Enum.map(indices, fn i -> if MapSet.member?(current_state, i), do: "#", else: "." end)

        MapSet.member?(spread_rules, plants)
      end)
      |> Enum.map(fn [_, _, c, _, _] -> c end)
      |> MapSet.new()

    %Pots{current_state: new_state, spread_rules: spread_rules}
  end

  def count_total(state) do
    state
    |> Map.fetch!(:current_state)
    |> Enum.sum()
  end

  ##########
  # PART 2 #
  ##########
  def part_2(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> find_stability()
  end

  def find_stability(state) do
    Enum.reduce_while(1..50_000_000_000, {state, 0, []}, fn i, {state, prev, diffs} ->
      new_state = grow_pots(state)
      count = count_total(new_state)
      diff = count - prev
      diffs = [diff | diffs]

      if length(diffs) < 10 do
        {:cont, {new_state, count, diffs}}
      else
        case Enum.uniq(diffs) do
          [uniq] -> {:halt, (50_000_000_000 - i) * uniq + count}
          _not_uniq -> {:cont, {new_state, count, Enum.take(diffs, 10)}}
        end
      end
    end)
  end
end

defmodule Day9 do
  @moduledoc """
  Documentation for Day9.
  """
  def part_1(no_players \\ 476, last_marble \\ 71431) do
    Stream.cycle(1..no_players)
    |> Enum.take(last_marble)
    |> reduce_marble_mania(last_marble)
    # |> play_marble_mania([0], [], 1, %{})
    |> winner_score()
  end

  def part_2(no_players \\ 476, last_marble \\ 7_143_100) do
    Stream.cycle(1..no_players)
    |> Enum.take(last_marble)
    |> reduce_marble_mania(last_marble)
    |> winner_score()
  end

  def reduce_marble_mania(turns, last_marble) do
    Enum.reduce_while(turns, {%{}, [0], [], 1}, fn
      player, {scores, first_half, second_half, curr} when rem(curr, 23) == 0 ->
        list = second_half ++ first_half
        additional_points = list |> Enum.reverse() |> Enum.at(8, 0)

        list = list |> Enum.reverse() |> List.delete_at(8)

        {second_half, first_half} = list |> Enum.split(6)

        second_half = second_half |> Enum.reverse()
        first_half = first_half |> Enum.reverse()

        points_won = curr + additional_points

        scores = Map.update(scores, player, points_won, &(&1 + points_won))

        {:cont, {scores, first_half, second_half, curr + 1}}

      _player, {scores, [head | first_half], [], curr} ->
        {:cont, {scores, [head], first_half ++ [curr], curr + 1}}

      _player, {scores, first_half, [head | second_half], curr} ->
        {:cont, {scores, first_half ++ [curr, head], second_half, curr + 1}}

      _player, {scores, _, _, ^last_marble} ->
        {:halt, scores}
    end)
  end

  def play_marble_mania([], _, _, _, acc), do: acc

  def play_marble_mania([player | rest], first_half, second_half, played_marble, acc)
      when rem(played_marble, 23) == 0 do
    list = second_half ++ first_half
    additional_points = list |> Enum.reverse() |> Enum.at(8, 0)

    list = list |> Enum.reverse() |> List.delete_at(8)

    {second_half, first_half} = list |> Enum.split(6)

    second_half = second_half |> Enum.reverse()
    first_half = first_half |> Enum.reverse()

    points_won = played_marble + additional_points

    acc = Map.update(acc, player, points_won, &(&1 + points_won))

    play_marble_mania(
      rest,
      first_half,
      second_half,
      played_marble + 1,
      acc
    )
  end

  def play_marble_mania([_player | rest], [head | first_half], [], curr_marble, acc) do
    play_marble_mania(rest, [head], first_half ++ [curr_marble], curr_marble + 1, acc)
  end

  def play_marble_mania([_player | rest], first_half, [head | second_half], curr_marble, acc) do
    play_marble_mania(rest, first_half ++ [curr_marble, head], second_half, curr_marble + 1, acc)
  end

  def winner_score({scores, _, _, _}) do
    scores
    |> Map.values()
    |> Enum.max()
  end

  def winner_score(scores) do
    scores
    |> Map.values()
    |> Enum.max()
  end
end

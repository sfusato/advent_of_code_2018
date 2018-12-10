defmodule Day9 do
  @moduledoc """
  Documentation for Day9.
  """
  def part_1(no_players \\ 476, last_marble \\ 71431) do
    Stream.cycle(1..no_players)
    |> Enum.take(last_marble)
    |> reduce_marble_mania(last_marble)
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
      player, {scores, circle, acc, curr} when rem(curr, 23) == 0 ->
        list = Enum.reverse(acc) ++ Enum.reverse(circle)

        additional_points = list |> Enum.at(7)

        list = list |> List.delete_at(7)

        {circle, acc} = list |> Enum.split(6)

        acc = Enum.reverse(acc)
        circle = Enum.reverse(circle)

        points_won = curr + additional_points

        scores = Map.update(scores, player, points_won, &(&1 + points_won))

        {:cont, {scores, circle, acc, curr + 1}}

      _player, {scores, [first, second | circle], acc, curr} ->
        {:cont, {scores, [second | circle], acc ++ [first, curr], curr + 1}}

      _player, {scores, [circle], acc, curr} ->
        {:cont, {scores, acc ++ [circle, curr], [], curr + 1}}

      _player, {scores, _, _, ^last_marble} ->
        {:halt, scores}
    end)
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

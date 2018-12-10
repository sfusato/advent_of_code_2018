defmodule Day9 do
  @moduledoc """
  Documentation for Day9.
  """
  def part_1(no_players \\ 476, last_marble \\ 71_431) do
    play_marble_mania({%{}, %{0 => {0, 0}}, 0, 0}, 0, last_marble + 1, no_players)
  end

  def part_2(no_players \\ 476, last_marble \\ 7_143_100) do
    play_marble_mania({%{}, %{0 => {0, 0}}, 0, 0}, 0, last_marble + 1, no_players)
  end

  def play_marble_mania({scores, _circle, _, _}, turns, turns, _total_players) do
    scores
    |> Map.values()
    |> Enum.max()
  end

  def play_marble_mania({scores, circle, player, current}, turn, turns, total_players)
      when rem(turn, 23) == 0 do
    removed_marble =
      current
      |> Stream.iterate(fn current -> circle |> Map.fetch!(current) |> elem(0) end)
      |> Stream.drop(1)
      |> Enum.take(7)
      |> List.last()

    {one_counter_clockwise, one_clockwise} = Map.fetch!(circle, removed_marble)

    circle =
      circle
      |> Map.update!(one_counter_clockwise, &{elem(&1, 0), one_clockwise})
      |> Map.update!(one_clockwise, &{one_counter_clockwise, elem(&1, 1)})

    score = turn + removed_marble
    scores = Map.update(scores, player, score, &(&1 + score))

    player = if player > total_players - 1, do: 1, else: player + 1

    play_marble_mania({scores, circle, player, one_clockwise}, turn + 1, turns, total_players)
  end

  def play_marble_mania({scores, circle, player, current}, turn, turns, total_players) do
    {_one_couner_clockwise, one_clockwise} = Map.fetch!(circle, current)
    {_two_counter_clockwise, two_clockwise} = Map.fetch!(circle, one_clockwise)

    circle =
      circle
      |> Map.update!(one_clockwise, &{elem(&1, 0), turn})
      |> Map.put(turn, {one_clockwise, two_clockwise})
      |> Map.update!(two_clockwise, &{turn, elem(&1, 1)})

    player = if player > total_players - 1, do: 1, else: player + 1

    play_marble_mania({scores, circle, player, turn}, turn + 1, turns, total_players)
  end

  # Not efficient enough for part 2
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

defmodule Main do
  def part_1() do
    twos = input() |> Enum.filter(&two_repetitions/1) |> Enum.count()
    threes = input() |> Enum.filter(&three_repetitions/1) |> Enum.count()

    twos * threes
  end

  def part_2() do
    input =
      input()
      |> Enum.map(fn x -> String.replace_suffix(x, "\n", "") end)

    for i <- input,
        j <- input,
        i != j,
        one_char_diff(i, j) do
      i
    end
    |> common_part()
  end

  defp three_repetitions(string), do: string |> String.graphemes() |> three_repetitions(%{})

  defp three_repetitions([], map_count) do
    map_count
    |> Map.values()
    |> Enum.max() >= 3
  end

  defp three_repetitions([head | tail], map_count) do
    {_, map_count} =
      map_count
      |> Map.get_and_update(head, fn
        nil -> {nil, 1}
        curr_count -> {curr_count, curr_count + 1}
      end)

    three_repetitions(tail, map_count)
  end

  defp two_repetitions(string) when is_bitstring(string) do
    string |> String.graphemes() |> two_repetitions(%{})
  end

  defp two_repetitions([], map_count) do
    map_count
    |> Map.values()
    |> Enum.member?(2)
  end

  defp two_repetitions([head | tail], map_count) do
    {_, map_count} =
      map_count
      |> Map.get_and_update(head, fn
        nil -> {nil, 1}
        curr_count -> {curr_count, curr_count + 1}
      end)

    two_repetitions(tail, map_count)
  end

  defp one_char_diff(a, b) do
    if String.length(a) == String.length(b) do
      do_one_char_diff(String.graphemes(a), String.graphemes(b), 0)
    else
      false
    end
  end

  defp do_one_char_diff(_, _, 2), do: false
  defp do_one_char_diff([], [], _), do: true
  defp do_one_char_diff([same | t_a], [same | t_b], diffs), do: do_one_char_diff(t_a, t_b, diffs)

  defp do_one_char_diff([_ | t_a], [_ | t_b], count),
    do: do_one_char_diff(t_a, t_b, count + 1)

  defp common_part([a, b]), do: common_part(String.graphemes(a), String.graphemes(b), [])
  defp common_part([], [], acc), do: acc |> Enum.reverse() |> Enum.join()
  defp common_part([x | tail_a], [x | tail_b], acc), do: common_part(tail_a, tail_b, [x | acc])
  defp common_part([_ | tail_a], [_ | tail_b], acc), do: common_part(tail_a, tail_b, acc)

  defp input(), do: File.stream!("./input.txt")
end

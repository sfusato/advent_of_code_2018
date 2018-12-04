defmodule Day1 do
  def part_1() do
    File.stream!("./input.txt")
    |> Enum.reduce(0, fn n, acc ->
      n =
        String.replace_suffix(n, "\n", "")
        |> String.to_integer()

      n + acc
    end)
  end

  def part_2() do
    File.stream!("./input.txt")
    |> Stream.cycle()
    |> Enum.reduce_while(%{acc: 0, set: MapSet.new([])}, fn n, acc ->
      n =
        String.replace_suffix(n, "\n", "")
        |> String.to_integer()

      curr = acc.acc + n

      if MapSet.member?(acc.set, curr) do
        {:halt, curr}
      else
        {:cont, %{acc: curr, set: MapSet.put(acc.set, curr)}}
      end
    end)
  end
end

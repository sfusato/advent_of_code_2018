defmodule Main do
  def part_1(input \\ File.read!("./input.txt")) do
    input
    |> split_and_map()
    |> build_map_coordinates()
    |> overlapped_squares_count()
  end

  def part_2(input \\ File.read!("./input.txt")) do
    input = input |> split_and_map()

    non_overlapping_squares =
      input
      |> build_map_coordinates()
      |> Enum.filter(fn {key, val} -> length(val) == 1 end)
      |> Enum.map(fn {key, [val]} -> val end)

    [id] =
      for [id, _, _, w, h] <- input,
          w * h == Enum.count(non_overlapping_squares, &(&1 == id)) do
        id
      end

    id
  end

  def split_and_map(input) do
    input
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(&parse_claim/1)
  end

  def parse_claim(claim) do
    String.split(claim, ["#", " @ ", ",", ": ", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def build_map_coordinates(claims) do
    Enum.reduce(claims, %{}, fn [id, left, top, width, height], acc ->
      Enum.reduce((left + 1)..(left + width), acc, fn x, acc ->
        Enum.reduce((top + 1)..(top + height), acc, fn y, acc ->
          Map.update(acc, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  def overlapped_squares_count(coordinates_map) do
    coordinates_map
    |> Map.values()
    |> Enum.filter(fn list -> length(list) > 1 end)
    |> Enum.count()
  end
end

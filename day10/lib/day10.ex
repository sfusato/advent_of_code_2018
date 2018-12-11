defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  def part_1(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> reduce_stars()
    |> sort_stars()
    |> print_the_sky()
    |> write_to_file()
  end

  def part_2(input \\ File.read!("./input.txt")) do
    input
    |> parse_input()
    |> reduce_stars_seconds(0)
  end

  @doc """
      iex> Day10.parse_input(
      ...> \"""
      ...> position=< 9,  1> velocity=< 0,  2>
      ...> position=< 7,  0> velocity=<-1,  0>
      ...> position=< 3, -2> velocity=<-1,  1>
      ...> \""")
      [{9, 1, 0, 2}, {7, 0, -1, 0}, {3, -2, -1, 1}]
  """
  def parse_input(input) do
    input
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(fn row ->
      row
      |> String.replace(" ", "")
      |> String.split([",", "position=<", ">velocity=<", ">"], trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def reduce_stars_seconds(stars, acc) do
    prev_sky_area =
      stars
      |> sky_limits()
      |> sky_area()

    new_stars = stars |> align_stars()

    current_sky_area =
      new_stars
      |> sky_limits()
      |> sky_area()

    if prev_sky_area > current_sky_area do
      reduce_stars_seconds(new_stars, acc + 1)
    else
      acc
    end
  end

  def reduce_stars(stars) do
    prev_sky_area =
      stars
      |> sky_limits()
      |> sky_area()

    new_stars = stars |> align_stars()

    current_sky_area =
      new_stars
      |> sky_limits()
      |> sky_area()

    if prev_sky_area > current_sky_area do
      reduce_stars(new_stars)
    else
      stars
    end
  end

  @doc """
      iex> Day10.align_stars([{9, 1, 0, 2}, {7, 0, -1, 0}, {3, -2, -1, 1}])
      [{9, 3, 0, 2}, {6, 0, -1, 0}, {2, -1, -1, 1}]
  """
  def align_stars(stars) do
    Enum.map(stars, fn {x, y, vx, vy} ->
      {x + vx, y + vy, vx, vy}
    end)
  end

  @doc """
      iex> Day10.sort_stars([{9, 1, 0, 2}, {7, 0, -1, 0}, {3, -2, -1, 1}])
      [{3, -2, -1, 1}, {7, 0, -1, 0}, {9, 1, 0, 2}]
  """
  def sort_stars(stars) do
    stars
    |> Enum.sort_by(&{elem(&1, 1), elem(&1, 0)})
    |> Enum.uniq_by(fn {x, y, _, _} -> {x, y} end)
  end

  def print_the_sky(stars) do
    {min_col, max_col, min_row, max_row} = sky_limits(stars)

    Enum.reduce(min_row..max_row, {stars, ""}, fn row, acc ->
      Enum.reduce(min_col..max_col, acc, fn
        col, {[{star_col, star_row, _, _} | rest] = stars, acc} ->
          cond do
            col == star_col && row == star_row -> {rest, acc <> "#"}
            true -> {stars, acc <> "."}
          end

        _col, {[], acc} ->
          {[], acc <> "."}
      end)
    end)
    |> elem(1)
    |> String.graphemes()
    |> Enum.chunk_every(max_col - min_col + 1)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  def write_to_file(stars, file_output \\ "./output.txt") do
    File.write!(file_output, stars)
  end

  @doc """
      iex> Day10.sky_limits([{9, 1, 0, 2}, {7, 0, -1, 0}, {3, -2, -1, 1}])
      {3, 9, -2, 1}
  """
  def sky_limits(stars) do
    min_col = Enum.map(stars, fn {col, _, _, _} -> col end) |> Enum.min()
    max_col = Enum.map(stars, fn {col, _, _, _} -> col end) |> Enum.max()
    min_row = Enum.map(stars, fn {_, row, _, _} -> row end) |> Enum.min()
    max_row = Enum.map(stars, fn {_, row, _, _} -> row end) |> Enum.max()

    {min_col, max_col, min_row, max_row}
  end

  def sky_area({x, y, z, q}), do: (y - x) * (q - z)
end

defmodule Day11 do
  @moduledoc """
  Documentation for Day11.
  """

  @doc """
  Find the {x,y} coordinate of the top-left fuel cell of the 3x3 square with the largest total power in a 300x300 grid

      iex> Day11.part_1(18)
      {33, 45}
      iex> Day11.part_1(42)
      {21, 61}
  """
  def part_1(serial_no \\ 5791) do
    Enum.reduce(1..298, {0, nil}, fn x, acc ->
      Enum.reduce(1..298, acc, fn y, {max_power, cell} ->
        current_power = grid_3x3_power({x, y}, serial_no)

        if current_power > max_power do
          {current_power, {x, y}}
        else
          {max_power, cell}
        end
      end)
    end)
    |> elem(1)
  end

  @doc """
  Compute the power of a 3x3 grid given its top-left coordinate and serial number

      iex> Day11.grid_3x3_power({33, 45}, 18)
      29
      iex> Day11.grid_3x3_power({21, 61}, 42)
      30
  """
  def grid_3x3_power({x, y}, serial_no) do
    Enum.map(x..(x + 2), fn x ->
      Enum.reduce(y..(y + 2), 0, fn y, acc ->
        cell_power_level({x, y}, serial_no) + acc
      end)
    end)
    |> Enum.sum()
  end

  @doc """
  Compute the power of a cell given its coordinates and the serial number

      iex> Day11.cell_power_level({3, 5}, 8)
      4
      iex> Day11.cell_power_level({122, 79}, 57)
      -5
      iex> Day11.cell_power_level({217, 196}, 39)
      0
      iex> Day11.cell_power_level({101, 153}, 71)
      4
  """
  def cell_power_level({x, y}, serial_no) do
    rack_id = x + 10
    (((rack_id * y + serial_no) * rack_id) |> div(100) |> rem(10)) - 5
  end

  @doc """
  Find the {X,Y,size} identifier of the square with the largest total power

      iex> Day11.part_2(18)
      {90, 269, 16}
      iex> Day11.part_2(42)
      {232, 251, 12}
  """
  def part_2(serial_no \\ 5791) do
    summed_area_table = summed_area_table(serial_no)

    Task.async_stream(
      1..300,
      fn size ->
        Enum.reduce(1..(300 - size), {0, nil, nil}, fn x, acc ->
          Enum.reduce(1..(300 - size), acc, fn y, {max_power, cell, cell_size} ->
            current_power = grid_power_sum(summed_area_table, {x, y}, size)

            if current_power > max_power do
              {current_power, {x, y}, size}
            else
              {max_power, cell, cell_size}
            end
          end)
        end)
      end,
      ordered: false
    )
    |> Enum.sort_by(fn {_, {power, _, _}} -> power end, &>=/2)
    |> Enum.take(1)
    |> Enum.map(fn {_key, {_power, {x, y}, size}} -> {x, y, size} end)
    |> List.first()
  end

  @doc """
  Compute the power of a partial grid within a grid given the summed area table, top-left coordinate and size of the partial grid

      iex> summed_area_table = Day11.summed_area_table(18)
      iex> Day11.grid_power_sum(summed_area_table, {90, 269}, 16)
      113
      iex> summed_area_table = Day11.summed_area_table(42)
      iex> Day11.grid_power_sum(summed_area_table, {232, 251}, 12)
      119
  """
  def grid_power_sum(summed_area_table, {x, y}, size) do
    Map.get(summed_area_table, {x - 1, y - 1}, 0) +
      Map.get(summed_area_table, {x + size - 1, y + size - 1}, 0) -
      Map.get(summed_area_table, {x + size - 1, y - 1}, 0) -
      Map.get(summed_area_table, {x - 1, y + size - 1}, 0)
  end

  def summed_area_table(serial_no) do
    Enum.reduce(1..300, %{}, fn y, table ->
      Enum.reduce(1..300, table, fn x, table ->
        xy = cell_power_level({x, y}, serial_no)

        sum =
          case {x, y} do
            {1, 1} ->
              xy

            {_, 1} ->
              xy + Map.fetch!(table, {x - 1, 1})

            {1, _} ->
              xy + Map.fetch!(table, {x, y - 1})

            {x, y} ->
              xy + Map.fetch!(table, {x, y - 1}) + Map.fetch!(table, {x - 1, y}) -
                Map.fetch!(table, {x - 1, y - 1})
          end

        Map.put(table, {x, y}, sum)
      end)
    end)
  end
end

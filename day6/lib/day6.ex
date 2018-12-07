defmodule Day6 do
  @moduledoc """
  Documentation for Day6.
  """
  # 1. get grid boundaries
  # 2. build the grid
  # 3. compute the Manhattan distance for each point of the matrix to all coordinates as well as the sum of distances (for part_2)
  # 4. keep the closest/lowest or mark as duplicate (nil) if so
  # 5. filter out the infinite areas
  # 7. return the largest area
  def part_1(input) do
    coordinates = input |> parse()

    coordinates
    |> grid_boundaries()
    |> build_grid(coordinates)
    |> filter_out_infinite_areas()
    |> finite_areas_size()
    |> extract_largest_area_size()
  end

  def part_2(input, distance \\ 10000) do
    coordinates = input |> parse()

    coordinates
    |> grid_boundaries()
    |> build_grid(coordinates)
    |> filter_out_max_distance(distance)
    |> Enum.count()
  end

  def build_grid([[lower_col, upper_col], [lower_row, upper_row]], coordinates) do
    grid =
      Enum.reduce(lower_row..upper_row, %{}, fn row, acc ->
        Enum.reduce(lower_col..upper_col, acc, fn col, acc ->
          Map.put(
            acc,
            {col, row},
            {closest_coordinate({col, row}, coordinates),
             manhattan_distance_sum({col, row}, coordinates)}
          )
        end)
      end)

    {[[lower_col, upper_col], [lower_row, upper_row]], grid}
  end

  @doc """
  Manhattan Distance

  ## Examples

      iex> Day6.manhattan_distance({1,1},{5,1})
      4

  """
  def manhattan_distance({x_a, y_a}, {x_b, y_b}) do
    abs(x_a - x_b) + abs(y_a - y_b)
  end

  def parse(input) do
    input
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(fn row -> String.split(row, ", ") |> Enum.map(&String.to_integer/1) end)
  end

  @doc """
  Grid Boundaries

  ## Examples

      iex> Day6.grid_boundaries([[1, 1], [1, 6], [8, 3], [3, 4], [5, 5], [8, 9]])
      [[1,8],[1,9]]

  """
  def grid_boundaries(coordinates) do
    grid_boundaries(coordinates, _x_min = nil, _x_max = 0, _y_min = nil, _y_max = 0)
  end

  def grid_boundaries([], x_min, x_max, y_min, y_max), do: [[x_min, x_max], [y_min, y_max]]

  def grid_boundaries([[x, y] | rest], x_min, x_max, y_min, y_max) do
    x_min = if x < x_min, do: x, else: x_min
    x_max = if x > x_max, do: x, else: x_max
    y_min = if y < y_min, do: y, else: y_min
    y_max = if y > y_max, do: y, else: y_max

    grid_boundaries(rest, x_min, x_max, y_min, y_max)
  end

  @doc """
  Closest coordinate

  ## Examples

      iex> Day6.closest_coordinate({4,1}, [[1, 1], [1, 6], [8, 3], [3, 4], [5, 5], [8, 9]])
      {1,1}

      iex> Day6.closest_coordinate({5,1}, [[1, 1], [1, 6], [8, 3], [3, 4], [5, 5], [8, 9]])
      nil

  """
  def closest_coordinate({col, row}, coordinates) do
    distances =
      coordinates
      |> Enum.reduce(%{}, fn [x, y], acc ->
        Map.put(acc, {x, y}, manhattan_distance({x, y}, {col, row}))
      end)

    min_distance =
      distances
      |> Map.values()
      |> Enum.min()

    min_distances =
      distances
      |> Enum.filter(fn {_key, distance} -> distance == min_distance end)

    case min_distances do
      [{coordinate, _distance}] -> coordinate
      _ -> nil
    end
  end

  def manhattan_distance_sum({col, row}, coordinates) do
    coordinates
    |> Enum.reduce(0, fn [x, y], acc ->
      acc + manhattan_distance({x, y}, {col, row})
    end)
  end

  def filter_out_infinite_areas({[[lower_col, upper_col], [lower_row, upper_row]], grid}) do
    coordinates_with_infinite_areas =
      grid
      |> Enum.filter(fn {_, val} -> not is_nil(val) end)
      |> Enum.reduce(MapSet.new(), fn {{col, row}, {coordinate, _}}, acc ->
        if row in [lower_row, upper_row] or col in [lower_col, upper_col] do
          MapSet.put(acc, coordinate)
        else
          acc
        end
      end)

    grid
    |> Enum.filter(fn {_, {val, _}} -> not is_nil(val) end)
    |> Enum.filter(fn {_key, {coordinate, _}} ->
      coordinate not in coordinates_with_infinite_areas
    end)
  end

  def finite_areas_size(grid) do
    Enum.reduce(grid, %{}, fn {_point, {coordinate, _}}, acc ->
      Map.update(acc, coordinate, 1, &(&1 + 1))
    end)
  end

  def extract_largest_area_size(grid) do
    grid
    |> Map.values()
    |> Enum.max()
  end

  def filter_out_max_distance({_args, grid}, distance) do
    grid
    |> Enum.filter(fn {_, {_, dist}} -> dist < distance end)
  end
end

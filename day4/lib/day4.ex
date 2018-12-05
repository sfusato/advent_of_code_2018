defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  @doc """
  Day 4 - Part 1

  ## Examples

      iex> Day4.part_1(
      ...> \"""
      ...> [1518-11-01 00:00] Guard #10 begins shift
      ...> [1518-11-01 00:05] falls asleep
      ...> [1518-11-01 00:25] wakes up
      ...> [1518-11-01 00:30] falls asleep
      ...> [1518-11-01 00:55] wakes up
      ...> [1518-11-01 23:58] Guard #99 begins shift
      ...> [1518-11-02 00:40] falls asleep
      ...> [1518-11-02 00:50] wakes up
      ...> [1518-11-03 00:05] Guard #10 begins shift
      ...> [1518-11-03 00:24] falls asleep
      ...> [1518-11-03 00:29] wakes up
      ...> [1518-11-04 00:02] Guard #99 begins shift
      ...> [1518-11-04 00:36] falls asleep
      ...> [1518-11-04 00:46] wakes up
      ...> [1518-11-05 00:03] Guard #99 begins shift
      ...> [1518-11-05 00:45] falls asleep
      ...> [1518-11-05 00:55] wakes up
      ...> \""")
      240

  """
  def part_1(input) do
    input
    |> parse_records()
    |> sort_records()
    |> parse_datetime()
    |> split_guard_records()
    |> build_activity_map()
    |> Enum.sort_by(fn {_id, records} -> minutes_slept(records) end, &>=/2)
    |> List.first()
    |> id_x_most_sleepy_minute()
  end

  @doc """
  Day 4 - Part 2

  ## Examples

      iex> Day4.part_2(
      ...> \"""
      ...> [1518-11-01 00:00] Guard #10 begins shift
      ...> [1518-11-01 00:05] falls asleep
      ...> [1518-11-01 00:25] wakes up
      ...> [1518-11-01 00:30] falls asleep
      ...> [1518-11-01 00:55] wakes up
      ...> [1518-11-01 23:58] Guard #99 begins shift
      ...> [1518-11-02 00:40] falls asleep
      ...> [1518-11-02 00:50] wakes up
      ...> [1518-11-03 00:05] Guard #10 begins shift
      ...> [1518-11-03 00:24] falls asleep
      ...> [1518-11-03 00:29] wakes up
      ...> [1518-11-04 00:02] Guard #99 begins shift
      ...> [1518-11-04 00:36] falls asleep
      ...> [1518-11-04 00:46] wakes up
      ...> [1518-11-05 00:03] Guard #99 begins shift
      ...> [1518-11-05 00:45] falls asleep
      ...> [1518-11-05 00:55] wakes up
      ...> \""")
      4455

  """

  def part_2(input) do
    {id, minute, _times} =
      input
      |> parse_records()
      |> sort_records()
      |> parse_datetime()
      |> split_guard_records()
      |> build_activity_map()
      |> Enum.map(&most_sleepy_minute/1)
      |> Enum.filter(fn x -> x != nil end)
      |> Enum.sort_by(fn {_, _, val} -> val end, &>=/2)
      |> List.first()

    id * minute
  end

  def parse_records(input) do
    input
    |> String.replace("[", "")
    |> String.replace("] ", "_")
    |> String.split(["\n", "\r"], trim: true)
    |> Enum.map(&String.split(&1, "_"))
    |> Enum.map(fn
      [datetime, "falls asleep"] ->
        [datetime, "-"]

      [datetime, "wakes up"] ->
        [datetime, "+"]

      [datetime, guard] ->
        [guard_id] = Regex.run(~r/[0-9]+/, guard)
        guard_id = String.to_integer(guard_id)
        [datetime, guard_id]
    end)
  end

  def sort_records(input) do
    input
    |> Enum.sort(fn [datetime1, _], [datetime2, _] -> datetime1 < datetime2 end)
  end

  def parse_datetime(datetimes) do
    datetimes
    |> Enum.map(fn [datetime, activity] ->
      [year, month, day, hour, minute] =
        String.split(datetime, ["-", " ", ":"]) |> Enum.map(&String.to_integer/1)

      [year, month, day, hour, minute, activity]
    end)
  end

  def split_guard_records(records), do: do_split_guard_records(records, %{})

  def do_split_guard_records([], acc), do: acc

  def do_split_guard_records([[_, _, _, _, _, id] | tail], acc) when is_integer(id) do
    {tail, guard_entries} = get_guard_entries(tail, [])
    acc = Map.update(acc, id, guard_entries, &(&1 ++ guard_entries))

    do_split_guard_records(tail, acc)
  end

  def get_guard_entries([], acc), do: {[], Enum.reverse(acc)}

  def get_guard_entries([[_, _, _, _, _, id] | _] = records, acc) when is_integer(id) do
    {records, Enum.reverse(acc)}
  end

  def get_guard_entries([entry | tail], acc) do
    get_guard_entries(tail, [entry | acc])
  end

  def build_activity_map(records_map) do
    Enum.reduce(records_map, %{}, fn {id, records}, acc ->
      slept_map = get_sleep_map(records, %{})

      Map.put(acc, id, slept_map)
    end)
  end

  def get_sleep_map([], map_acc), do: map_acc

  def get_sleep_map(
        [[_, month, day, _, start_minute, "-"], [_, _, _, _, end_minute, "+"] | tail],
        map_acc
      ) do
    range = start_minute..(end_minute - 1) |> Enum.to_list()

    map_acc =
      Map.update(
        map_acc,
        {month, day},
        range,
        &(&1 ++ range)
      )

    get_sleep_map(tail, map_acc)
  end

  def minutes_slept(records) do
    Enum.reduce(records, 0, fn {_day, minutes}, acc ->
      length(minutes) + acc
    end)
  end

  def most_sleepy_minute({id, records}) do
    case most_common_in_list(records, %{}) do
      nil ->
        nil

      {most_sleepy_minute, times} ->
        {id, most_sleepy_minute, times}
    end
  end

  def id_x_most_sleepy_minute({id, records}) do
    {most_sleepy_minute, _} = most_common_in_list(records, %{})
    id * most_sleepy_minute
  end

  def most_common_in_list(records, acc) when is_map(records),
    do: most_common_in_list(Map.values(records), acc)

  def most_common_in_list([], acc) do
    acc
    |> Enum.sort_by(fn {_key, val} -> val end, &>=/2)
    |> List.first()
  end

  def most_common_in_list([list | tail], acc) do
    acc =
      Enum.reduce(list, acc, fn x, acc ->
        Map.update(acc, x, 1, &(&1 + 1))
      end)

    most_common_in_list(tail, acc)
  end
end

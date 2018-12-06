defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """
  def part_1(input) do
    input
    |> scan_polymer(<<>>)
    |> byte_size()
  end

  def scan_polymer(<<>>, acc), do: String.reverse(acc)

  def scan_polymer(<<a, rest::binary>>, <<b, acc::binary>>) when abs(a - b) == 32 do
    scan_polymer(rest, acc)
  end

  def scan_polymer(<<a, rest::binary>>, acc) do
    scan_polymer(rest, <<a, acc::binary>>)
  end

  def part_2(input) do
    ?a..?z
    |> Task.async_stream(fn letter ->
      input
      |> replace_in_string_i(letter)
      |> part_1()
    end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.min()
  end

  def replace_in_string_i(str, char) do
    char = List.to_string([char])
    regex = Regex.compile!(char, "i")
    Regex.replace(regex, str, "")
  end
end

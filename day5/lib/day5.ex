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
    |> Task.async_stream(
      fn letter ->
        input
        |> discard_and_react(<<>>, letter)
        |> byte_size()

        # Regex method
        # input
        # |> replace_in_string_i(letter)
        # |> part_1()
      end,
      max_concurrency: 26,
      ordered: false
    )
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.min()
  end

  def discard_and_react(<<>>, acc, _), do: String.reverse(acc)

  def discard_and_react(<<a, rest::binary>>, <<b, acc::binary>>, letter) when abs(a - b) == 32 do
    discard_and_react(rest, acc, letter)
  end

  def discard_and_react(<<a, rest::binary>>, acc, letter) when a == letter or a == letter - 32 do
    discard_and_react(rest, acc, letter)
  end

  def discard_and_react(<<a, rest::binary>>, acc, letter) do
    discard_and_react(rest, <<a, acc::binary>>, letter)
  end

  # This + part_1() isn't much slower than the above method
  def replace_in_string_i(str, char) do
    char = List.to_string([char])
    regex = Regex.compile!(char, "i")
    Regex.replace(regex, str, "")
  end
end

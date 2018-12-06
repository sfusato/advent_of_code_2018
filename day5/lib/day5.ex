defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """
  def part_1(input) do
    input
    |> scan_polymer("")
    |> String.length()
  end

  # Stop condition on empty string; return the reversed accumulator
  def scan_polymer("", acc), do: String.reverse(acc)

  # Edge case: "bAaB" => gets here after "Aa" reaction with "b" in input and "B" in acc
  def scan_polymer(<<r>>, <<rr>>) when abs(r - rr) == 32, do: ""

  # Stop condition on one character; add it to the accumulator, reverse it and return it
  def scan_polymer(<<last>>, acc), do: String.reverse(<<last, acc::binary>>)

  # Immediate chain reaction clause: "dcbaABCD" chain reaction gets caught here after "aA" is found
  def scan_polymer(<<r, rest::binary>>, <<rr, acc::binary>>) when abs(r - rr) == 32 do
    scan_polymer(rest, acc)
  end

  # No immediate chain reaction; "AaB..." in input and "c..." in accumulator;
  def scan_polymer(<<first, second, rest::binary>>, acc) when abs(first - second) == 32 do
    scan_polymer(rest, acc)
  end

  # no chain reaction
  def scan_polymer(<<first, second, rest::binary>>, acc) do
    scan_polymer(<<second, rest::binary>>, <<first, acc::binary>>)
  end

  # an improvement would be to dynamically create the 'units' based on the input instead of going through all possible combinations a-z
  def part_2(input) do
    ?a..?z
    |> Enum.reduce([], fn letter, acc ->
      val =
        input
        |> replace_in_string_i(letter)
        |> part_1()

      [val | acc]
    end)
    |> Enum.min()
  end

  def replace_in_string_i(str, char) do
    char = List.to_string([char])
    regex = Regex.compile!(char, "i")
    Regex.replace(regex, str, "")
  end
end

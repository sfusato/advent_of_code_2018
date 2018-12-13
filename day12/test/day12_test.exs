defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  test "Day 12: Part 1" do
    assert Day12.part_1("""
           initial state: #..#.#..##......###...###

           ...## => #
           ..#.. => #
           .#... => #
           .#.#. => #
           .#.## => #
           .##.. => #
           .#### => #
           #.#.# => #
           #.### => #
           ##.#. => #
           ##.## => #
           ###.. => #
           ###.# => #
           ####. => #
           """) == 325
  end
end

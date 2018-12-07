defmodule Day6Test do
  use ExUnit.Case
  doctest Day6

  test "Day 6 default test case: Part 1" do
    assert Day6.part_1("""
           1, 1
           1, 6
           8, 3
           3, 4
           5, 5
           8, 9
           """) == 17
  end

  test "Day 6 default test case: Part 2" do
    assert Day6.part_2(
             """
             1, 1
             1, 6
             8, 3
             3, 4
             5, 5
             8, 9
             """,
             32
           ) == 16
  end
end

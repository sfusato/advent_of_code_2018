defmodule Day9Test do
  use ExUnit.Case
  doctest Day9

  test "Day 9: Part 1 #1" do
    assert Day9.part_1(9, 25) == 32
  end

  test "Day 9: Part 1 #2" do
    assert Day9.part_1(10, 1618) == 8317
  end

  test "Day 9: Part 1 #3" do
    assert Day9.part_1(13, 7999) == 146_373
  end

  test "Day 9: Part 1 #4" do
    assert Day9.part_1(17, 1104) == 2764
  end

  test "Day 9: Part 1 #5" do
    assert Day9.part_1(21, 6111) == 54718
  end

  test "Day 9: Part 1 #6" do
    assert Day9.part_1(30, 5807) == 37305
  end
end

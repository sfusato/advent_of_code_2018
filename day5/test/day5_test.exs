defmodule Day5Test do
  use ExUnit.Case
  doctest Day5

  test "Default polymer test part 1" do
    assert Day5.part_1("dabAcCaCBAcCcaDA") == 10
  end

  test "#2 test" do
    assert Day5.part_1("aabAAB") == 6
  end

  test "#3 test" do
    assert Day5.part_1("aA") == 0
  end

  test "#4 test" do
    assert Day5.part_1("abBA") == 0
  end

  test "#5 test" do
    assert Day5.part_1("abAB") == 4
  end

  test "#6 test" do
    assert Day5.part_1("aabAAB") == 6
  end

  test "Default polymer test part 2" do
    assert Day5.part_2("dabAcCaCBAcCcaDA") == 4
  end
end

defmodule Day7Test do
  use ExUnit.Case
  doctest Day7

  test "Day 7 - Part 1 default test case" do
    assert Day7.part_1("""
           Step C must be finished before step A can begin.
           Step C must be finished before step F can begin.
           Step A must be finished before step B can begin.
           Step A must be finished before step D can begin.
           Step B must be finished before step E can begin.
           Step D must be finished before step E can begin.
           Step F must be finished before step E can begin.
           """) == "CABDFE"
  end
end

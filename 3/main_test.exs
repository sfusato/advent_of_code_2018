if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("main.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(trace: true)

defmodule MainTest do
  use ExUnit.Case

  test "Part 1: default test case" do
    input = """
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    """

    assert Main.part_1(input) == 4
  end

  test "Part 2: default test case" do
    input = """
    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2
    """

    assert Main.part_2(input) == 3
  end
end

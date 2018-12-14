defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "move cart #1" do
    result =
      Day13.move_cart({1, 1}, %{direction: "^", next_intersection: :left}, %{{1, 0} => "|"})

    assert result == {{1, 0}, %{direction: "^", next_intersection: :left}}
  end

  test "move cart #2" do
    result =
      Day13.move_cart({1, 1}, %{direction: "^", next_intersection: :left}, %{{1, 0} => "/"})

    assert result == {{1, 0}, %{direction: ">", next_intersection: :left}}
  end

  test "move cart #3" do
    result =
      Day13.move_cart({1, 1}, %{direction: "^", next_intersection: :left}, %{{1, 0} => "\\"})

    assert result == {{1, 0}, %{direction: "<", next_intersection: :left}}
  end

  test "move cart #4" do
    result =
      Day13.move_cart({1, 1}, %{direction: ">", next_intersection: :left}, %{{2, 1} => "-"})

    assert result == {{2, 1}, %{direction: ">", next_intersection: :left}}
  end
end
